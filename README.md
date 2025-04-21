# MetaBundle Server Infrastructure

This repository serves as the infrastructure hub for all MetaBundle services and applications. It provides global configurations, shared services, and orchestration for the entire MetaBundle ecosystem.

**Repository**: [https://github.com/MetaBundleAutomation/MetaBundle-Server](https://github.com/MetaBundleAutomation/MetaBundle-Server)

## System Architecture

The MetaBundle system is organized into two main categories:

### Project Repositories
All application repositories are organized in the `./projects` directory as Git submodules:

| Repository | Description | Location | Repository URL |
|------------|-------------|----------|---------------|
| Bloomberg-Terminal | Bloomberg data integration and terminal interface | [./projects/Bloomberg-Terminal](./projects/Bloomberg-Terminal) | https://github.com/MetaBundleAutomation/Bloomberg-Terminal |
| Dashboard | Frontend UI for monitoring and control | [./projects/Dashboard](./projects/Dashboard) | https://github.com/MetaBundleAutomation/Dashboard |
| DataProcessor | Data processing and transformation pipeline | [./projects/DataProcessor](./projects/DataProcessor) | https://github.com/MetaBundleAutomation/Data-Processor |
| Scraper | Web scraping and data collection services | [./projects/Scraper](./projects/Scraper) | https://github.com/MetaBundleAutomation/Scraper-Setup |

### Infrastructure Services
Shared infrastructure services are organized in the `./services` directory:

| Service | Description | Location | 
|---------|-------------|----------|
| celery | Background task processing (worker and beat) using Redis as the broker | [./services/celery](./services/celery) |
| nginx | Web server and Cloudflare Tunnel configurations | [./services/nginx](./services/nginx) |

## Getting Started

### Quick Start

1. Clone this repository with its submodules:
   ```bash
   git clone --recurse-submodules https://github.com/MetaBundleAutomation/MetaBundle-Server.git
   cd MetaBundle-Server
   ```
   
   Alternatively, you can clone first and then initialize submodules:
   ```bash
   git clone https://github.com/MetaBundleAutomation/MetaBundle-Server.git
   cd MetaBundle-Server
   git submodule init
   git submodule update
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
| `repo` | Manage repositories | `.\metabundle-cli.ps1 repo add --all` |
| `env` | Manage environment variables | `.\metabundle-cli.ps1 env edit` |
| `update` | Update all components | `.\metabundle-cli.ps1 update` |
| `help` | Show help information | `.\metabundle-cli.ps1 help` |

For a complete list of commands and options, run `.\metabundle-cli.ps1 help`.

### Git Submodule Management

The `manage-repos.ps1` script handles the Git submodules for project and service repositories:

```powershell
# List repositories
.\manage-repos.ps1 -Action list

# Add repositories as submodules
.\manage-repos.ps1 -Action add -All

# Initialize submodules
.\manage-repos.ps1 -Action init

# Update submodules
.\manage-repos.ps1 -Action update -RepoName Dashboard

# Remove a submodule
.\manage-repos.ps1 -Action remove -RepoName nginx
```

## Repository Management

MetaBundle Server uses Git submodules to manage project repositories. This provides a modular structure while maintaining clear relationships between components.

### Adding Repositories

To add a project repository as a submodule:

```powershell
# Using the CLI tool
./metabundle-cli.ps1 repo add <repository-name>

# Or directly
./manage-repos.ps1 -Action add -RepoName <repository-name>
```

### Updating Repositories

To update repositories to specific versions:

```powershell
# Update a specific repository
./metabundle-cli.ps1 repo update <repository-name>

# Auto-update all repositories to their latest versions
./metabundle-cli.ps1 repo auto-update
```

The auto-update command will:
1. Pull the latest changes for each submodule from their default branches
2. Stage and commit these updates in the root repository
3. Optionally push the changes to GitHub

## Global Infrastructure

This repository provides the following global services:

- **Redis**: Message broker and cache for distributed services.
- **Celery**: Background task processing (worker and beat for scheduled tasks) using Redis as the broker.
- **Flower**: Web UI for monitoring Celery tasks (http://localhost:5555).
- **Nginx**: Reverse proxy and static file serving.

### Using Celery

- **Celery code is located at:** `services/celery/`
- **Add tasks to:** `services/celery/tasks.py`
- **Dependencies:** `services/celery/requirements.txt`

#### Build and Start All Services
```sh
docker-compose up --build
```

#### Monitor Tasks
- Visit [http://localhost:5555](http://localhost:5555) for the Flower dashboard.

#### Example: Add a Celery Task
Edit `services/celery/tasks.py`:
```python
@app.task
def my_task():
    print("Hello from Celery!")
```

#### Call a Task from Python (inside container or with Redis running)
```python
from tasks import add
result = add.delay(2, 3)
print(result.get())  # Should print 5
```

## Services

The `services/` directory contains core infrastructure components required by the MetaBundle Server. These are **not** submodules or standalone repositories—they are part of this main repository and provide supporting services for the overall system.

### Directory Structure (Services)

```
services/
├── celery/        # Celery worker & beat for background task processing
│   └── shared-tasks/  # Shared directory for Celery task files
├── nginx/         # Nginx reverse proxy configuration
└── ...            # (Other core service folders)
```

- **celery/**: Contains the Celery worker/beat code, Dockerfile, and shared-tasks mount for distributed task processing.
- **nginx/**: Contains configuration for the Nginx reverse proxy.
- Other folders may be added for additional infrastructure services.

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
