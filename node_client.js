const axios = require('axios');
const fs = require('fs');
const xlsx = require('xlsx');
const { exec } = require('child_process'); // ✅ Fix: Import exec from child_process

// API URL
const API_URL = 'http://localhost:8000/api/process-email/';
const EXCEL_FILE = 'email_responses.xlsx';

async function fetchGeneratedEmail() {
    console.log("\n🔄 Step 1: Starting Node.js script...");

    try {
        console.log("📡 Step 2: Sending request to FastAPI backend...");

        const emailContext = {
            my_company: "Reachify Innovations",
            my_designation: "CTO",
            my_name: "Abhinav Dogra",
            my_mail: "info@reachifyinnovations.com",
            my_work: "Software development and website optimization",
            my_cta_link: "https://www.reachifyinnovations.com/contactus",
            
            client_name: "Raghav Pratay",
            client_company: "Triumph Pvt Ltd",
            client_designation: "CEO",
            client_mail: "raghav@triumph.com",
            client_website: "https://www.triumphmotorcycles.in/",
            client_website_issue: "Navigation, Performance, Accessibility, Contact Page Issues.",
            video_path: "testing_video.mp4"
        };

        // Send request to FastAPI
        const response = await axios.post(API_URL, emailContext);
        console.log("✅ Step 3: Response received from FastAPI backend.");

        const responseData = response.data;

        console.log("\n📩 **Step 4: AI-Generated Email Output**");
        console.log("---------------------------------------------------");
        console.log(`📌 **Subject:** ${responseData.subject}`);
        console.log("---------------------------------------------------");

        let emailBody;
        
        // Save HTML or plain text
        if (responseData.cleaned_html) {
            console.log("📝 **Step 5: HTML Email Generated. Saving to file...**");
            fs.writeFileSync('email_output.html', responseData.cleaned_html);
            console.log("✅ Step 6: HTML email saved as email_output.html");
            emailBody = responseData.cleaned_html;
        } else {
            console.log(`📝 **Step 5: Plain Text Email Body:** ${responseData.body_text}`);
            emailBody = responseData.body_text;
        }

        // Save to Excel
        await saveToExcel(responseData.subject, emailBody);

        console.log("✅ Step 7: Script execution complete.\n");

    } catch (error) {
        console.error("❌ Step X: Error Occurred:", error.response ? error.response.data : error.message);
    }
}


function closeExcelIfOpen() {
    return new Promise((resolve) => {
        exec('tasklist', (err, stdout) => {
            if (stdout.includes('EXCEL.EXE')) {
                console.log("⚠️ Excel is open. Closing it...");
                exec('taskkill /F /IM EXCEL.EXE', (error) => {
                    if (!error) console.log("✅ Excel closed successfully.");
                    setTimeout(resolve, 2000); // Wait 2 sec before proceeding
                });
            } else {
                resolve();
            }
        });
    });
}

async function saveToExcel(subject, body, retries = 5, delay = 2000) {
    let attempt = 0;

    async function trySaving() {
        try {
            await closeExcelIfOpen(); // Ensure Excel is closed before writing

            let workbook;
            let worksheet;
            let sheetName = "Emails";

            if (fs.existsSync(EXCEL_FILE)) {
                workbook = xlsx.readFile(EXCEL_FILE);
                worksheet = workbook.Sheets[sheetName] || xlsx.utils.aoa_to_sheet([["Subject", "Body"]]);
            } else {
                workbook = xlsx.utils.book_new();
                worksheet = xlsx.utils.aoa_to_sheet([["Subject", "Body"]]);
                xlsx.utils.book_append_sheet(workbook, worksheet, sheetName);
            }

            let data = xlsx.utils.sheet_to_json(worksheet, { header: 1 });

            data.push([subject, body]); // Append new data

            workbook.Sheets[sheetName] = xlsx.utils.aoa_to_sheet(data);
            xlsx.writeFile(workbook, EXCEL_FILE);

            console.log("📂 Data successfully saved to Excel.");
        } catch (error) {
            if (error.code === "EBUSY" && attempt < retries) {
                console.log(`⚠️ File locked, retrying in ${delay / 1000}s... (Attempt ${attempt + 1}/${retries})`);
                attempt++;
                setTimeout(trySaving, delay);
            } else {
                console.error("❌ Failed to save to Excel:", error);
            }
        }
    }

    await trySaving();
}

// Run the function
fetchGeneratedEmail();
