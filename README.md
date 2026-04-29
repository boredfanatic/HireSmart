# HireSmart - Automated Skill-Based Recruitment Platform

A web-based recruitment management system that automates candidate-job matching through CV parsing, keyword extraction, and weighted skill-based scoring algorithms.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)

---

## Overview

HireSmart streamlines the recruitment process by automatically matching candidates with job openings based on their skills. The system parses uploaded resumes, extracts skills using keyword matching, and calculates compatibility scores using a weighted algorithm that considers both skill proficiency and job requirement importance.

### Key Capabilities
- **CV Processing**: Extract skills from resumes using Python-based keyword matching
- **Intelligent Matching**: Calculate candidate-job compatibility using weighted scoring
- **Dual Portal System**: Separate interfaces for candidates and employers
- **Real-time Rankings**: Automatically rank candidates for each job posting
- **Interview Management**: Schedule and track interviews with status automation

---

## Features

### For Candidates
- **Profile Creation**: Register and create detailed candidate profiles
- **CV Parsing**: Process resumes using a Python-based parser for skill extraction
- **Job Search**: Browse available job openings with detailed descriptions
- **Match Insights**: View compatibility scores for each job application
- **Application Tracking**: Monitor application status (pending, shortlisted, rejected, interview scheduled)
- **Interview Tracking**: Manage interview stages and status updates

### For Employers
- **Company Profiles**: Create and manage employer accounts
- **Job Posting**: Create job listings with required skills and importance weights
- **Candidate Discovery**: View ranked candidates based on match scores
- **Smart Filtering**: Access pre-filtered, qualified candidates automatically
- **Interview Management**: Schedule interviews and track candidate pipeline
- **Analytics**: View application statistics and hiring metrics

### System Features
- **Secure Authentication**: Role-based access control (candidate/employer)
- **Automated Workflows**: Database triggers for status updates and score calculations
- **Advanced Reporting**: Complex SQL queries for insights and analytics
- **Transaction Safety**: ACID-compliant operations for data integrity
- **Responsive Design**: Mobile-friendly Bootstrap interface

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Database** | MySQL 8.0+ | Data storage, stored procedures, triggers |
| **Backend** | PHP 7.4+ | RESTful API endpoints, business logic |
| **Frontend** | HTML5, CSS3, JavaScript | User interface, Bootstrap 5 for styling |
| **CV Parser** | Python 3.x | Resume parsing, skill extraction |
| **Tools** | XAMPP, MySQL Workbench, VS Code | Development environment |

### Python Libraries
- **PyPDF2** / **pdfplumber**: PDF text extraction
- **python-docx**: Word document parsing (optional)
- **re** (built-in): Regular expressions for pattern matching

---

## Notes

- CV parsing is handled using a Python script that is triggered via a PHP endpoint when a CV is uploaded.
- The parser extracts skills and inserts them into the database for matching.
- This project is designed to run locally using XAMPP (Apache + MySQL).

---

## How to Run the Project

1. Install XAMPP
2. Start Apache and MySQL

3. Copy project folder to:
   C:\xampp\htdocs\

4. Open phpMyAdmin:
   http://localhost/phpmyadmin

5. Create database: hiresmart

6. Import:
   database/schema.sql
   database/sample_data.sql

7. Open in browser:
   http://localhost/HireSmart/

**HireSmart** - Smart Hiring, Simplified 
