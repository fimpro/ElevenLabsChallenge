import json
import os
import random
from typing import List
from uuid import uuid4, uuid5

import dotenv
import requests

from tags import EXCLUDED_TAGS, INCLUDED_TAGS

dotenv.load_dotenv()

API_URL = "https://places.googleapis.com/v1/places:searchNearby"
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
if GOOGLE_API_KEY is None:
    print("Google api key is none")
fields = [
    "id",
    "types",
    "formattedAddress",
    "location",
    "rating",
    "userRatingCount",
    "displayName",
    "primaryTypeDisplayName",
    "editorialSummary",
    "photos",
]


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
        "X-Goog-Api-Key": GOOGLE_API_KEY,
        "X-Goog-FieldMask": ",".join([f"places.{field}" for field in fields]),
    }
    response = requests.post(API_URL, json=request_data, headers=headers)

    response = response.json()

    with open("response_google.json", "w") as f:
        json.dump(response, f, indent=4)

    places = []

    if not "places" in response:
        return []

    for place in response["places"]:
        has_rating = "rating" in place and "rating_count" in place
        places.append(
            {
                "id": place["id"],
                "tags": place["types"],
                "primary_tag": (
                    place["primaryTypeDisplayName"]["text"]
                    if "primaryTypeDisplayName" in place
                    else None
                ),
                "name": place["displayName"]["text"],
                "address": place["formattedAddress"],
                "location": [
                    place["location"]["latitude"],
                    place["location"]["longitude"],
                ],
                "rating": place["rating"] if has_rating else None,
                "rating_count": place["userRatingCount"] if has_rating else None,
                "summary": place.get("editorialSummary", {}).get("text", None),
                "photos_ids": [photo["name"] for photo in place.get("photos", [])],
            }
        )

    return places


def get_photos(place):
    photos_urls = []
    # filter only 3 random images
    place["photos_ids"] = random.sample(
        place["photos_ids"], min(3, len(place["photos_ids"]))
    )
    for photo_id in place["photos_ids"]:
        # maxHeightPx=400&maxWidthPx=400&
        url = f"https://places.googleapis.com/v1/{photo_id}/media?maxWidthPx=1000&key={GOOGLE_API_KEY}"
        # get response and save it to file
        response = requests.get(url)
        image_hash = uuid5(namespace=uuid4(), name=f"{place['id']}_{photo_id}")
        path = f"outputs/{image_hash}.jpg"
        with open(path, "wb") as f:
            f.write(response.content)

        photos_urls.append(f"images/{image_hash}.jpg")

    return photos_urls
