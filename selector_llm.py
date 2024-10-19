import os
from dotenv import load_dotenv
from openai import OpenAI
import time

load_dotenv()
openai_api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=openai_api_key)

class SelectorLLM:
    def __init__(self, model="4o-latest", log=False):
        self.messages = [
            {
                "role": "system", 
                "content": "You are a helpful travel guide assistant that selects the most suitable location based on given information and user preferences."
            }
        ]
        self.model = model
        self.log = log
        if self.log:
            print("\n*** Selector LLM conversation ***")

    def message(self, msg):
        start_t = time.time()
        if self.log:
            print(f"-USER- {msg}")
        
        self.messages.append({"role": "user", "content": msg})
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=self.messages
        )
        content = response.choices[0].message.content
        self.messages.append({"role": "assistant", "content": content})

        if self.log:
            print(f"-ASSISTANT ({time.time() - start_t:.2f}s)- {content}")

        return content
    