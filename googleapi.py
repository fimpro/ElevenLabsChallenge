import json
import os
from typing import List

import dotenv
import requests
from numpy import dot

dotenv.load_dotenv()

API_URL = "https://places.googleapis.com/v1/places:searchNearby"
API_KEY = os.getenv("API_KEY")
FIELD_MASK = "places.types,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.displayName,places.editorialSummary"
excluded_types = []


def get_nearby(location: List[float], radius: float, max_count: int):
    print("Getting nearby places...")
    request_data = {
        "maxResultCount": max_count,
        "languageCode": "pl",
        "locationRestriction": {
            "circle": {
                "center": {"latitude": location[0], "longitude": location[1]},
                "radius": radius,
            }
        },
        "excludedTypes": excluded_types,
    }
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": API_KEY,
        "X-Goog-FieldMask": FIELD_MASK,
    }
    response = requests.post(API_URL, json=request_data, headers=headers)

    response = response.json()

    with open("response.json", "w") as f:
        json.dump(response, f, indent=4)

    places = []

    for place in response["places"]:
        if not "tourist_attraction" in place["types"]:
            continue

        places.append(
            {
                "name": place["displayName"]["text"],
                "address": place["formattedAddress"],
                "location": [
                    place["location"]["latitude"],
                    place["location"]["longitude"],
                ],
                "rating": place["rating"],
                "userRatingCount": place["userRatingCount"],
                "summary": place.get("editorialSummary", {}).get("text", None),
            }
        )

    return places


places = get_nearby(location=[53.010255, 18.605087], radius=50, max_count=20)

with open("places.json", "w") as f:
    json.dump(places, f, indent=4)
