# MetaBundle Projects Directory

This directory contains all the project repositories that make up the MetaBundle ecosystem. Each project is a separate repository with its own git history and purpose within the larger system.

## Directory Structure

```
projects/
├── Bloomberg-Terminal/   # Bloomberg data integration and terminal interface
├── Dashboard/           # Frontend UI for monitoring and control
├── DataProcessor/       # Data processing and transformation pipeline 
├── Scraper/             # Web scraping and data collection services
└── Infrastructure/      # Core infrastructure components
```

## Project Repositories

| Repository | Description | Repository URL |
|------------|-------------|----------------|
| Bloomberg-Terminal | Bloomberg data integration and terminal interface | https://github.com/MetaBundleAutomation/Bloomberg-Terminal |
| Dashboard | Frontend UI for monitoring and control | https://github.com/MetaBundleAutomation/Dashboard |
| DataProcessor | Data processing and transformation pipeline | https://github.com/MetaBundleAutomation/Data-Processor |
| Scraper | Web scraping and data collection services | https://github.com/MetaBundleAutomation/Scraper-Setup |

## Repository Management

All repositories in this directory are managed through the root-level `manage-repos.ps1` script. This allows for consistent management of cloning, updating, and status checking across all projects.

## Integration

These projects are designed to work together within the MetaBundle ecosystem, communicating through shared services defined in the `../services` directory and configured via environment variables.

Each project directory should contain a `REPOSITORY.md` file that describes its purpose, architecture, and relationships to other components in the MetaBundle ecosystem.
