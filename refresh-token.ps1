# Client ID for the vscode copilot
$client_id = "01ab8ac9400c4e429b23"

# Parameters for HTTP requests
$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
}

# Request the device code
Write-Host "Requesting device code from GitHub..."
$response = Invoke-RestMethod -Uri "https://github.com/login/device/code" -Method Post -Headers $headers -Body "client_id=$client_id&scope=user:email"

# Extract the device_code and user_code
$device_code = $response.device_code
$user_code = $response.user_code

# Check if we got the codes
if (-not $device_code -or -not $user_code) {
    Write-Host "Error: Could not get device code or user code from GitHub." -ForegroundColor Red
    exit 1
}

# Print instructions for the user
Write-Host "Please open https://github.com/login/device/ and enter the following code:" -ForegroundColor Green
Write-Host $user_code -ForegroundColor Cyan
Write-Host "Press Enter once you have authorized the application..."
$null = Read-Host

# Get the access token
Write-Host "Requesting access token from GitHub..."
try {
    $response_access_token = Invoke-RestMethod -Uri "https://github.com/login/oauth/access_token" -Method Post -Headers $headers -Body "client_id=$client_id&scope=user:email&device_code=$device_code&grant_type=urn:ietf:params:oauth:grant-type:device_code"
    $access_token = $response_access_token.access_token
    
    if (-not $access_token) {
        Write-Host "Error: Could not get access token from GitHub." -ForegroundColor Red
        exit 1
    }

    # Print the access token
    Write-Host "Your access token is: $access_token" -ForegroundColor Green

    # Create .env file with all needed variables
    $env_content = @"
# Required settings
REFRESH_TOKEN=$access_token

# Request settings
MAX_TOKENS=10240
TIMEOUT_SECONDS=300
EDITOR_VERSION=vscode/1.97.2
MIN_DELAY_SECONDS=5.0
MAX_DELAY_SECONDS=60.0

# Debug settings
RECORD_TRAFFIC=false
LOGURU_LEVEL=INFO
"@

    # Write content to .env file
    $env_content | Out-File -FilePath ".env" -Encoding utf8

    Write-Host "Created .env file with all configuration settings." -ForegroundColor Green
    Write-Host "Run the app with the following command:" -ForegroundColor Yellow
    Write-Host "poetry run uvicorn copilot_more.server:app --port 15432" -ForegroundColor Cyan
}
catch {
    Write-Host "Error: Failed to get access token: $_" -ForegroundColor Red
    exit 1
}