from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import email

app = FastAPI()

# Add CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins, change for security
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(email.router, prefix="/api")

@app.get("/")
def home():
    return {"message": "Welcome to the Email Processing API"}

