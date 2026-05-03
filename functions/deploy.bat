@echo off
echo 🚀 Let's Crease Firebase Deployment Script
echo ==========================================

echo.
echo 📦 Installing dependencies...
call npm install

echo.
echo 🔑 Checking for Firebase service account key...
if not exist "lets-crease-firebase-adminsdk.json" (
    echo ❌ Service account key not found!
    echo 📝 Please download your Firebase service account key and place it as:
    echo    lets-crease-firebase-adminsdk.json
    echo 🔗 Download from: https://console.firebase.google.com/project/lets-crease/settings/serviceaccounts/adminsdk
    pause
    exit /b 1
)

echo ✅ Service account key found!

echo.
echo 🌱 Seeding Firestore database...
call node comprehensive_seed.js

if %ERRORLEVEL% EQU 0 (
    echo.
    echo 🎉 Database seeding completed successfully!
    echo 🔗 Check your Firebase console: https://console.firebase.google.com/project/lets-crease/firestore
    echo.
    echo 📋 Collections created:
    echo    ✅ blog_posts - Artist profiles and educational content
    echo    ✅ origami_models - Model database with PDF integration
    echo    ✅ app_settings - Feature flags and configuration
    echo    ✅ achievements - Gamification system
    echo    ✅ user_activities - Comprehensive activity tracking
    echo    ✅ categories - Model categories
    echo    ✅ users - Sample user for testing
    echo.
    echo 🎯 Your Let's Crease app database is ready!
) else (
    echo ❌ Database seeding failed!
    echo Please check the error messages above.
)

echo.
pause
