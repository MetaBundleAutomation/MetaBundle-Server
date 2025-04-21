# MetaBundle Infrastructure Services

This directory contains shared infrastructure services that support the MetaBundle ecosystem. Unlike the projects in the `../projects` directory, these services are part of the main repository and focus on infrastructure rather than application logic. **They are not submodules or standalone repositories.**

## Directory Structure

Each subdirectory represents a separate infrastructure service:

```
services/
├── celery/                # Celery worker and beat for distributed background task processing
│   └── shared-tasks/      # Shared directory for Celery task files (mounted by automation)
├── nginx/                 # Web server and Cloudflare Tunnel configurations
└── [future services]      # Additional services can be added here
```

## Service Management

Infrastructure services are managed through the Docker Compose configuration in the root directory. They provide essential capabilities that are used by multiple projects.

## Current Services

### celery
- **Description**: Celery worker and beat for distributed background task processing using Redis as the broker
- **Purpose**: Handles asynchronous and scheduled tasks for the MetaBundle ecosystem. Task files are dynamically imported from the `shared-tasks/` directory, which is populated by automation or CLI scripts.

### nginx
- **Description**: Web server and Cloudflare Tunnel configurations
- **Purpose**: Provides reverse proxy capabilities, SSL termination, and integration with Cloudflare for secure external access to MetaBundle services

---

For more details on adding or updating services, see the root README or consult the Docker Compose configuration.
