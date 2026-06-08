import json
from sqlalchemy import create_engine
from sqlalchemy.types import TypeDecorator, TEXT as SqliteText
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import declarative_base, sessionmaker
from .config import settings

# Prioritize DATABASE_URL, then fallback to SUPABASE_DB_URL, then local SQLite
db_url = settings.DATABASE_URL or settings.SUPABASE_DB_URL

if not db_url:
    db_url = "sqlite:///./local_voiceflow.db"
elif db_url.startswith("postgres://"):
    # SQLAlchemy requires 'postgresql://' instead of legacy 'postgres://' scheme
    db_url = db_url.replace("postgres://", "postgresql://", 1)

connect_args = {}
if db_url.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

engine = create_engine(db_url, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# A custom array decorator that handles PostgreSQL's ARRAY type natively,
# but falls back to JSON strings for SQLite/local execution.
class TextArray(TypeDecorator):
    impl = SqliteText
    cache_ok = True

    def load_dialect_impl(self, dialect):
        if dialect.name == 'postgresql':
            return dialect.type_descriptor(ARRAY(SqliteText))
        else:
            return dialect.type_descriptor(SqliteText)

    def process_bind_param(self, value, dialect):
        if dialect.name == 'postgresql':
            return value
        if value is None:
            return None
        return json.dumps(value)

    def process_result_value(self, value, dialect):
        if dialect.name == 'postgresql':
            return value
        if value is None:
            return []
        if isinstance(value, list):
            return value
        try:
            return json.loads(value)
        except Exception:
            return []

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
