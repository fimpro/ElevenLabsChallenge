import requests
from bs4 import BeautifulSoup
import openai
from openai import OpenAI

# URL of the webpage to scrape
url = 'https://medium.com/@tejpal.abhyuday/retrieval-augmented-generation-rag-from-basics-to-advanced-a2b068fd576c'
client  = OpenAI(api_key='xD')
response = requests.get(url)

# Check if the request was successful (status code 200)
if response.status_code == 200:
    # Parse the HTML content using BeautifulSoup
    soup = BeautifulSoup(response.content, 'html.parser')
    #print(soup.prettify())

    # Extract the text from the webpage
    page_text = soup.get_text()

    # Find all the <p> tags (paragraphs)
    chat_response = client.chat.completions.create(
        model="gpt-3.5-turbo",  # You can use "gpt-3.5-turbo" for GPT-3.5 models
        messages=[
            {"role": "system", "content": "You will get raw html from webpage. Extract text and divide that text into paragraphs and separate them using <CHUJ> token. One paragraphs should be 3-4 sentences long"},
            {"role": "user", "content": page_text}
        ]
    )
    print(chat_response)
else:
    print(f"Failed to retrieve webpage. Status code: {response.status_code}")