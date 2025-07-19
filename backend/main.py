import logging
from fastapi import FastAPI, HTTPException, Body
from typing import List

from schemas import FeatureCreate, FeatureOut, VoteCreate
import firestore_client as db
from datetime import datetime, timezone

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = FastAPI(
    title="Feature Voting API",
    description="An API for submitting and voting on new product features.",
    version="1.0.0"
)

@app.on_event("startup")
async def startup_event():
    """Log a message when the application starts."""
    logging.info("Application startup complete. Checking Firestore connection...")
    # The client is initialized at module load time in firestore_client.py
    if db.db is None:
        logging.critical("FATAL: Firestore client could not be initialized. The application may not function correctly.")
    else:
        logging.info("Firestore client appears to be configured.")

@app.post("/features", response_model=FeatureOut, status_code=201)
def create_feature(feature: FeatureCreate):
    """
    Submit a new feature suggestion.
    """
    try:
        # This successfully saves the feature to Firestore with the server's timestamp
        new_feature = db.create_feature_in_db(title=feature.title, description=feature.description)

        # For the API response, replace the placeholder with a real datetime
        new_feature['created_at'] = datetime.now(timezone.utc)
        new_feature['votes'] = 0

        return new_feature
    except ConnectionError as e:
        logging.error(f"POST /features - Firestore connection error: {e}")
        raise HTTPException(status_code=503, detail="Could not connect to the database.")
    except Exception as e:
        logging.error(f"POST /features - An unexpected error occurred: {e}")
        raise HTTPException(status_code=500, detail="An internal server error occurred.")

@app.get("/features", response_model=List[FeatureOut])
def list_features():
    """
    Get a list of all submitted features, ordered by creation date, with vote counts.
    """
    try:
        features = db.get_features_with_votes()
        return features
    except ConnectionError as e:
        logging.error(f"GET /features - Firestore connection error: {e}")
        raise HTTPException(status_code=503, detail="Could not connect to the database.")
    except Exception as e:
        logging.error(f"GET /features - An unexpected error occurred: {e}")
        raise HTTPException(status_code=500, detail="An internal server error occurred.")

@app.post("/features/{feature_id}/vote", status_code=200)
def vote_for_feature(feature_id: str, vote: VoteCreate = Body(...)):
    """
    Register a vote for a specific feature.
    - `feature_id`: The ID of the feature to vote for.
    - `user_identifier`: A unique string for the user/device to prevent duplicate votes.
    """
    try:
        result = db.add_vote_to_feature(feature_id, vote.user_identifier)
        if result['status'] == 'error':
            # Differentiate between 'not found' and 'already voted'
            if result['message'] == 'Feature not found.':
                raise HTTPException(status_code=404, detail=result['message'])
            else: # 'Already voted'
                raise HTTPException(status_code=409, detail=result['message']) # 409 Conflict is suitable here
        return result
    except ConnectionError as e:
        logging.error(f"POST /features/{feature_id}/vote - Firestore connection error: {e}")
        raise HTTPException(status_code=503, detail="Could not connect to the database.")
    except Exception as e:
        logging.error(f"POST /features/{feature_id}/vote - An unexpected error occurred: {e}")
        raise HTTPException(status_code=500, detail="An internal server error occurred.")