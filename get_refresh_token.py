#!/usr/bin/env python3
import os
import platform
import subprocess
import sys
from pathlib import Path


def get_script_dir():
    """Get the directory where the current script is located."""
    return Path(__file__).parent.absolute()


def main():
    """Detect OS and run the appropriate refresh token script."""
    print("\n=== GitHub Copilot Refresh Token Generator ===\n")
    
    script_dir = get_script_dir()
    os_name = platform.system().lower()
    
    # Determine which script to run based on OS
    if os_name == "windows":
        script_path = script_dir / "refresh-token.ps1"
        print(f"Detected Windows OS. Using PowerShell script: {script_path}\n")
        
        try:
            # Execute PowerShell script
            result = subprocess.run(
                ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(script_path)],
                check=True
            )
            if result.returncode != 0:
                print(f"Error: PowerShell script exited with code {result.returncode}")
                sys.exit(1)
        except FileNotFoundError:
            print("Error: PowerShell is not installed or not in the system PATH.")
            sys.exit(1)
        except subprocess.SubprocessError as e:
            print(f"Error executing PowerShell script: {e}")
            sys.exit(1)
    
    elif os_name in ("linux", "darwin"):  # Linux or macOS
        script_path = script_dir / "refresh-token.sh"
        os_name_str = "Linux" if os_name == "linux" else "macOS"
        print(f"Detected {os_name_str} OS. Using Bash script: {script_path}\n")
        
        try:
            # Ensure the script is executable
            os.chmod(script_path, 0o755)
            
            # Execute Bash script
            result = subprocess.run([str(script_path)], check=True)
            if result.returncode != 0:
                print(f"Error: Bash script exited with code {result.returncode}")
                sys.exit(1)
        except FileNotFoundError:
            print("Error: Bash is not installed or script not found.")
            sys.exit(1)
        except subprocess.SubprocessError as e:
            print(f"Error executing Bash script: {e}")
            sys.exit(1)
        except PermissionError:
            print(f"Error: Could not set execute permission on {script_path}.")
            print("Try running: chmod +x refresh-token.sh")
            sys.exit(1)
    
    else:
        print(f"Error: Unsupported operating system: {os_name}")
        print("This tool supports Windows, Linux, and macOS only.")
        sys.exit(1)


if __name__ == "__main__":
    main()