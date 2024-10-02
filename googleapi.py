import json
import os
from typing import List
import dotenv
import requests

from tags import INCLUDED_TAGS, EXCLUDED_TAGS

dotenv.load_dotenv()

API_URL = "https://places.googleapis.com/v1/places:searchNearby"
API_KEY = os.getenv("API_KEY")
FIELD_MASK = "places.types,places.formattedAddress,places.id,places.location,places.rating,places.userRatingCount,places.displayName,places.editorialSummary"

def get_nearby(location: List[float], radius: float):
    request_data = {
        "maxResultCount": 20,
        "languageCode": "pl",
        "locationRestriction": {
            "circle": {
                "center": {"latitude": location[0], "longitude": location[1]},
                "radius": radius,
            }
        },
        "includedTypes": INCLUDED_TAGS,
        "excludedTypes": EXCLUDED_TAGS,
    }
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": API_KEY,
        "X-Goog-FieldMask": FIELD_MASK,
    }
    response = requests.post(API_URL, json=request_data, headers=headers)

    response = response.json()

    with open("response_google.json", "w") as f:
        json.dump(response, f, indent=4)

    places = []

    for place in response["places"]:
        places.append(
            {
                "id": place["id"],
                "tags": place["types"],
                "name": place["displayName"]["text"],
                "address": place["formattedAddress"],
                "location": [
                    place["location"]["latitude"],
                    place["location"]["longitude"],
                ],
                "rating": place["rating"],
                "rating_count": place["userRatingCount"],
                "summary": place.get("editorialSummary", {}).get("text", None),
            }
        )

    return places


places = get_nearby(location=[53.010255, 18.605087], radius=50)

with open("places_google.json", "w") as f:
    json.dump(places, f, indent=4)
