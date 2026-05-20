import os
from dotenv import load_dotenv
from google import genai

load_dotenv()


class ClientManager:
    def __init__(self):
        self.project = os.getenv("GOOGLE_CLOUD_PROJECT")
        self.location = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")

        if not self.project:
            raise ValueError("GOOGLE_CLOUD_PROJECT is missing in .env")

        self.client = genai.Client(
            vertexai=True,
            project=self.project,
            location=self.location,
        )

    def get_client(self) -> genai.Client:
        return self.client


_manager = ClientManager()


def get_client() -> genai.Client:
    return _manager.get_client()