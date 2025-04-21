# MetaBundle Server: Project Metadata & Environment Reference

This file provides a centralized reference for environment variables, API/port usage, and best practices for all projects in the MetaBundle Server ecosystem. All projects and infrastructure services should reference this file for standardized configuration and integration.

---

## How to Use
- **For Developers:** Reference this document when adding new environment variables, APIs, or ports. Document any new integration points here.
- **For Automation/CI/CD:** Use the `PROJECT_METADATA` environment variable (set in `.env`) to programmatically locate and parse this file for configuration or documentation purposes.
- **For Each Project:** The project's own README should reference this file for environment variable documentation and infrastructure integration notes.

---

## Environment Variables

| Variable Name        | Description                                      | Example Value            | Used By                |
|---------------------|--------------------------------------------------|-------------------------|------------------------|
| SHARED_TASKS        | Path to shared Celery tasks directory             | ./services/celery/shared-tasks | Celery worker/beat     |
| REDIS_HOST          | Hostname for Redis broker                         | redis                   | Celery, Scraper, etc.  |
| REDIS_PORT          | Redis port                                        | 6379                    | Celery, Scraper        |
| CELERY_BROKER_URL   | Celery broker connection string                   | redis://redis:6379/0    | Celery                 |
| SCRAPER_API_PORT    | Port for Scraper-Manager FastAPI backend          | 8081                    | Scraper-Manager        |
| ...                 | ...                                              | ...                     | ...                    |

*Add new variables as needed. Always update this table when introducing or deprecating environment variables!*

---

## API & Port Usage
- **Scraper-Manager API:** Runs on `${SCRAPER_API_PORT}` (default: 8081)
- **Redis:** Accessible at `${REDIS_HOST}:${REDIS_PORT}` (default: redis:6379)
- **Celery:** Uses `${CELERY_BROKER_URL}` for broker communication
- **Other Services:** Add additional API endpoints and port usages here as your infrastructure grows

---

## Best Practices
- **Never hardcode sensitive values or connection strings in code.** Always use environment variables and document them here.
- **When adding new services or APIs,** update this file and reference it in the new project's README.
- **Use the `PROJECT_METADATA` env variable** to programmatically locate this file from any project or automation tool.

---

## Example: Referencing This File in a Project README

```markdown
## Environment Variables & Integration

For all required environment variables and integration points, see [../PROJECT_METADATA.md](../PROJECT_METADATA.md) in the root of the repository. This file documents:
- All global and service-specific environment variables
- API endpoints and port assignments
- Best practices for configuration and integration
```

---

## Change Log
- 2025-04-22: Initial creation of centralized metadata file for MetaBundle Server
