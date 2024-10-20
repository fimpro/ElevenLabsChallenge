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
from internet_llm import ask_question
from selector_llm import SelectorLLM

SEARCH_RADIUS = 40  # search in nearby 40 meters
MAX_FILETIME = 24 * 3600  # how long an audio file can stay in the 'outputs' folder
MIN_DISTANCE = (
    30  # minimum distance the user has to go to create the next google API request
)
MIN_TIME = 8  # minimum time (8 seconds) between google API requests, in case the user moves too fast
MAX_TIME = 30 * 60  # if a user does not answer for 30 minutes, it gets removed
PRINT_OUTPUTS = False  # writes some cool stuff on console when set to True


class User:
    def __init__(self, preferences, emotions, voice):
        self.prev_update = time.time()
        self.curr_location = None
        self.prev_request_location = None  # the location of previous API request
        self.prev_request_time = None  # the time of previous API request
        self.initiated = False
        self.emotions = emotions
        self.voice = voice
        self.location_history = []
        self.visited_places = []
        self.preferences = preferences

        if PRINT_OUTPUTS:
            print(
                f"Created a new user (emotions: {emotions}, voice: {voice}, preferences: {preferences})"
            )

    def update(self, location):
        self.location_history.append((location, time.time()))
        self.prev_update = time.time()
        self.curr_location = location

    # TODO: maybe averaging over previous 2-3 entries from location_history?
    # TODO: or linearly extrapolating from them to predict future location to decrease latency?
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


# TODO: uzupełnić summary w przypadku None (o ile nie ma ich za dużo)?
# converts places from google API to formatted version for llm
def places_to_descriptions(places):
    descriptions = []
    for place in places:
        descriptions.append(
            f"""{place['name']}
Address: {place['address']}
Rating: {'not provided' if place['rating'] is None else f'{place["rating"]:.1f} ({place["userRatingCount"]} reviews)'}
Tags: {'there are no provided' if len(place['tags']) == 0 else ', '.join(place['tags'])}
Summary: {'not provided' if place['summary'] is None else place['summary']}"""
        )
    return descriptions


class CreateTokenRequest(BaseModel):
    preferences: List[str]
    emotions: str
    voice: str


@app.post("/create_token")
async def create_token(req: CreateTokenRequest):
    token = secrets.token_hex(32)
    users[token] = User(
        ", ".join(req.preferences) if len(req.preferences) > 0 else "none",
        req.emotions.lower(),
        req.voice.lower(),
    )
    return {"token": token, "ok": True}


class InfoRequest(BaseModel):
    id: str


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


# Ask the LLM what is the best place
def choose_place(preferences, descs):
    if len(descs) < 2:
        return 0

    prompt = f"""Hi!
I am making an app that is supposed to automatically tell the user (a tourist in a city) some cool stuff about the things near them. Could you help me with that?
This means finding some nice monuments, cultural places, tourist attractions, or any places with deeper history.
The user has provided the following preferences: {preferences}.
Try to pick the place that fits the user's preferences the best. But, if there is a really popular place worth seeing, but not aligning exactly with the preferences, then still pick it: the user still wants to see everything, just likes the things mentioned in preferences A BIT more.
You should pick the place that offers some cool information that user might want to hear about.
Note that we will get those locations every 50 meters, so if there is nothing interesting right now, there is no problem with simply choosing no location at all, so definitely keep that in mind.
Also, the locations might not be formatted perfectly (and they might for example repeat) or they might even be in a different language than English so be ready for that.
I provided the ratings in scale 1-5 provided by Google services, but do not rely on them too much. Remember to also include the number of the location you pick in the final response.
With that in mind, choose the best location from these or choose that none of them are really worth seeing:"""

    for idx, desc in enumerate(descs):
        prompt += f"\n\nLocation {idx+1}: {desc}"

    chat = SelectorLLM("4o-latest", log=PRINT_OUTPUTS)
    chat.message(prompt)
    str_chosen_id = chat.message(
        "Now, for automatic record, write ONLY the number of the place that you have chosen or word 'none'."
    )
    if "none" in str_chosen_id.lower():
        return 0  # TODO (maybe cancel audio generation?)
    str_chosen_id = "".join([char for char in str_chosen_id if char.isdigit()])

    return int(str_chosen_id) - 1


def generate_audio(user, places, id):
    descs = places_to_descriptions(places)
    chosen_id = choose_place(user.preferences, descs)

    if PRINT_OUTPUTS:
        print(f"chosen id: {chosen_id}")
    if chosen_id < 0 or chosen_id >= len(places):
        print(
            f"WARNING: chosen id was {chosen_id}, but there are only {len(places)} places (forced chosen_id=0)"
        )
        chosen_id = 0

    infos[id]["location"] = places[chosen_id]["location"]
    infos[id]["name"] = places[chosen_id]["name"]

    place = descs[chosen_id]
    prompt = f"""I have found this place on google maps:
{place}

Tell something nice about this place to a tourist who has never seen it before. Tell it in an enjoyable way: include some fun facts and useful information, while not providing too much boring information like dates which no one will ever remember.
Only provide the description, so don't for example write 'Sure, here is the description: ...'. Instead, write it immediately. Also, make sure to write it in English, even if the place has some parts written in a different language."""

    if PRINT_OUTPUTS:
        print("Generating description...")
    final_result = ask_question(prompt)
    if PRINT_OUTPUTS:
        print(f"Description: {final_result}")
    user.visited_places.append(places[chosen_id]["id"])
    infos[id]["description"] = final_result

    print("Generating audio file...")
    text_to_speech_file(
        text=final_result,
        path=f"outputs/{id}.mp3",
        emotions=user.emotions,
        voice=user.voice,
    )


class UpdateRequest(BaseModel):
    prevent: bool
    lat: float
    lon: float


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
            threading.Thread(target=generate_audio, args=(user, places, id)).start()
            return {"ok": True, "new_file": True, "id": id}

        return {"ok": True, "new_file": False}
    else:
        return {"ok": False, "type": 1}
