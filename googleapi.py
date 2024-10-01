import os
from typing import List

import dotenv
import requests
from numpy import dot

places_type_list = []

dotenv.load_dotenv()

API_URL = "https://places.googleapis.com/v1/places:searchNearby"
API_KEY = os.getenv("API_KEY")
FIELD_MASK = "places.types,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.displayName,places.primaryTypeDisplayName,places.shortFormattedAddress,places.editorialSummary"


def get_nearby(location: List[float], radius: float, max_count: int):
    print("Getting nearby places...")
    request_data = {
        "includedTypes": places_type_list,
        "maxResultCount": max_count,
        "languageCode": "pl",
        "locationRestriction": {
            "circle": {
                "center": {"latitude": location[0], "longitude": location[1]},
                "radius": radius,
            }
        },
    }
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": API_KEY,
        "X-Goog-FieldMask": FIELD_MASK,
    }
    response = requests.post(API_URL, json=request_data, headers=headers)
    with open("response.json", "w") as file:
        file.write(response.text)


get_nearby(location=[53.010255, 18.605087], radius=50, max_count=20)
