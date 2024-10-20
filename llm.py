import os
import time
import tempfile
import datetime
from dotenv import load_dotenv
from langchain_community.retrievers import YouRetriever
from langchain.chains import RetrievalQA
from langchain_community.chat_models import ChatOpenAI
from openai import OpenAI

load_dotenv()
openai_api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=openai_api_key)
yr = YouRetriever()

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
            content = RetrievalQA.from_chain_type(
                llm=ChatOpenAI(model=self.model, api_key=openai_api_key),
                chain_type="stuff",
                retriever=yr
            ).run(msg)
        else:
            response = client.chat.completions.create(
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
