from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import re
import logging
from .llm import process_input, train_model, train_model_2, generate_response, extract_email_parts, process_video




# Configure Logging for Debugging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter()

# Define request model
class RequestData(BaseModel):
    my_company: str
    my_designation: str
    my_name: str
    my_mail: str
    my_work: str
    my_cta_link: str
    client_name: str
    client_company: str
    client_designation: str
    client_mail: str
    client_website: str
    video_path: str

@router.post("/process-email/")
def process_email(data: RequestData):
    try:
        logger.info("Processing started for email generation")

        # Extracting website information
        client_about_website = process_input(data.client_website)
        logger.info("Client website analysis completed")

        # Analyzing video issues
        client_website_issue = process_video(data.video_path)
        logger.info(f"Processed video analysis: {client_website_issue}")

        # Training initial model
        system_prompt = train_model(
            data.my_company, data.my_designation, data.my_name, data.my_mail, data.my_work, 
            data.client_name, data.client_company, data.client_designation, data.client_mail, 
            data.client_website, client_website_issue, client_about_website
        )
        logger.info("Initial model training completed")

        # Generating response from trained model
        response = generate_response(system_prompt)
        if not response:
            raise ValueError("generate_response(system_prompt) returned empty")
        
        response = re.sub(r"\*\*", "", response)
        logger.info(f"Generated initial response: {response}")

        # Extracting email parts
        my_subject_text, my_body_text = extract_email_parts(response)
        logger.info(f"Extracted Email Subject: {my_subject_text}")

        # Training second model
        final_response = generate_response(
            train_model_2(
                data.my_company, data.my_designation, data.my_name, data.my_mail, data.my_work, 
                data.client_name, data.client_company, data.client_designation, data.client_mail, 
                data.client_website, client_website_issue, client_about_website, data.my_cta_link, 
                my_body_text
            )
        )

        if not final_response:
            raise ValueError("generate_response(train_model_2) returned empty")

        logger.info("Final response generated successfully")

        # Cleaning unnecessary characters
        final_response = re.sub(r"\{\{", "{", final_response)
        final_response = re.sub(r"\}\}", "}", final_response)

        # Extract HTML block
        pattern = r'```(.*?)```'
        matches = re.findall(pattern, final_response, re.DOTALL)
        logger.info(f"Extracted Matches: {matches}")

        cleaned_text = re.sub(r"^.*?<\s*!DOCTYPE\s+html.*?>\s*", "", matches[0], flags=re.DOTALL | re.IGNORECASE) if matches else ""

        logger.info(f"Cleaned HTML Content: {cleaned_text}")

        # Final response decision
        if "<html>" not in cleaned_text:
            logger.info("Returning plain text email")
            return {
                "subject": my_subject_text,
                "body_text": my_body_text
            }
        else:
            logger.info("Returning HTML email")
            return {
                "subject": my_subject_text,
                "cleaned_html": cleaned_text
            }

    except Exception as e:
        logger.error(f"Error Occurred: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
