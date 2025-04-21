# MetaBundle Server Infrastructure

This repository serves as the infrastructure hub for all MetaBundle services and applications. It provides global configurations, shared services, and orchestration for the entire MetaBundle ecosystem.

**Repository**: [https://github.com/MetaBundleAutomation/MetaBundle-Server](https://github.com/MetaBundleAutomation/MetaBundle-Server)

## System Architecture

The MetaBundle system is organized into two main categories:

### Project Repositories
All application repositories are organized in the `./projects` directory:

| Repository | Description | Location | Repository URL |
|------------|-------------|----------|---------------|
| Bloomberg-Terminal | Bloomberg data integration and terminal interface | [./projects/Bloomberg-Terminal](./projects/Bloomberg-Terminal) | https://github.com/MetaBundleAutomation/Bloomberg-Terminal |
| Dashboard | Frontend UI for monitoring and control | [./projects/Dashboard](./projects/Dashboard) | https://github.com/MetaBundleAutomation/Dashboard |
| DataProcessor | Data processing and transformation pipeline | [./projects/DataProcessor](./projects/DataProcessor) | https://github.com/MetaBundleAutomation/Data-Processor |
| Scraper | Web scraping and data collection services | [./projects/Scraper](./projects/Scraper) | https://github.com/MetaBundleAutomation/Scraper-Setup |

### Infrastructure Services
Shared infrastructure services are organized in the `./services` directory:

| Service | Description | Location | Repository URL |
|---------|-------------|----------|---------------|
| nginx | Web server and Cloudflare Tunnel configurations | [./services/nginx](./services/nginx) | https://github.com/MetaBundleAutomation/nginx-config |

## Getting Started

### Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/MetaBundleAutomation/MetaBundle-Server.git
   cd MetaBundle-Server
   ```

2. Use the MetaBundle CLI tool for setup:
   ```powershell
   .\metabundle-cli.ps1 setup all
   ```

3. Start all services:
   ```powershell
   .\metabundle-cli.ps1 start all
   ```

4. Check service status:
   ```powershell
   .\metabundle-cli.ps1 status services
   ```

### MetaBundle CLI Tool

The `metabundle-cli.ps1` script provides a streamlined interface for managing the entire MetaBundle environment:

| Command | Description | Example |
|---------|-------------|---------|
| `setup` | Configure environment and dependencies | `.\metabundle-cli.ps1 setup all` |
| `start` | Start services | `.\metabundle-cli.ps1 start all` |
| `stop` | Stop services | `.\metabundle-cli.ps1 stop all` |
| `status` | Check service status | `.\metabundle-cli.ps1 status services` |
| `repo` | Manage repositories | `.\metabundle-cli.ps1 repo clone --all` |
| `env` | Manage environment variables | `.\metabundle-cli.ps1 env edit` |
| `update` | Update all components | `.\metabundle-cli.ps1 update` |
| `help` | Show help information | `.\metabundle-cli.ps1 help` |

For a complete list of commands and options, run `.\metabundle-cli.ps1 help`.

### Repository Management

The `manage-repos.ps1` script provides direct management of project and service repositories:

```powershell
# List repositories
.\manage-repos.ps1 -Action list

# Clone repositories
.\manage-repos.ps1 -Action clone -All

# Update repositories
.\manage-repos.ps1 -Action update -RepoName Dashboard
```

## Global Infrastructure

This repository provides the following global services:

- **Redis**: Shared caching and message queue (port 6379)
- **Celery Worker**: Background task processing
- **Celery Beat**: Scheduled task management
- **Flower**: Celery monitoring interface (port 5555)

## Scraper Architecture

The scraping system consists of:

1. **Scraper-Manager**: FastAPI backend that receives frontend requests and spins up new scraper instances
   - Exposes `/spawn` endpoint to launch new scraper containers
   - Communicates with Docker to manage containers

2. **Scraper-Instance**: Lightweight container that runs scrape tasks
   - Simulates a scraping job
   - Returns status messages and results

3. **Scraper-Dashboard**: React + TypeScript frontend
   - Provides "Spawn Scraper" button to trigger backend
   - Displays container messages and logs

## Development Workflow

1. **Local Development**: Use the CLI tool to start services and manage repositories
   ```powershell
   .\metabundle-cli.ps1 start all
   ```

2. **Updating Environment**: Edit environment variables as needed
   ```powershell
   .\metabundle-cli.ps1 env edit
   ```

3. **Adding New Services**: Update the `docker-compose.yml` file to add new services

## Troubleshooting

- **Port Conflicts**: Check for port availability
  ```powershell
  .\metabundle-cli.ps1 status ports
  ```

- **Service Issues**: Check service status
  ```powershell
  .\metabundle-cli.ps1 status services
  ```
