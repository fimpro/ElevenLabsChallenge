FROM python:3.12-alpine

COPY requirements.txt .

RUN apk add ffmpeg

RUN pip install --no-cache-dir --upgrade -r requirements.txt

COPY . .

CMD ["fastapi", "run", "main.py"]
