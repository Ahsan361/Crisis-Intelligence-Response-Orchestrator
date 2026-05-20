import os
import json
from dotenv import load_dotenv
from google import genai

load_dotenv()


def setup_google_credentials():
    creds_json = os.getenv("GOOGLE_APPLICATION_CREDENTIALS_JSON")

    if creds_json:
        creds_path = "/tmp/google-credentials.json"

        with open(creds_path, "w") as f:
            json.dump(json.loads(creds_json), f)

        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = creds_path
        print("Google credentials loaded from GOOGLE_APPLICATION_CREDENTIALS_JSON")
    else:
        print("GOOGLE_APPLICATION_CREDENTIALS_JSON not found")


class ClientManager:
    def __init__(self):
        setup_google_credentials()

        self.project = os.getenv("GOOGLE_CLOUD_PROJECT")
        self.location = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")

        print("Google Cloud Project:", self.project)
        print("Google Cloud Location:", self.location)
        print("GOOGLE_APPLICATION_CREDENTIALS:", os.getenv("GOOGLE_APPLICATION_CREDENTIALS"))

        if not self.project:
            raise ValueError("GOOGLE_CLOUD_PROJECT is missing")

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