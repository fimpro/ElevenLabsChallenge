import json

import requests
from osm2geojson import json2geojson


def get_pois(lat, lon, radius):
    q = f"""
        [out:json][timeout:300];
        (
        nwr(around:{radius}, {lat}, {lon})["tourism"~"attraction|artwork"][name];
        nwr(around:{radius}, {lat}, {lon})["historic"][name];
        );

        out center;
    """

    url = "https://overpass-api.de/api/interpreter"
    response = requests.post(url, data={"data": q}).json()

    response = json2geojson(response)

    with open("response_osm.json", "w") as f:
        json.dump(response, f, indent=4)

    places = []

    for place in response["features"]:
        location = place["geometry"]["coordinates"]

        place_tags = []

        tags = place["properties"]["tags"]

        if "building" in tags:
            if tags["building"] == "yes":
                place_tags.append("building")
            else:
                place_tags.append(tags["building"])

        if "tourism" in tags:
            place_tags.append(tags["tourism"])

        if tags.get("historic", False):
            place_tags.append("historic")

        if "note" in tags:
            summary = tags["note"]
        else:
            summary = None

        places.append(
            {
                "id": place["properties"]["id"],
                "tags": place_tags,
                "name": tags["name"],
                "address": geocode(location),
                "location": location,
                "rating": None,
                "userRatingCount": None,
                "summary": summary,
            }
        )

    return places


def geocode(cords):
    cords = ",".join(map(str, cords[::-1]))
    url = f"https://nominatim.openstreetmap.org/search.php?q={cords}&format=jsonv2"
    response = requests.get(url, headers={"User-Agent": "sightseeing-app"}).json()
    if len(response) > 0:
        return response[0]["display_name"]
    return None


features = get_pois(53.010255, 18.605087, 100)


with open("places_osm.json", "w") as f:
    json.dump(features, f, indent=2)
