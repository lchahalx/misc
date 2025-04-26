# CLI tools

This repository contains CLI tools focused on:
- **Document inspection** (e.g., special character detection in `.docx` files)
- **System maintenance** (e.g., automated APT package updates on Debian Ubuntu-based systems)
- **Environment setup automation** (e.g., repairing AWS CLI installation and accessibility issues)

Each tool is self-contained, operationally efficient, and built for future expansion.

## Prerequisites

- Python 3.x
- `sudo` privileges for running `apt` commands
- pip (Python package manager)
- pipx (for isolated Python CLI tool management)

## Setup Instructions 

1. Clone the repository:

    ```bash
    git clone git@github.com:lchahalx/misc.git
    cd misc
    ```

2. (Optional) Create and activate a virtual environment:

    ```bash
    python3 -m venv venv
    #Linux/macOS
    source venv/bin/activate
    #Windows
    .\venv\Scripts\activate
    ```

3. Install any required dependencies (if any):

    ```bash
    pip install python-docx
    ```
4. (Optional but Recommended) Repair AWS CLI Installation and Environment (for Linux Systems):

    A script is provided to fully automate fixing the awscli environment if you are facing issues due to snap confinement, missing $PATH, or PEP 668 protections.

    Execute the provided script:

    ```bash
    chmod +x fix_awscli_environment.sh
    ./fix_awscli_environment.sh
    
   ```
   Script Description:

    Installs pipx if not already installed.

    Ensures pipx binary paths are correctly added to your environment.

    Installs awscli using pipx in an isolated manner.

    Validates that the aws binary is available and operational.
## Usage

To run the script, simply execute:

```bash
python update_upgrade.py
python inspect_chars.py yourfile.docx
# Example output
Special characters found: {'@', '#', '$', '%'}
```
## Deactivating the Virtual Environment
```bash
deactivate
```
