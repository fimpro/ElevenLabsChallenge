import os
import time
import threading
from elevenlabs import VoiceSettings, play
from elevenlabs.client import ElevenLabs
import random


def find_id(path): #returns new highest id, from given
    i=0
    if(os.path.exists(path)):
        for filename in os.listdir(path):
            try:
                file = filename.removesuffix('.mp3')
                if int(file)>i:
                    i=int(file)
            except:
                i = random.randint(1,100000)
    else:
        os.mkdir(path)
    return i+1

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

def generate_audio(text,ID,path,max_time):
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
    save_file_path = f"{path}/{ID}.mp3"
    with open(save_file_path, "wb") as f:
        for chunk in response:
            if chunk:
                f.write(chunk)
    try:
        remove_old(path,max_time)
    except Exception as e:
        print("error during removing old files: ", e)
    #print(time.time(), "ENDG")

def text_to_speech_file(text: str,path = 'outputs',max_time=600): #returns path to .mp3 file with audio. .mp3 file will
                                                           # be created a few seconds after this function returns path.
    ID = find_id(path)
    threading.Thread(target=generate_audio,args=(text,ID,path,max_time)).start()
    return f"{path}\\{ID}.mp3"
