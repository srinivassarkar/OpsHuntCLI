# 🎯 OpsHunt AI — DevOps Daily Job Digest Tool

A lightweight, automated command-line utility designed for macOS terminals. It aggregates DevOps/SRE job postings daily from 7 different sources, ranks them against your profile using Google's Gemini AI, compiles them into a custom-designed Excel spreadsheet, logs them in Google Sheets, and emails you a formatted HTML digest.

---

## 🌟 Core Features

- **11 Scraped Feeds**: Remotive, Jobicy, We Work Remotely RSS, Otta, Arbeitnow, Naukri, Instahyre, LinkedIn, Indeed, ZipRecruiter, RemoteOK, Hacker News, and Reddit.
- **Smart Pre-Filtering**: Performs local keyword scans before calling Gemini to reduce API token usage by 70%.
- **Anti-Bot Resiliency**: Set up with emulated browser headers, 10s timeouts, and automatic retries to bypass simple bot blocks.
- **Dynamic Gemini AI Scoring**: Evaluates and ranks jobs (0-100) based on your custom skills, experience (3 years), preferred locations, and downranks (with a local fallback engine).
- **Premium Color Theme**: Styled HTML email body and matching formatted Excel spreadsheets (Deep Navy & Gold scheme).
- **Google Sheets Integration**: Automatically appends scored jobs directly to your online Google Sheet.
- **Auto-Installer**: Simple shell script to install optimal weekday and Saturday schedules on macOS.

---

## 🛠️ Installation & Setup

### 1. Prerequisites
Ensure you have **Python 3.9+** installed on your macOS system. Verify in your terminal:
```bash
python3 --version
```

### 2. Install Dependencies
Open your Terminal, navigate to the `ops_hunt_python_digest` folder, and install the libraries:
```bash
pip3 install -r requirements.txt
```

### 3. Configure Credentials (`config.json`)
Open `config.json` in a text editor to configure your keys:
- **Gemini API Key**: Add your Google Gemini API key in the `"gemini_api_key"` field.
- **Gmail App Password**: Enter your email address and a 16-character [Gmail App Password](https://myaccount.google.com/security) (requires 2-Step Verification to be turned ON in your Google Account security settings).
- **Google Sheet ID** (Optional): Add your Google Sheet ID under `"sheet_id"` and drop your service account credentials file in this folder named `service_account.json`.

### 4. Configuration Skeleton (`config.json`)
Create a `config.json` file in the root directory with the following structure:

```json
{
  "gemini_api_key": "YOUR_GEMINI_API_KEY",
  "google_sheets": {
    "service_account_json": "service_account.json",
    "sheet_id": "YOUR_GOOGLE_SHEET_ID"
  },
  "email": {
    "smtp_server": "smtp.gmail.com",
    "smtp_port": 587,
    "sender_email": "sender@gmail.com",
    "sender_password": "YOUR_GMAIL_APP_PASSWORD",
    "receiver_email": "receiver@gmail.com"
  },
  "candidate_profile": {
    "title": "DevOps Engineer",
    "experience_years": 3,
    "skills": [
      "Kubernetes",
      "Terraform",
      "Docker",
      "Python"
    ],
    "preferred_roles": [
      "DevOps Engineer",
      "SRE",
      "Platform Engineer"
    ],
    "preferred_locations": ["Hyderabad", "Bangalore", "Remote"],
    "strong_match_keywords": [
      "Kubernetes",
      "Terraform",
      "SRE"
    ],
    "downrank_keywords": [
      "WordPress",
      "PHP"
    ],
    "target_companies": [
      "Apple",
      "PayPal"
    ]
  },
  "scraper": {
    "max_job_age_days": 7
  }
}
```

---

## 🚀 How to Run

### Run Manually
To execute a scrape, score, compile, and email run immediately, run:
```bash
python3 digest.py
```

### Run Automatically (macOS Scheduler)
To automate the script to run daily (Mon-Fri at **11:30 AM** and Sat at **10:00 AM**):
1. Make the setup script executable:
   ```bash
   chmod +x setup_cron.sh
   ```
2. Run it:
   ```bash
   ./setup_cron.sh
   ```

> [!IMPORTANT]
> **macOS Disk Access Permissions**:
> Starting with macOS Mojave, macOS blocks `cron` from accessing folders by default. To allow the scheduler to run:
> 1. Go to **System Settings** -> **Privacy & Security** -> **Full Disk Access**.
> 2. Click the `+` button.
> 3. Press `Cmd + Shift + G`, type `/usr/sbin/cron`, and select **cron**.
> 4. Ensure the toggle for **cron** is enabled.
