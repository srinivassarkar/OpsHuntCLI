# 🎯 OpsHunt AI — Serverless DevOps Daily Job Digest

A serverless, automated DevOps & SRE job scraper and email digest tool. It runs entirely for free in the cloud using **GitHub Actions**, meaning you do not need to host it on a personal server or keep a local machine running.

The tool aggregates DevOps and SRE job postings daily from 11 different sources, performs smart keyword-based pre-filtering to minimize AI quota usage, scores the most relevant jobs using Google's Gemini AI, compiles them into a custom-designed Excel spreadsheet, logs them to Google Sheets, and sends a formatted HTML digest directly to your inbox.

---

## 🌟 Core Features

- **11 Scraped Feeds**: Aggregates openings from Remotive, Jobicy, We Work Remotely, Otta, Arbeitnow, Naukri, Instahyre, LinkedIn, Indeed, ZipRecruiter, RemoteOK, Hacker News Jobs (`hnrss.org/jobs`), and Reddit (`r/devops` and `r/sre`).
- **Serverless Execution**: Runs entirely in the cloud via GitHub Actions schedules. No servers, cron-daemons, or local terminals required.
- **Smart Pre-Filtering**: Analyzes jobs locally before calling Gemini to reduce daily API token usage by 70-85%.
- **Experience-Level Downranking**: Automatically flags and downranks senior, staff, lead, principal, manager, and junior roles that mismatch the candidate's target experience level (both in Gemini and the local fallback engine).
- **Dynamic Gemini AI Scoring**: Matches and ranks jobs (0-100) based on your custom skills, target experience, preferred locations, and target companies (using the modern `google-genai` SDK with a robust local fallback engine).
- **Early Exit on Zero Matches**: If no jobs meet your minimum score threshold on a given day, the script updates the seen database and exits cleanly, avoiding sending spam/empty emails.
- **Premium Navy & Gold Styling**: Delivers a styled HTML email digest alongside an automated, color-coded Excel spreadsheet.
- **Google Sheets Integration**: Automatically appends scored jobs directly to an online Google Sheet for tracking.
- **Seen Jobs Memory**: Persists previously sent jobs back to Git to ensure you never receive duplicate emails.

---

## ☁️ 1. Serverless Setup on GitHub (Recommended)

GitHub Actions' native scheduler (`on.schedule`) is prone to unpredictable queue delays (often executing 30 to 90 minutes late). To guarantee that your Daily Job Digest runs **exactly on time**, we trigger the workflow externally using a free cloud cron service (**Cron-Job.org**) hitting GitHub's API.

---

### Phase A: GitHub Repository Setup

1. **Add Repository Secrets**:
   Go to your GitHub repository -> **Settings** -> **Secrets and variables** -> **Actions** -> **New repository secret** and add:
   - **`CONFIG_JSON`**: Paste the entire content of your `config.json` file. Get your Gemini API key from [Google AI Studio](https://aistudio.google.com/).
   - **`SERVICE_ACCOUNT_JSON`** (Optional): Paste the entire JSON content of your `service_account.json` if using Google Sheets integration. Otherwise, leave this secret blank.

2. **Configure Workflow Permissions**:
   To allow the workflow to commit and push changes back to `seen_jobs.json` (to prevent duplicate emails):
   - Go to **Settings** -> **Actions** -> **General** -> scroll down to **Workflow permissions**.
   - Select **Read and write permissions** and click **Save**.

---

### Phase B: Generate GitHub Personal Access Token (PAT)

An API token is required to allow the external scheduler to trigger the workflow.

1. Go to GitHub **Settings** -> **Developer Settings** -> **Personal Access Tokens** -> **Fine-grained tokens** -> **Generate new token**.
2. Set the following:
   - **Token name**: `OpsHunt Cron Trigger`
   - **Repository access**: Select **Only select repositories** -> choose `srinivassarkar/OpsHuntCLI`.
   - **Permissions**: Under **Repository permissions**, find **Actions** and set it to **Read and write**. (Leave everything else at default/no-access).
3. Click **Generate token** and copy the generated token immediately.

---

### Phase C: Setup Cron-Job.org for On-Time Execution

1. Register or log in at [Cron-Job.org](https://cron-job.org).
2. Go to **Cronjobs** -> **Create cronjob** and fill in:
   - **Title**: `OpsHunt Daily Digest Trigger`
   - **Address (URL)**: `https://api.github.com/repos/srinivassarkar/OpsHuntCLI/actions/workflows/daily_digest.yml/dispatches`
   - **Request Method**: `POST`
   - **Request Body**: `{"ref": "main"}` (Choose `application/json` or enter raw JSON)
   - **Time Zone**: Select `Asia/Kolkata (IST)`
   - **Schedule**:
     - Mon-Fri at **11:30 AM**
     - Sat at **10:00 AM**
   - **Authentication**: Leave Username and Password blank (unticked).
3. Under **Headers**, click "Add header" and add these 5 keys:
   * **`Authorization`**  →  `Bearer <YOUR_PAT_TOKEN>` (Make sure to include `Bearer ` before your token)
   * **`Accept`**  →  `application/vnd.github+json`
   * **`X-GitHub-Api-Version`**  →  `2022-11-28`
   * **`User-Agent`**  →  `Cron-Job-Scheduler`
   * **`Content-Type`**  →  `application/json`
4. Click **Create** and run a **Test Run** to verify! The workflow will run immediately.

---

## 🛠️ 2. Local Setup & Development (Optional)

If you want to run the script locally for debugging or customization:

### Prerequisites
Ensure you have **Python 3.9+** installed:
```bash
python3 --version
```

### Installation
1. Install the required dependencies:
   ```bash
   pip3 install -r requirements.txt
   ```
2. Run the script manually:
   ```bash
   python3 digest.py
   ```

---

## 📋 Configuration Format (`config.json`)

Configure your search parameters, credentials, and email settings using the following JSON structure. Store this in `config.json` (do not commit this file to public repositories; it is ignored by git to protect your secrets):

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
    "max_job_age_days": 7,
    "min_score_to_email": 65,
    "top_n_in_email": 7
  }
}
```
