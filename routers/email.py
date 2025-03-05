from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import re
from .llm import process_input, train_model, train_model_2, generate_response, extract_email_parts, process_video

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
        client_about_website = process_input(data.client_website)
        # print(1)

        client_website_issue = process_video(data.video_path, "local")



        system_prompt = train_model(data.my_company, data.my_designation, data.my_name, data.my_mail, data.my_work, 
                                    data.client_name, data.client_company, data.client_designation, data.client_mail, 
                                    data.client_website, client_website_issue, client_about_website)
        # print(2)
        response = generate_response(system_prompt)
        # print(3)
        response = re.sub(r"\*\*", "", response)
        # print(4)
        my_subject_text, my_body_text = extract_email_parts(response)
        # print(5)

        final_response = generate_response(
            train_model_2(data.my_company, data.my_designation, data.my_name, data.my_mail, data.my_work, 
                          data.client_name, data.client_company, data.client_designation, data.client_mail, 
                          data.client_website, client_website_issue, client_about_website, data.my_cta_link, 
                          my_body_text))

        text = re.sub(r"\{\{", "{", final_response)
        final_response = re.sub(r"\}\}", "}", text)

        pattern = r'```(.*?)```'
        matches = re.findall(pattern, final_response, re.DOTALL)

        pattern = r"^.*?<\s*!DOCTYPE\s+html.*?>\s*"
        cleaned_text = re.sub(pattern, "", matches[0], flags=re.DOTALL | re.IGNORECASE) if matches else ""

        if "<html>" not in cleaned_text:
            return {
                "subject": my_subject_text,
                "body_text": my_body_text
            }
        else:
            return {
                "subject": my_subject_text,
                "cleaned_html": cleaned_text
            }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
