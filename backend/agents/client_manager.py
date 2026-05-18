import os
from dotenv import load_dotenv
from google import genai

# Load environment variables
load_dotenv()

class ClientManager:
    def __init__(self):
        # Load keys from .env
        self.keys = [
            os.getenv("GEMINI_API_KEY_1"),
            os.getenv("GEMINI_API_KEY_2"),
            os.getenv("GEMINI_API_KEY_3"),
            os.getenv("GEMINI_API_KEY_4")
        ]
        # Filter out None values in case some keys are missing
        self.keys = [k for k in self.keys if k]
        
        if not self.keys:
            raise ValueError("No Gemini API keys found in .env. Please provide GEMINI_API_KEY_1, _2, or _3.")
            
        self.current_index = 0
        self.clients = [genai.Client(api_key=k) for k in self.keys]
        self.exhausted = [False] * len(self.keys)

    def get_client(self) -> genai.Client:
        """Returns the current genai.Client."""
        if all(self.exhausted):
            raise RuntimeError("All API keys exhausted. Please wait or add more keys.")
        return self.clients[self.current_index]

    def rotate_client(self):
        """Switches to the next available API key."""
        self.exhausted[self.current_index] = True
        
        # Find next non-exhausted key
        for i in range(len(self.keys)):
            next_index = (self.current_index + i + 1) % len(self.keys)
            if not self.exhausted[next_index]:
                self.current_index = next_index
                print(f"Rotating to API Key {self.current_index + 1}...")
                return
            
        raise RuntimeError("All API keys exhausted. Please wait or add more keys.")

# Singleton instance
_manager = ClientManager()

def get_client() -> genai.Client:
    return _manager.get_client()

def rotate_client():
    _manager.rotate_client()
