import json
import requests
from osm2geojson import json2geojson


def get_pois(location, radius):
    lat, lon = location

    q = f"""[out:json][timeout:300];

(
nwr(around:{radius}, {lat}, {lon})["tourism"~"attraction|artwork"];
nwr(around:{radius}, {lat}, {lon})["historic"];
);

out center;"""

    url = "https://overpass-api.de/api/interpreter"
    response = requests.post(url, data={"data": q}).json()

    return json2geojson(response)["features"]


def geocode(cords):
    cords = ",".join(map(str, cords[::-1]))
    url = f"https://nominatim.openstreetmap.org/search.php?q={cords}&format=jsonv2"
    response = requests.get(url, headers={"User-Agent": "sightseeing-app"}).json()
    if len(response) > 0:
        return response[0]["display_name"]

    return None


# features = get_pois(location=(54.010255, 18.605087), radius=3000)
features = get_pois(location=(53.010255, 18.605087), radius=50)

print(f'{len(features)} objects')

objects = []
for fet in features:
    obj = {
        'location': fet['geometry']['coordinates'],
    }
    # print(fet.keys())
    # print(fet['type'])
    print(fet['properties'])

# for feature in features:
#     cords = feature["geometry"]["coordinates"]
#     address = geocode(cords)
#     print(feature["properties"]["tags"]["name"] + " location: " + address)
