import os
from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables


def select_location(locations, user_preferences):

    load_dotenv()

    # Get the API key from the environment
    openai_api_key = os.getenv("OPENAI_API_KEY")

    # Initialize the OpenAI client with the API key
    client = OpenAI(api_key=openai_api_key)
    """
    Select the most suitable location based on the list of locations and user preferences.
    """
    prompt = f"Given the following list of locations and user preferences, select the most suitable location. Please provide your selection, keep the exact details of the selection. Describe the selection, generally, do not afress the user here.\n\n"
    prompt += f"Locations:\n {locations}\n\n"
    prompt += f"User Preferences: {user_preferences}\n\n"
    prompt += "Selected Location:"

    # Make the API call
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",  # Changed from "gpt-4o" to "gpt-3.5-turbo"
        messages=[
            {"role": "system", "content": "You are a helpful travel guide assistant that selects the most suitable location based on given information and user preferences."},
            {"role": "user", "content": prompt}
        ]
    )

    # Extract the selected location from the response
    selection = response.choices[0].message.content.strip()

    return selection

