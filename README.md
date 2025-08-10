# Pai Nam Nae - A Safe Ride Sharing App

A safe ride-sharing application with a **Nuxt.js** frontend and **Express.js** backend, powered by **Prisma** ORM and **PostgreSQL**.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Security & Rate Limiting](#security--rate-limiting)
- [Installation](#installation)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [API Endpoints](#api-endpoints)
- [Contact](#contact)

## Features

- User registration with multi-step identity verification
- JWT authentication
- Role-based access control (PASSENGER / DRIVER / ADMIN)
- Vehicle management (CRUD, set default)
- User profile management
- Admin capabilities for user management (list, update status, delete)
- Image uploads for verification handled via **Cloudinary**
- Input validation via **Zod**
- API documentation with Swagger UI
- Health-check & Metrics endpoints (`/health`, `/metrics`)

## Tech Stack

- **Frontend:** Nuxt.js
- **Backend:** Express.js
- **ORM:** Prisma
- **Database:** PostgreSQL
- **Authentication:** JSON Web Tokens (JWT)
- **Image Storage:** Cloudinary
- **Validation:** Zod
- **API Docs:** Swagger (Swagger UI Express, Swagger JSDoc)

## Prerequisites

- Node.js v16+
- npm or yarn
- PostgreSQL instance
- Cloudinary Account (for API Key, Secret, and Cloud Name)

<!-- ## Security & Rate Limiting

- **Rate Limiting:** 100 requests per 15 minutes per IP (returns 429 Too Many Requests when exceeded)
- **Security Headers:** Helmet is used to set various security-related HTTP headers -->

## Installation

1.  **Clone the repository**

    ```bash
    git clone https://github.com/Pai-Nam-Nae-A-Safe-Ride-Sharing/PaiNamNaeWebApp.git
    cd PaiNamNaeWebApp
    ```

2.  **Install backend dependencies**

    ```bash
    cd backend
    npm install
    ```

3.  **Install frontend dependencies**

    ```bash
    cd ../frontend
    npm install
    ```

## Environment Variables

Create a `.env` file in the `backend` directory with the following:

```ini
# Server
PORT=3000

# Database
DATABASE_URL="postgresql://<user>:<password>@<host>:<port>/<database>?schema=public"

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key

# Cloudinary Credentials
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

## Database Setup

1.  **Navigate to the backend directory**
    ```bash
    cd backend
    ```
2.  **Generate Prisma Client**
    ```bash
    npx prisma generate
    ```
3.  **Run migrations**
    ```bash
    npx prisma migrate dev --name init
    ```

## Running the Application

1.  **Start the backend**
    ```bash
    cd backend
    npm run dev # starts Express server on http://localhost:3000
    ```
2.  **Start the frontend**
    ```bash
    cd frontend
    npm run dev # starts Nuxt.js on http://localhost:3001
    ```

## API Endpoints

Visit [**http://localhost:3000/documentation**](http://localhost:3000/documentation) for interactive Swagger UI and full API reference.

### Authentication

- `POST /api/auth/login` – Login with email/username & password
- `PUT /api/auth/change-password` – Change current user's password

### Users

- `POST /api/users` – Register a new user with identity verification photos
- `GET /api/users/admin` – List all active users (Admin only)
- `GET /api/users/{id}` – Get user by ID
- `PUT /api/users/me` – Update current user's profile
- `PUT /api/users/admin/users/{id}` – Update user by ID (Admin only)
- `DELETE /api/users/admin/{id}` – Delete user by ID (Admin only)
- `PATCH /api/users/admin/{id}/status` – Set user's active status (Admin only)

### Vehicles (Authenticated users)

- `GET /api/vehicles` – List all vehicles for the current user
- `GET /api/vehicles/{id}` – Get vehicle by ID
- `POST /api/vehicles` – Create a new vehicle
- `PUT /api/vehicles/{id}` – Update a vehicle
- `DELETE /api/vehicles/{id}` – Delete a vehicle
- `PUT /api/vehicles/{id}/default` – Set a vehicle as the default

### Driver Verifications

- `GET /api/driver-verifications/me` – View your own verification record  
- `POST /api/driver-verifications` – Submit a new driver verification (upload license)  
- `PUT /api/driver-verifications/{id}` – Update your verification details
- `GET /api/driver-verifications` – List all verifications (Admin only)  
- `GET /api/driver-verifications/{id}` – Get a specific verification record (Admin only)  
- `PATCH /api/driver-verifications/{id}/status` – Approve or reject a driver verification (Admin only)

### Routes

- `GET /api/routes` – List all routes (public)  
- `GET /api/routes/{id}` – Get route by ID (public)
- `GET /api/routes/me` - List all routes created by the current logged-in driver (Driver only)
- `POST /api/routes` – Create a new route (Driver only, must be pending/approved)  
- `PUT /api/routes/{id}` – Update your route (Driver only)  
- `DELETE /api/routes/{id}` – Delete your route (Driver only)

### Bookings

- `GET /api/bookings/me` - List all bookings made by the current user (Passenger only)
- `GET /api/bookings/{id}` - Get a booking by its ID (Related Passenger or Driver only)
- `POST /api/bookings` - Create a new booking for a route (Passenger only)
- `PATCH /api/bookings/{id}/status` - Update a booking's status, e.g., confirm/reject (Driver only)
- `PATCH /api/bookings/{id}/cancel` - Cancel a booking (Passenger only)
- `DELETE /api/bookings/{id}` - Delete a cancelled/rejected booking (Related Passenger or Driver only)

### Health-check & Metrics

- `GET /health` – Check application & database health (200 OK or 503)
- `GET /metrics` – Expose Prometheus-compatible metrics (CPU, memory, HTTP latency, request counts, etc.)
- `GET /documentation` - Access the Swagger UI API documentation page

## Contact

For questions or feedback, reach out to:

**Email:** [jonathandoillon2002@gmail.com](mailto\:jonathandoillon2002@gmail.com)
**Email:** [seth.s@kkumail.com](mailto\:seth.s@kkumail.com)