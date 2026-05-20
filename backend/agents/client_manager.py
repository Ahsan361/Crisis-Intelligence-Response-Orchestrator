import os
import json
from dotenv import load_dotenv
from google import genai

load_dotenv()


def setup_google_credentials():
    """
    For Render deployment:
    Reads service account JSON from env variable and writes it to a temp file.
    For local development:
    If GOOGLE_APPLICATION_CREDENTIALS already exists, it uses that.
    """

    creds_json = os.getenv("GOOGLE_APPLICATION_CREDENTIALS_JSON")

    if creds_json:
        creds_path = "/tmp/google-credentials.json"

        with open(creds_path, "w") as f:
            json.dump(json.loads(creds_json), f)

        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = creds_path


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