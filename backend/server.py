import os
import shutil
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import random

app = FastAPI()

#CORS Setup (Crucial for Mobile/Emulator access)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

#Setup a local folder to mimic S3 Bucket
UPLOAD_DIR = "uploaded_files"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# health check
@app.get("/", status_code=200)
async def root():
    return {"status": "online", "message": "Backend is running on port 8000"}

# Upload audio
@app.post("/upload_audio", status_code=200)
async def upload_audio(
    file: UploadFile = File(...),
    audio_id: str = Form(...),          
    conversation_id: str = Form(...),
    farmer_id: str = Form(...),   
    timestamp: str = Form(...),
    duration: int = Form(...)
):
    try:
        # Generate a filename (Mimicking S3 Key)
        file_extension = file.filename.split('.')[-1]
        safe_filename = f"{audio_id}.{file_extension}"
        file_path = os.path.join(UPLOAD_DIR, safe_filename)

        # Save to local disk (Mimicking S3 Upload)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        print(f"Saved Audio: {safe_filename} | Farmer: {farmer_id}")
        
        # In a real app, metadata would have been saved to MongoDB here
        
        return { # return job id which the name of the audio file saved on the storage bucket
            "status":   "success",
            "job_id":   safe_filename,
            "s3_path":  file_path
        }
    except Exception as e:
        print(f"Error occured while uploading audio: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed. Error: {e}")

# Analyse audio
@app.get("/job/{job_id}", status_code=200)
async def generate_analysis(job_id: str):
    # In production, this will make a call to Gemini 1.5 Flash, get the analysis & return the result
    mock_results = [
        "Maize quality refers to its suitability for intended use, judged by appearance (no mold, damage, discoloration), physical traits (size, breakage, cracks).",
        "Potato phenotyping is the systematic measurement of potato plant and tuber traits (phenotypes) like yield, stress resistance, and quality.",
        "Paddy (rice) phenotyping involves the systematic, high-throughput, and non-destructive measurement of physiological, biochemical, and morphological properties of the rice plant to enhance breeding, improve yield, and ensure stress tolerance."
    ]

    try:
       
        return {
            "status": "success",
            "transcription": "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            "audio_analysis": random.choice(mock_results)
        }
    except Exception as e:
        print(f"Error occured while analysis of audio: {e}")
        raise HTTPException(status_code=500, detail=f"AI analysis of audio failed. Error: {e}")


if __name__ == "__main__":
    import uvicorn
    # Host 0.0.0.0 is required to be accessible from outside the container/machine
    uvicorn.run(app, host="0.0.0.0", port=5000)