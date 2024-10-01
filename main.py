import asyncio
import websockets

def location_to_poi():
    pass

def poi_to_audio():
    pass

async def handle_connection(websocket, path):
    print(websocket.remote_address)
    async for message in websocket:
        print(f"Received message: {message}")
        response = f"Hello from Python, you said: {message, path}"
        await websocket.send(response)

async def main():
    async with websockets.serve(handle_connection, "localhost", 8765):
        print("WebSocket server running on ws://localhost:8765")
        await asyncio.Future()  # keep the server running

if __name__ == '__main__':
    asyncio.run(main())