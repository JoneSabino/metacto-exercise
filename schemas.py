from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# --- Feature Schemas ---

class FeatureBase(BaseModel):
    title: str
    description: Optional[str] = None

class FeatureCreate(FeatureBase):
    pass

class FeatureOut(FeatureBase):
    id: str
    votes: int = 0
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- Vote Schemas ---

class VoteCreate(BaseModel):
    # This identifier can be an IP hash, device ID, etc.
    user_identifier: str