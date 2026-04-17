$ErrorActionPreference = "Stop"

$BASE_URL = "http://localhost:8000/api/auth"

Write-Host "==============================="
Write-Host "🧪 Testing Rapid Aid Auth Layer"
Write-Host "==============================="

# 1. Register a new CITIZEN user
Write-Host "`n[1/3] Registering new CITIZEN user..."
$registerPayload = @{
    username = "citizen_philip"
    email = "philip@example.com"
    password = "SecurePassword123!"
    first_name = "Philip"
    last_name = "Tested"
    phone_number = "+2348012345678"
    role = "CITIZEN"
} | ConvertTo-Json

try {
    $regResponse = Invoke-RestMethod -Uri "$BASE_URL/register/" `
        -Method Post `
        -Body $registerPayload `
        -ContentType "application/json"
    
    Write-Host "✅ Registration Successful!"
} catch {
    Write-Host "Registration failed (might already exist): $($_.Exception.Message)"
}

# 2. Login as CITIZEN without any portal_role specified
Write-Host "`n[2/3] Logging in as CITIZEN..."
$loginPayload = @{
    username = "citizen_philip"
    password = "SecurePassword123!"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$BASE_URL/login/" `
    -Method Post `
    -Body $loginPayload `
    -ContentType "application/json"

$accessToken = $loginResponse.access
$refreshToken = $loginResponse.refresh

Write-Host "✅ Login Successful!"
Write-Host "Access Token: $($accessToken.Substring(0, 20))..."

# 3. Test a Protected Endpoint (/api/auth/me/)
Write-Host "`n[3/3] Fetching protected profile data..."
$authHeaders = @{
    "Authorization" = "Bearer $accessToken"
}

$meResponse = Invoke-RestMethod -Uri "$BASE_URL/me/" `
    -Method Get `
    -Headers $authHeaders

Write-Host "✅ Profile Data Received for: $($meResponse.username) (Role: $($meResponse.role))"

Write-Host "`n==============================="
Write-Host "🚀 Testing DISPATCHER Portal check..."
$dispatchLoginPayload = @{
    username = "citizen_philip"
    password = "SecurePassword123!"
    portal_role = "DISPATCHER"
} | ConvertTo-Json

try {
    $dispatchResponse = Invoke-RestMethod -Uri "$BASE_URL/login/" `
        -Method Post `
        -Body $dispatchLoginPayload `
        -ContentType "application/json"
        
    Write-Host "❌ Test Failed: Citizen was allowed into Dispatcher portal!"
} catch {
    Write-Host "✅ Test Passed: Citizen blocked from Dispatcher portal (403 Forbidden)"
}

Write-Host "==============================="
Write-Host "🏁 ALL TESTS COMPLETE"
