# Rapid Aid 🚨 - Development Environment & Dependency Manifest

Welcome to **Rapid Aid**! This document maps out our core infrastructure and provides a step-by-step guide to setting up your local development environment for Sprint 1 and beyond.

## 📦 Initial Dependency Mapping

To ensure a smooth, "It Just Works" experience across the team, ensure you have the exact (or highly compatible) versions installed:

### 1. Software
- **Python:** `3.12+` (Required for Django 5 and spatial libraries).
- **Flutter SDK:** `3.x` (Dart 3 required for modern null safety).
- **Redis:** `7.x` (Required locally for Django Channels / WebSockets).

### 2. External Binaries (GeoDjango Constraints)
We use PostGIS. On Windows, this requires the **GDAL** and **GEOS** C-libraries.
- **The "GDAL Fix":** We have bypassed the need for a full OSGeo4W installation on Windows. Instead, the `shapely` and `fiona` Python packages are installed via pip. These wheels locally bundle the required spatial DLLs, and our Django `settings.py` auto-detects them cleanly.

### 3. Database (Supabase / PostgreSQL)
We use a shared, cloud-hosted Supabase instance to ensure schema consistency.
- **PostgreSQL Version:** 16
- **Extensions required:** `postgis` (3.4+)
- **Connection Rule:** The connection string MUST require SSL (`sslmode=require`) to securely connect to Supabase.

---

## 🚀 Quick Start Configuration

Follow these instructions strictly to get your local environment running:

### Step 1: Clone the Repo
```bash
git clone <repository_url> rapid_aid
cd rapid_aid
```

### Step 2: GDAL/GEOS Setup (Windows Only)
Thanks to our "GDAL Fix", you do *not* need to manually install OSGeo4W. The spatial libraries are bundled when you install the Python requirements in Step 3!

### Step 3: Setup Python Backend
```bash
cd backend
python -m venv .venv
# Activate virtual environment
.venv\Scripts\activate  # Windows
# Or: source .venv/bin/activate # Mac/Linux

pip install -r requirements.txt
```

### Step 4: Configure Environment Variables
Copy `.env.example` to `.env` in the `backend/` directory:
```bash
cp .env.example .env
```
Ensure your database parameters in `.env` match our Supabase credentials to connect directly to the shared Supabase instance:
```env
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=your_secure_password
DB_HOST=db.lxrzahnfcmgeanrcistc.supabase.co
DB_PORT=5432
DATABASE_URL=postgresql://postgres:your_secure_password@db.lxrzahnfcmgeanrcistc.supabase.co:5432/postgres
```

> **Spatial Check:** If your initial `migrate` ever fails due to missing PostGIS functions, remind yourself to run `CREATE EXTENSION IF NOT EXISTS postgis;` directly in the Supabase SQL editor.

### Step 5: Start Redis & Django
Make sure you have Redis running in the background. Then start Daphne:
```bash
python manage.py runserver
```

---

## 🛠 Maintenance Plan

This manifest is a living document. We are implementing a strict **"Infrastructure as Code & Documentation"** policy.
- **When adding new core tech:** (e.g., Celery for task queues, Google Maps SDK for Flutter), the developer responsible for the PR MUST update this file.
- **Dependency Version Bumps:** Minor bumps don't require an update here, but major version changes (e.g., upgrading to Flutter 4.x or Python 3.13) should be documented.
- **Bi-Weekly Review:** During our Sprint Retrospective, the DevOps Lead will quickly verify if this manifest still accurately reflects our production and local reality.
