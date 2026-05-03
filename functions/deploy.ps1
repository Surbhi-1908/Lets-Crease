Write-Host "🚀 Let's Crease Firebase Deployment Script" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

Write-Host ""
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
npm install

Write-Host ""
Write-Host "🔑 Checking for Firebase service account key..." -ForegroundColor Yellow
if (-not (Test-Path "lets-crease-firebase-adminsdk.json")) {
    Write-Host "❌ Service account key not found!" -ForegroundColor Red
    Write-Host "📝 Please download your Firebase service account key and place it as:" -ForegroundColor White
    Write-Host "   lets-crease-firebase-adminsdk.json" -ForegroundColor Cyan
    Write-Host "🔗 Download from: https://console.firebase.google.com/project/lets-crease/settings/serviceaccounts/adminsdk" -ForegroundColor Blue
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Service account key found!" -ForegroundColor Green

Write-Host ""
Write-Host "🌱 Seeding Firestore database..." -ForegroundColor Yellow
node comprehensive_seed.js

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🎉 Database seeding completed successfully!" -ForegroundColor Green
    Write-Host "🔗 Check your Firebase console: https://console.firebase.google.com/project/lets-crease/firestore" -ForegroundColor Blue
    Write-Host ""
    Write-Host "📋 Collections created:" -ForegroundColor White
    Write-Host "   ✅ blog_posts - Artist profiles and educational content" -ForegroundColor Green
    Write-Host "   ✅ origami_models - Model database with PDF integration" -ForegroundColor Green
    Write-Host "   ✅ app_settings - Feature flags and configuration" -ForegroundColor Green
    Write-Host "   ✅ achievements - Gamification system" -ForegroundColor Green
    Write-Host "   ✅ user_activities - Comprehensive activity tracking" -ForegroundColor Green
    Write-Host "   ✅ categories - Model categories" -ForegroundColor Green
    Write-Host "   ✅ users - Sample user for testing" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 Your Let's Crease app database is ready!" -ForegroundColor Magenta
} else {
    Write-Host "❌ Database seeding failed!" -ForegroundColor Red
    Write-Host "Please check the error messages above." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
