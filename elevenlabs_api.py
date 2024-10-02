import os
import time
import threading
from elevenlabs import VoiceSettings, play
from elevenlabs.client import ElevenLabs
import random

def remove_old(path,max_time): #romoves old files
    # Get the current time
    current_time = time.time()

    # Iterate over all files in the specified folder
    for filename in os.listdir(path):
        file_path = os.path.join(path, filename)
        #print(file_path)
        # Check if the path is a file
        if os.path.isfile(file_path):
            # Get the last modified time of the file
            file_mod_time = os.path.getmtime(file_path)

            # Calculate the age of the file
            file_age = current_time - file_mod_time
            # Remove the file if it's older than 10 minutes (600 seconds)
            if file_age > max_time:
                os.remove(file_path)
                #print(f'Removed: {file_path}')

def generate_audio(text, path):
    ELEVENLABS_API_KEY = open('elevenapikey.txt').readline()
    client = ElevenLabs(
        api_key=ELEVENLABS_API_KEY,
    )

    response = client.text_to_speech.convert( #maybe tune params
        voice_id="asDeXBMC8hUkhqqL7agO",  #imported
        output_format="mp3_22050_32",
        text=text,
        language_code='pl',
        model_id="eleven_turbo_v2_5",  # use the turbo model for low latency
        voice_settings=VoiceSettings(
            stability=0.2,
            similarity_boost=0.5,
            style=0.4,
            use_speaker_boost=True,
        ),
    )
    with open(path, "wb") as f:
        for chunk in response:
            if chunk:
                f.write(chunk)

def text_to_speech_file(text: str, path: str):#creates audiofile with text as speech
    threading.Thread(target=generate_audio,args=(text, path)).start()
