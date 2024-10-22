import os
import time
import threading
from elevenlabs import VoiceSettings, play
from elevenlabs.client import ElevenLabs
import random
import subprocess
import tempfile


def remove_old(path, max_time):  # romoves old files
    # Get the current time
    current_time = time.time()

    # Iterate over all files in the specified folder
    for filename in os.listdir(path):
        file_path = os.path.join(path, filename)
        # print(file_path)
        # Check if the path is a file
        if os.path.isfile(file_path):
            # Get the last modified time of the file
            file_mod_time = os.path.getmtime(file_path)

            # Calculate the age of the file
            file_age = current_time - file_mod_time
            # Remove the file if it's older than 10 minutes (600 seconds)
            if file_age > max_time:
                os.remove(file_path)
                # print(f'Removed: {file_path}')


def generate_audio(text, path, emotions, voice):
    ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY")
    client = ElevenLabs(
        api_key=ELEVENLABS_API_KEY,
    )

    if emotions == "bored":
        stability = 0.0
        similarity_boost = 0.0
        style = 0.0
    elif emotions == "dramatic":
        stability = 0.4
        similarity_boost = 0.6
        style = 0.8
    else:
        stability = 0.7
        similarity_boost = 0.9
        style = 0.4

    if voice == "charlotte": ### In voice lib  Lily
        voice_id = "pFZP5JQG7iQjIQuC4Bku"
    elif voice == "eric":    ###In voice library Grandpa Slow Reading
        voice_id = "ZJ6YRAIdR3FwMeEx6NIc"
    elif voice == "fin":
        voice_id = "zZ78uuLgyOfL4C3MyVaj" ###in voice lib Thys -- Sexy
    else: ### in voice lab alice
        voice_id = "Xb7hH8MSUJpSbSDYk0k2"

    response = client.text_to_speech.convert(  # maybe tune params
        voice_id=voice_id,  # imported
        output_format="mp3_22050_32",
        text=text,
        language_code='en',
        model_id="eleven_turbo_v2_5",  # use the turbo model for low latency
        voice_settings=VoiceSettings(
            stability=stability,
            similarity_boost=similarity_boost,
            style=style,
            use_speaker_boost=True,
        ),
    )
    print("Generated audio!")

    # temp path
    temp_path = tempfile.mktemp(suffix=".mp3", dir="outputs")

    with open(temp_path, "wb") as f:
        for chunk in response:
            if chunk:
                f.write(chunk)

    print(f"downloaded audio to temporary directory: {temp_path}")
    print(f"ffmpeg -i {temp_path} -acodec libmp3lame {path}")

    # run ffmpeg -i generated_file.mp3 -acodec libmp3lame -ar 44100 -b:a 128k output.mp3
    # "-ar", "44100", "-b:a", "128k",

    subprocess.run(["ffmpeg", "-i", temp_path, "-acodec", "libmp3lame", path], check=True)
    print(f're-encoded {path}')


def text_to_speech_file(text: str, path: str, emotions="energetic",
                        voice="Eric"):  # creates audiofile with text as speech
    threading.Thread(target=generate_audio, args=(text, path, emotions, voice)).start()

#text_to_speech_file("History of that place is really interesting", "xd",voice = 'fin')
