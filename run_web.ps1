# Chạy Flutter Web với cấu hình Firebase (firebase.env)
# Cách dùng: trong thư mục project, chạy: .\run_web.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path "firebase.env")) {
    Write-Host ""
    Write-Host "Chua co file firebase.env trong thu muc project." -ForegroundColor Yellow
    Write-Host "1) Copy firebase.env.example -> firebase.env"
    Write-Host "2) Mo firebase.env va dien DAY DU gia tri tu Firebase Console (Project settings)"
    Write-Host "3) Chay lai: .\run_web.ps1"
    Write-Host ""
    if (Test-Path "firebase.env.example") {
        Copy-Item "firebase.env.example" "firebase.env"
        Write-Host "Da tao firebase.env tu mau. Hay dien gia tri roi chay lai script." -ForegroundColor Green
    }
    exit 1
}

flutter run -d chrome --dart-define-from-file=firebase.env
