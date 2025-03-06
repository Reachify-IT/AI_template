from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import email
import asyncio  # ✅ Import asyncio

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
async def home():  # ✅ Make it async to prevent blocking
    return {"message": "Welcome to the Email Processing API"}

# ✅ Ensure FastAPI runs in an event loop to prevent hanging
if __name__ == "__main__":
    import uvicorn
    asyncio.run(uvicorn.run(app, host="13.201.48.163", port=8000, log_level="debug"))
