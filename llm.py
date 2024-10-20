import os
import time
import tempfile
import datetime
from dotenv import load_dotenv
from langchain_community.chat_models import ChatOpenAI
from openai import OpenAI

load_dotenv()
openai_api_key = os.getenv("OPENAI_API_KEY")
perplexity_api_key = os.getenv("PERPLEXITY_API_KEY")

class LLM:
    def __init__(self, model="chatgpt-4o-latest", print_log=False):
        self.messages = [
            {
                "role": "system", 
                "content": open('prompts/system.txt', 'r').read()
            }
        ]
        self.model = model
        self.print_log = print_log
        self.full_log = ''
        self.log_file = tempfile.mktemp(suffix='.log', dir='logs')
        self.log(f'*** LLM conversation {datetime.datetime.now()} ***')
        self.openai_client = OpenAI(api_key=openai_api_key)
        self.perplexity_client = OpenAI(api_key=perplexity_api_key, base_url="https://api.perplexity.ai")

    def log(self, txt):
        self.full_log += txt + '\n'
        if self.print_log:
            print(txt)
        with open(self.log_file, 'w', encoding='utf-8') as file:
            file.write(self.full_log)

    def message(self, msg, use_internet=False):
        start_t = time.time()
        self.log(f"-USER- {msg}")
        
        self.messages.append({"role": "user", "content": msg})
        if use_internet:
            response = self.perplexity_client.chat.completions.create(
                model="llama-3.1-sonar-large-128k-online",
                messages=self.messages,
            )
        else:
            response = self.openai_client.chat.completions.create(
                model=self.model,
                messages=self.messages
            )
        content = response.choices[0].message.content
        self.messages.append({"role": "assistant", "content": content})

        self.log(f"-ASSISTANT ({time.time() - start_t:.2f}s)- {content}")

        return content
    
    def message_from_file(self, filename, use_internet=False, **kwargs):
        prompt = open(filename, 'r').read().format(**kwargs)
        return self.message(prompt, use_internet)
