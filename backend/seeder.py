import os
import sys
import time
import random
from datetime import datetime, timezone, timedelta
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Pakistan Standard Time (PKT = UTC+5)
PKT = timezone(timedelta(hours=5))

# Add parent directory of database.py to sys.path to allow correct imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import supabase
from data.seed_reports import REPORTS_POOL

def seed_reports():
    print("====================================================")
    print("      CIRO Social Media Simulator & Seeder Started  ")
    print("====================================================\n")

    try:
        while True:
            report_data = random.choice(REPORTS_POOL)
            db_report = {
                "report_text": report_data["report_text"],
                "source": "social_media",
                "reported_by": report_data["reported_by"],
                "area_name": report_data["area_name"],
                "location_lat": report_data["location_lat"],
                "location_lng": report_data["location_lng"],
                "status": "pending"
            }
            
            timestamp = datetime.now(PKT).strftime("%Y-%m-%d %H:%M:%S PKT")
            print(f"[{timestamp}] Attempting to insert report for {db_report['area_name']}...")
            
            try:
                response = supabase.table("reports").insert(db_report).execute()
                if response.data:
                    inserted_report = response.data[0]
                    print(f" -> SUCCESS: Inserted report ID: {inserted_report['id']}")
                    print(f"    Text snippet: \"{db_report['report_text'][:60]}...\"")
                else:
                    print(" -> FAILED: Supabase returned empty data response.")
            except Exception as insert_error:
                print(f" -> ERROR during Supabase insertion: {insert_error}")
            
            # Choose random interval between 2 to 8 minutes
            sleep_duration = random.randint(120, 480)
            next_insert_time = datetime.fromtimestamp(time.time() + sleep_duration, tz=PKT).strftime("%H:%M:%S PKT")
            print(f" -> Sleeping for {sleep_duration} seconds ({sleep_duration // 60}m {sleep_duration % 60}s).")
            print(f"    Next report scheduled at {next_insert_time}.\n")
            
            time.sleep(sleep_duration)
            
    except KeyboardInterrupt:
        print("\nSeeding stopped manually. Exiting gracefully.")
    except Exception as general_error:
        print(f"\nFatal error in seeder: {general_error}")

if __name__ == "__main__":
    seed_reports()
