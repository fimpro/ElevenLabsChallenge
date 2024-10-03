import os
import time
import threading
from elevenlabs import VoiceSettings, play
from elevenlabs.client import ElevenLabs
import random
import subprocess
import tempfile

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

def generate_audio(text, path,emotions,voice):
    ELEVENLABS_API_KEY = open('elevenapikey.txt').readline()
    client = ElevenLabs(
        api_key=ELEVENLABS_API_KEY,
    )

    if(emotions=="energetic"):
        stability = 0.7
        similarity_boost = 0.9
        style = 0.4
    elif(emotions=="bored"):
        stability = 0.0
        similarity_boost = 0.0
        style = 0.0
    elif(emotions=="dramatic"):
        stability = 0.4
        similarity_boost = 0.6
        style = 0.8
    if(voice=="Anna"):
        voice_id = "Pid5DJleNF2sxsuF6YKD"
    elif(voice=="Charlotte"):
        voice_id = "XB0fDUnXU5powFXDhCwa"
    elif(voice=="Eric"):
        voice_id = "cjVigY5qzO86Huf0OWal"
    elif(voice=="Fin"):
        voice_id= "D38z5RcWu1voky8WS1ja"
    response = client.text_to_speech.convert( #maybe tune params
        voice_id= voice_id,  #imported
        output_format="mp3_22050_32",
        text=text,
        language_code='pl',
        model_id="eleven_turbo_v2_5",  # use the turbo model for low latency
        voice_settings=VoiceSettings(
            stability=stability,
            similarity_boost=similarity_boost,
            style=style,
            use_speaker_boost=True,
        ),
    )

    # temp path
    temp_path = tempfile.mktemp(suffix=".mp3")

    with open(temp_path, "wb") as f:
        for chunk in response:
            if chunk:
                f.write(chunk)

    # run ffmpeg -i generated_file.mp3 -acodec libmp3lame -ar 44100 -b:a 128k output.mp3

    subprocess.run(["ffmpeg", "-i", temp_path, "-acodec", "libmp3lame", "-ar", "44100", "-b:a", "128k", path], check=True)
    print(f're-encoded {path}')
    

def text_to_speech_file(text: str, path: str,emotions="energetic",voice="Eric"):#creates audiofile with text as speech
    threading.Thread(target=generate_audio,args=(text, path,emotions,voice)).start()