import requests
import json
import subprocess
import time
import webbrowser

# GitHub OAuth2 configuration
# it's fine for this to be in Git: client IDs are considered public knowledge
client_id = "Ov23liiIswnnMPlpXMFL"
device_code_url = "https://github.com/login/device/code"
access_token_url = "https://github.com/login/oauth/access_token"
scope = "repo,read:user,read:packages,workflow"

host = "github.com"

def credentials_exist():
    input = f"host={host}"
    p = subprocess.run(["git-credential-osxkeychain", "get"], 
        capture_output = True,
        timeout = 10,
        encoding = "utf-8",
        input = input + "\n\n"
        )
    return p.returncode == 0 and len(p.stdout) > 0


def request_verification():
    params = {
        "client_id": client_id,
        "scope": scope,
    }
    return requests.post(device_code_url, 
        data=params, 
        headers = {'Accept': 'application/json'}).json()

def validate_in_browser(verification_data):
    # Automatically open the browser
    verification_url = verification_data['verification_uri']
    user_code = verification_data['user_code']
    print(f"Your browser should open automatically. If not, please go to {verification_url} and enter the code: {user_code}")
    webbrowser.open(f"{verification_url}?user_code={user_code}")
    

def check_for_auth_token(device_code):
    params = {
            "client_id": client_id,
            "device_code": device_code,
            "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
        }
    access_token_response = requests.post(access_token_url, 
        data=params, 
        headers = {'Accept': 'application/json'})
    return access_token_response.json()

def fill_credentials(access_token_data):
    input = f"""protocol=https
host={host}
username=robharrop
password={access_token_data["access_token"]}
"""

    p = subprocess.run(["git", "credential", "approve"], 
        capture_output = True,
        timeout = 10,
        encoding = "utf-8",
        input = input + "\n\n"
        )
    return p.returncode == 0

# Initialize OAuth2 client
def auth():

    verification_data = request_verification()    
    validate_in_browser(verification_data)
    
    # Now poll for the access token
    poll_interval = verification_data.get("interval", 5)
    device_code = verification_data["device_code"]

    while True:
        access_token_data = check_for_auth_token(device_code)

        if "access_token" in access_token_data:
            print("Access token obtained successfully!")
            fill_credentials(access_token_data)
            break
        elif "error" in access_token_data and access_token_data["error"] == "authorization_pending":
            time.sleep(poll_interval)
        else:
            print(f"Error: {access_token_data.get('error_description', 'Unknown error')}")
            break

if  __name__ == "__main__":
    if credentials_exist():
        print("Already authenticated with github.com")
    else:
        auth()