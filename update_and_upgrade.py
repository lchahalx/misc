#!/bin/python3
import subprocess

def run_command(command):
    try:
        # Running the command
        result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        print(f"Output:\n{result.stdout}")
    except subprocess.CalledProcessError as e:
        # Handling errors
        print(f"Error:\n{e.stderr}")

def update_and_upgrade():
    # Update the package list
    print("Running apt update...")
    #calls function run command with sudo
    run_command(["sudo", "apt", "update"])
    
    # Upgrade the installed packages
    print("Running apt upgrade...")
    run_command(["sudo", "apt", "upgrade", "-y"])

if __name__ == "__main__":
    update_and_upgrade()
