# Apt Update and Upgrade Script

This repository contains CLI tools focused on:
- **Document inspection** (e.g., special character detection in `.docx` files)
- **System maintenance** (e.g., automated APT package updates on Debian Ubuntu-based systems)

Each tool is self-contained, operationally efficient, and built for future expansion.

## Prerequisites

- Python 3.x
- `sudo` privileges for running `apt` commands
- pip (Python package manager)

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