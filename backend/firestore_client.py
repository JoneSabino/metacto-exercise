import os
import logging
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def get_firestore_client():
    """
    Initializes and returns a Firestore client.

    Uses service account credentials from the `GOOGLE_APPLICATION_CREDENTIALS`
    environment variable.
    """
    try:
        # Check if the app is already initialized
        if not firebase_admin._apps:
            # The GOOGLE_APPLICATION_CREDENTIALS env var is automatically used by `initialize_app`
            # when no credentials argument is provided.
            cred = credentials.ApplicationDefault()
            firebase_admin.initialize_app(cred, {
                'projectId': os.getenv('GCP_PROJECT_ID'),
            })
            logging.info("Firebase Admin SDK initialized successfully.")

        db = firestore.client()
        logging.info("Firestore client retrieved successfully.")
        return db
    except Exception as e:
        logging.error(f"Error connecting to Firestore: {e}")
        # Depending on the application's needs, you might want to raise the exception
        # or handle it gracefully. For this simple app, we'll return None.
        return None

db = get_firestore_client()

def create_feature_in_db(title: str, description: str) -> dict:
    """Adds a new feature document to the 'features' collection."""
    if not db:
        raise ConnectionError("Firestore client is not available.")

    doc_ref = db.collection('features').document()
    feature_data = {
        'title': title,
        'description': description,
        'created_at': firestore.SERVER_TIMESTAMP
    }
    doc_ref.set(feature_data)
    logging.info(f"Feature '{title}' created with ID: {doc_ref.id}")
    return {'id': doc_ref.id, **feature_data}

def get_features_with_votes() -> list:
    """Retrieves all features and their corresponding vote counts."""
    if not db:
        raise ConnectionError("Firestore client is not available.")

    features_ref = db.collection('features').order_by('created_at', direction='DESCENDING').stream()

    features_list = []
    for feature in features_ref:
        feature_data = feature.to_dict()
        feature_data['id'] = feature.id

        # Count votes for the current feature
        votes_query = db.collection('votes').where(filter=FieldFilter('featureId', '==', feature.id)).stream()
        vote_count = len(list(votes_query))
        feature_data['votes'] = vote_count

        features_list.append(feature_data)

    logging.info(f"Retrieved {len(features_list)} features with vote counts.")
    return features_list

def add_vote_to_feature(feature_id: str, user_identifier: str) -> dict:
    """Adds a vote for a feature, ensuring the user has not voted before."""
    if not db:
        raise ConnectionError("Firestore client is not available.")

    # 1. Check if the feature exists
    feature_ref = db.collection('features').document(feature_id)
    if not feature_ref.get().exists:
        logging.warning(f"Vote attempt on non-existent feature ID: {feature_id}")
        return {'status': 'error', 'message': 'Feature not found.'}

    # 2. Check for an existing vote from this user for this feature (deduplication)
    votes_ref = db.collection('votes')
    existing_vote_query = votes_ref.where(
        filter=FieldFilter('featureId', '==', feature_id)
    ).where(
        filter=FieldFilter('userId', '==', user_identifier)
    ).limit(1).stream()

    if len(list(existing_vote_query)) > 0:
        logging.info(f"User '{user_identifier}' has already voted for feature '{feature_id}'.")
        return {'status': 'error', 'message': 'Already voted.'}

    # 3. Add the new vote
    vote_data = {
        'featureId': feature_id,
        'userId': user_identifier,
        'voted_at': firestore.SERVER_TIMESTAMP
    }
    db.collection('votes').add(vote_data)
    logging.info(f"Vote registered for feature '{feature_id}' by user '{user_identifier}'.")
    return {'status': 'success', 'message': 'Vote registered.'}