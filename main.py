import os
import secrets
import threading
import time
import uuid
from typing import Annotated, List

from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import Depends, FastAPI, Header, HTTPException, responses
from fastapi.middleware.cors import CORSMiddleware
from geopy.distance import geodesic
from pydantic import BaseModel

from elevenlabs_api import remove_old, text_to_speech_file
from googleapi import get_nearby
from llm import LLM

SEARCH_RADIUS = 4000  # search in nearby 40 meters
MAX_FILETIME = 24 * 3600  # how long an audio file can stay in the 'outputs' folder
MIN_DISTANCE = 30  # minimum distance the user has to go to create the next google API request
MIN_TIME = 8  # minimum time (8 seconds) between google API requests, in case the user moves too fast
MAX_TIME = 30 * 60  # if a user does not answer for 30 minutes, it gets removed
PRINT_OUTPUTS = True  # writes some cool stuff on console when set to True


class User:
    def __init__(self, preferences, emotions, voice, language):
        self.initiated = False
        self.prev_update = time.time()
        self.prev_request_location = None  # the location of previous API request
        self.prev_request_time = None  # the time of previous API request
        self.curr_location = None

        self.emotions = emotions
        self.voice = voice
        self.language = language
        self.preferences = preferences

        self.location_history = []
        self.visited_places = []

        if PRINT_OUTPUTS:
            print(f"Created a new user (emotions: {emotions}, voice: {voice}, preferences: {preferences})")

    def update(self, location):
        self.location_history.append((location, time.time()))
        self.prev_update = time.time()
        self.curr_location = location

    def get_request_location(self):
        return self.curr_location

    def get_nearby(self):
        loc = self.get_request_location()

        self.initiated = True
        self.prev_request_time = time.time()
        self.prev_request_location = loc

        return get_nearby(location=loc, radius=SEARCH_RADIUS)

    def do_api_request(self):
        if not self.initiated:
            return True

        time_since_last_request = time.time() - self.prev_request_time
        distance = geodesic(
            self.prev_request_location, self.get_request_location()
        ).meters
        if time_since_last_request < MIN_TIME or distance < MIN_DISTANCE:
            if PRINT_OUTPUTS:
                print(
                    f"Rejected doing api request: {time_since_last_request:.2f}s passed (min {MIN_TIME}s), {distance}m travelled (min {MIN_DISTANCE}m)"
                )
            return False

        return True

    def time_since_last_update(self):
        return time.time() - self.prev_update


users = {}
infos = {}
app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if not os.path.exists("outputs"):
    os.makedirs("outputs")
if not os.path.exists("logs"):
    os.makedirs("logs")


def cleanup_users():
    try:
        remove_old("outputs", MAX_FILETIME)
    except Exception as e:
        print("error during removing old files: ", e)

    tokens = list(users.keys())
    for token in tokens:
        if users[token].time_since_last_update() > MAX_TIME:
            del users[token]


scheduler = BackgroundScheduler()
scheduler.add_job(cleanup_users, "interval", seconds=30)
scheduler.start()


# converts places from google API to formatted version for llm
def places_to_descriptions(places):
    descriptions = []
    for place in places:
        descriptions.append(
            f"""{place['name']}
Address: {place['address']}
Rating: {'not provided' if place['rating'] is None else f'{place["rating"]:.1f} ({place["userRatingCount"]} reviews)'}
Type: {'not provided' if place['primary_tag'] is None else place['primary_tag']}
Tags: {'there are no provided' if len(place['tags']) == 0 else ', '.join(place['tags'])}
Summary: {'not provided' if place['summary'] is None else place['summary']}"""
        )
    return descriptions

# ask the LLM what is the best place given preferences and descriptions
def choose_place(preferences, descs):
    if len(descs) < 2:
        return 0

    locations_formatted = ""
    for idx, desc in enumerate(descs):
        locations_formatted += f"\n\nLocation {idx+1}: {desc}"

    chat = LLM("chatgpt-4o-latest", print_log=PRINT_OUTPUTS)
    chat.message_from_file(
        'prompts/choose_place_1.txt', 
        preferences=preferences, 
        locations_formatted=locations_formatted
    )
    str_chosen_id = chat.message_from_file('prompts/choose_place_2.txt')
    if "none" in str_chosen_id.lower():
        return 0
    try:
        str_chosen_id = "".join([char for char in str_chosen_id if char.isdigit()])
        return int(str_chosen_id) - 1
    except Exception as e:
        print("ERROR: there was an error while decoding llm's answer (forcing chosen_id=0):")
        print(e)
        return 0

# describe a place (given preferences for better relevance)
def describe_place(preferences, language, place_id, google_description):
    print(f"describing place (id={place_id})...")

    chat = LLM("chatgpt-4o-latest", print_log=PRINT_OUTPUTS)
    return chat.message_from_file(
        'prompts/describe_pl.txt' if language == 'polish' else 'prompts/describe_en.txt', 
        use_internet=True,
        preferences=preferences,
        google_description=google_description
    )

# given user and places, pick one place, generate description for it and start generating audio
def generate_content_and_audio(user, places, id):
    descs = places_to_descriptions(places)
    chosen_id = choose_place(user.preferences, descs)

    if PRINT_OUTPUTS:
        print(f"chosen id: {chosen_id}")
    if chosen_id < 0 or chosen_id >= len(places):
        print(
            f"WARNING: chosen id was {chosen_id}, but there are only {len(places)} places (forced chosen_id=0)"
        )
        chosen_id = 0

    user.visited_places.append(places[chosen_id]["id"])
    infos[id]["location"] = places[chosen_id]["location"]
    infos[id]["name"] = places[chosen_id]["name"]

    description = describe_place(user.preferences, user.language, places[chosen_id]["id"], descs[chosen_id])
    infos[id]["description"] = description

    print("Generating audio file...")
    text_to_speech_file(
        text=description,
        path=f"outputs/{id}.mp3",
        emotions=user.emotions,
        voice=user.voice,
    )


class CreateTokenRequest(BaseModel):
    preferences: List[str]
    emotions: str
    voice: str
    language: str

class InfoRequest(BaseModel):
    id: str

class UpdateRequest(BaseModel):
    prevent: bool
    lat: float
    lon: float


@app.post("/create_token")
async def create_token(req: CreateTokenRequest):
    token = secrets.token_hex(32)
    users[token] = User(
        ", ".join(req.preferences) if len(req.preferences) > 0 else "none",
        req.emotions.lower(),
        req.voice.lower(),
        req.language.lower()
    )
    return {"token": token, "ok": True}

@app.post("/info")
async def check_id(req: InfoRequest):
    if req.id in infos:
        return {
            "audio_ready": os.path.isfile(f"outputs/{req.id}.mp3"),
            "info": infos[req.id],
        }
    else:
        # this should never happen, but it's always better to be sure...
        return {
            "audio_ready": False,
            "info": {"location": [None, None], "name": None, "description": None},
        }

@app.get("/audio/{id}.mp3")
async def download_audio(id: str):
    if id in infos:
        return responses.FileResponse(
            path=f"outputs/{id}.mp3", filename=f"{id}.mp3", media_type="audio/mpeg"
        )
    
@app.get("/ping")
async def ping():
    return "pong"

@app.post("/update")
async def update_user(
    req: UpdateRequest, authorization: Annotated[str | None, Header()] = None
):
    token = authorization.split(" ")[1]
    if PRINT_OUTPUTS:
        print(
            f"user log (token: {token}, prevent: {req.prevent}, lat: {req.lat}, lon: {req.lon})"
        )
    if token in users:
        user = users[token]
        user.update([req.lat, req.lon])
        if user.do_api_request() and req.prevent == 0:
            if PRINT_OUTPUTS:
                print(
                    "   ------------ BEGINNING CONTENT AND AUDIO GENERATION ------------"
                )

            places = user.get_nearby()

            # filter out any seen places
            for idx in range(len(places)):
                if places[idx]["id"] in user.visited_places:
                    del places[idx]

            if len(places) == 0:
                if PRINT_OUTPUTS:
                    print("could not find any suitable places!")
                return {"ok": True, "new_file": False}

            id = str(uuid.uuid4())
            infos[id] = {"location": [None, None], "name": None, "description": None}
            threading.Thread(target=generate_content_and_audio, args=(user, places, id)).start()
            return {"ok": True, "new_file": True, "id": id}

        return {"ok": True, "new_file": False}
    else:
        return {"ok": False, "type": 1}
