# Laporin Backend API

Backend service for Laporin - an infrastructure damage reporting application.

## Overview

This backend provides RESTful API endpoints for the Laporin application, handling user reports of infrastructure damage, admin verification, and agency management.

## Technologies Used

- Node.js
- Express.js
- MySQL
- Sequelize ORM
- JWT Authentication
- bcrypt

## Prerequisites

- Node.js
- MySQL Server
- npm or yarn

## Installation

1. Clone the repository

   ```bash
   git clone <repository-url>
   cd laporin_app/backend
   ```

2. Install dependencies

   ```bash
   npm install
   ```

3. Configure environment variables
   Create a `.env` file in the root directory with the following variables:

   ```
   # Database Configuration
   DB_NAME=laporin_db
   DB_USERNAME=your_username
   DB_PASSWORD=your_password
   DB_HOST=localhost

   # JWT Secret Keys
   ACCESS_TOKEN_SECRET=your_access_token_secret
   REFRESH_TOKEN_SECRET=your_refresh_token_secret

   # Client URL (for CORS)
   CLIENT_URL=

   # Server Configuration
   PORT=5000

   # Bucket Google Cloud Platform
   PROJECT_ID =
   KEY_FILE_NAME = ''
   BUCKET_NAME =
   ```

4. Create database

   ```sql
   CREATE DATABASE laporin_db;
   ```

5. Run the server

   ```bash
   # Development mode
   npm run dev

   # Production mode
   npm start
   ```

## API Endpoints

### Health Check

- `GET /` - API health check

### Documentation

- `GET /docs` - API documentation page

### Public Endpoints (Guest/Reporter)

#### Reports

- `GET /public/reports` - Get all public reports with basic filtering
- `GET /public/reports/:id` - View details of a specific report
- `GET /public/reports/category/:categoryId` - Get reports by category
- `GET /public/reports/status/:status` - Get reports by status (pending, verified, in_progress, resolved, rejected)
- `POST /public/reports` - Submit a new infrastructure damage report (with file upload)
  - Content-Type: `multipart/form-data`
  - Body: `{ title, description, category_id, reporter_name, reporter_contact, location, agency_id?, image (file), lampiran (file, optional) }`
- `GET /public/reports/track/:trackingId` - Track report status using tracking ID
- `GET /public/statistics` - Get report statistics (count per category/status)

#### Categories

- `GET /public/categories` - Get all available report categories

#### Agencies

- `GET /public/agencies` - Get list of government agencies

### Admin Endpoints (Protected)

All admin endpoints require authentication token in header: `Authorization: Bearer <token>`

#### Authentication

- `POST /admin/register` - Register new admin
  - Body: `{ username, password, name, email }`
- `POST /admin/login` - Admin login
  - Body: `{ username, password }`
  - Returns: `{ accessToken, refreshToken }`
- `POST /admin/logout` - Admin logout
- `GET /admin/token` - Refresh access token using refresh token

#### Profile Management

- `GET /admin/profile` - Get admin profile
- `PATCH /admin/profile` - Update admin profile

#### Report Management

- `GET /admin/reports` - Get all reports with admin access
- `GET /admin/reports/:id` - Get detailed report information
- `POST /admin/reports` - Create new report (admin)
- `PATCH /admin/reports/:id` - Update report details
- `DELETE /admin/reports/:id` - Delete a report
- `GET /admin/reports/:id/history` - Get complete history of a report
- `PATCH /admin/reports/:id/verify` - Verify a pending report
  - Body: `{ note? }`
- `PATCH /admin/reports/:id/assign` - Assign report to an agency
  - Body: `{ agency_id, note? }`
- `PATCH /admin/reports/:id/resolve` - Mark report as resolved
  - Body: `{ note? }`
- `PATCH /admin/reports/:id/reject` - Reject a report
  - Body: `{ note }`

#### Category Management

- `GET /admin/categories` - Get all categories
- `POST /admin/categories` - Create new category
  - Body: `{ name, description }`
- `PATCH /admin/categories/:id` - Update category
  - Body: `{ name, description }`
- `DELETE /admin/categories/:id` - Delete category

#### Agency Management

- `GET /admin/agencies` - Get all agencies
- `POST /admin/agencies` - Create new agency
  - Body: `{ name, division, contact, service_area }`
- `PATCH /admin/agencies/:id` - Update agency
  - Body: `{ name, division, contact, service_area, is_active }`
- `DELETE /admin/agencies/:id` - Delete agency

#### Admin User Management

- `GET /admin/users` - Get all admin users
- `DELETE /admin/users/:id` - Delete admin user

## Report Status Values

- `pending` - New report, waiting for verification
- `verified` - Report has been verified by admin
- `in_progress` - Report is being handled by agency
- `resolved` - Report has been resolved
- `rejected` - Report has been rejected

## File Upload

- Supported formats: JPG, JPEG, PNG (images), PDF, DOC, DOCX (attachments)
- Maximum size: 5MB per file
- Image evidence is required
- Additional attachments are optional

## Database Models

### Admin

Admin user accounts for management and moderation.

### Report

Infrastructure damage reports submitted by users.

### ReportCategory

Categories for classifying types of infrastructure damage.

### ReportHistory

Tracking status changes and updates for each report.

### GovernmentAgency

Government agencies responsible for resolving reported issues.

## Development

### Scripts

- `npm start` - Start the server
- `npm run dev` - Start the server with nodemon for development

## License

This project is licensed under the ISC License.
