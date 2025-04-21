# MetaBundle Infrastructure Services

This directory contains shared infrastructure services that support the MetaBundle ecosystem. Unlike the projects in the `../projects` directory, these services are primarily focused on infrastructure rather than application logic.

## Directory Structure

Each subdirectory represents a separate infrastructure service:

```
services/
├── nginx/                # Web server and Cloudflare Tunnel configurations
└── [future services]     # Additional services can be added here
```

## Service Management

Infrastructure services are managed through the Docker Compose configuration in the root directory. They provide essential capabilities that are used by multiple projects.

## Current Services

### nginx
- **Description**: Web server and Cloudflare Tunnel configurations
- **Repository**: https://github.com/MetaBundleAutomation/nginx-config
- **Purpose**: Provides reverse proxy capabilities, SSL termination, and integration with Cloudflare for secure external access to MetaBundle services
