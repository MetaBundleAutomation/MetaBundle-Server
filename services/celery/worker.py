import sys
import os
import glob
import importlib.util

# Add Scraper project to PYTHONPATH
sys.path.append("/app/projects/Scraper")

# Add shared-tasks directory to sys.path for dynamic task discovery
shared_tasks_path = os.path.join(os.path.dirname(__file__), 'shared-tasks')
if os.path.exists(shared_tasks_path):
    sys.path.append(shared_tasks_path)

# Dynamically import all .py files in shared-tasks as modules
task_files = glob.glob(os.path.join(shared_tasks_path, '*.py'))
for task_file in task_files:
    module_name = os.path.splitext(os.path.basename(task_file))[0]
    if module_name == "__init__":
        continue
    spec = importlib.util.spec_from_file_location(module_name, task_file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

# Optionally: print loaded modules for debug
print(f"Loaded shared Celery task modules: {[os.path.basename(f) for f in task_files]}")

from tasks import app as scraper_app  # This imports all tasks from Scraper

# Optionally, you could add more task imports here from other projects
