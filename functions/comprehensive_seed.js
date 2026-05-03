const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin with your service account
// Replace this path with your actual service account key file
const serviceAccountPath = './lets-crease-firebase-adminsdk.json';

// Check if service account file exists
if (!fs.existsSync(serviceAccountPath)) {
  console.error('❌ Service account key file not found!');
  console.log('📝 Please download your Firebase service account key and place it at:');
  console.log(`   ${path.resolve(serviceAccountPath)}`);
  console.log('🔗 Download from: https://console.firebase.google.com/project/lets-crease/settings/serviceaccounts/adminsdk');
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

initializeApp({
  credential: cert(serviceAccount),
  projectId: 'lets-crease' // Your Firebase project ID from the console
});

const db = getFirestore();

async function seedLetsCreaseDatabase() {
  console.log('🚀 Starting Let\'s Crease Comprehensive Database Seeding...\n');

  try {
    // Load all data files
    console.log('📖 Loading comprehensive origami app data...');
    
    const blogPosts = JSON.parse(fs.readFileSync('./firebase_data/blog_posts.json', 'utf8'));
    const origamiModels = JSON.parse(fs.readFileSync('./firebase_data/origami_models.json', 'utf8'));
    const appSettings = JSON.parse(fs.readFileSync('./firebase_data/app_settings.json', 'utf8'));
    const achievements = JSON.parse(fs.readFileSync('./firebase_data/achievements.json', 'utf8'));
    
    console.log(`📊 Total data to seed:`);
    console.log(`   • Blog posts: ${Object.keys(blogPosts).length}`);
    console.log(`   • Origami models: ${Object.keys(origamiModels.animals).length + Object.keys(origamiModels.fictional).length}`);
    console.log(`   • App settings: ${Object.keys(appSettings.app_settings).length} categories`);
    console.log(`   • Achievements: ${Object.keys(achievements.achievements).length}`);

    // Seed Blog Posts
    console.log('\n🔄 Seeding blog posts...');
    const blogBatch = db.batch();
    Object.entries(blogPosts).forEach(([docId, data]) => {
      const docRef = db.collection('blog_posts').doc(docId);
      const processedData = { ...data };
      processedData.publishedAt = Timestamp.fromDate(new Date(data.publishedAt));
      processedData.createdAt = Timestamp.now();
      blogBatch.set(docRef, processedData);
      console.log(`✅ Prepared blog: ${data.title}`);
    });
    await blogBatch.commit();
    console.log(`✅ Successfully seeded ${Object.keys(blogPosts).length} blog posts`);

    // Seed Origami Models
    console.log('\n🔄 Seeding origami models...');
    const modelsBatch = db.batch();
    
    // Seed Animals category
    Object.entries(origamiModels.animals).forEach(([docId, data]) => {
      const docRef = db.collection('origami_models').doc(`animals_${docId}`);
      const processedData = { ...data };
      processedData.createdAt = Timestamp.fromDate(new Date(data.createdAt));
      processedData.updatedAt = Timestamp.now();
      modelsBatch.set(docRef, processedData);
      console.log(`✅ Prepared animal model: ${data.name}`);
    });

    // Seed Fictional category
    Object.entries(origamiModels.fictional).forEach(([docId, data]) => {
      const docRef = db.collection('origami_models').doc(`fictional_${docId}`);
      const processedData = { ...data };
      processedData.createdAt = Timestamp.fromDate(new Date(data.createdAt));
      processedData.updatedAt = Timestamp.now();
      modelsBatch.set(docRef, processedData);
      console.log(`✅ Prepared fictional model: ${data.name}`);
    });

    await modelsBatch.commit();
    const totalModels = Object.keys(origamiModels.animals).length + Object.keys(origamiModels.fictional).length;
    console.log(`✅ Successfully seeded ${totalModels} origami models`);

    // Seed App Settings
    console.log('\n🔄 Seeding app settings...');
    const settingsBatch = db.batch();
    Object.entries(appSettings.app_settings).forEach(([settingKey, settingData]) => {
      const docRef = db.collection('app_settings').doc(settingKey);
      const processedData = { ...settingData };
      processedData.updatedAt = Timestamp.now();
      settingsBatch.set(docRef, processedData);
      console.log(`✅ Prepared setting: ${settingKey}`);
    });
    await settingsBatch.commit();
    console.log(`✅ Successfully seeded ${Object.keys(appSettings.app_settings).length} app settings`);

    // Seed Achievements
    console.log('\n🔄 Seeding achievements...');
    const achievementsBatch = db.batch();
    Object.entries(achievements.achievements).forEach(([achievementId, data]) => {
      const docRef = db.collection('achievements').doc(achievementId);
      const processedData = { ...data };
      processedData.createdAt = Timestamp.now();
      achievementsBatch.set(docRef, processedData);
      console.log(`✅ Prepared achievement: ${data.title}`);
    });
    await achievementsBatch.commit();
    console.log(`✅ Successfully seeded ${Object.keys(achievements.achievements).length} achievements`);

    // Create User Activity Collection Structure
    console.log('\n🔄 Setting up user activity tracking structure...');
    const activityDocRef = db.collection('user_activities').doc('_structure');
    await activityDocRef.set({
      description: 'This collection tracks comprehensive user activity across the Let\'s Crease app',
      trackingTypes: [
        'session_tracking',
        'model_interactions', 
        'quiz_activities',
        'navigation_tracking',
        'feature_usage',
        'error_tracking'
      ],
      createdAt: Timestamp.now(),
      isActive: true
    });
    console.log('✅ User activity tracking structure created');

    // Create Categories Collection
    console.log('\n🔄 Setting up origami categories...');
    const categoriesBatch = db.batch();
    const categories = [
      {
        id: 'animals',
        name: 'Animals',
        description: 'Realistic animal models from simple to complex',
        icon: '🐾',
        modelCount: Object.keys(origamiModels.animals).length,
        isActive: true
      },
      {
        id: 'birds',
        name: 'Birds',
        description: 'Flying creatures and avian models',
        icon: '🦅',
        modelCount: 0,
        isActive: true
      },
      {
        id: 'kusudamas',
        name: 'Kusudamas',
        description: 'Decorative ball-shaped modular origami',
        icon: '🌸',
        modelCount: 0,
        isActive: true
      },
      {
        id: 'tessellations',
        name: 'Tessellations',
        description: 'Geometric patterns that tile perfectly',
        icon: '🔷',
        modelCount: 0,
        isActive: true
      },
      {
        id: 'modular',
        name: 'Modular',
        description: 'Models made from multiple identical units',
        icon: '🧩',
        modelCount: 0,
        isActive: true
      },
      {
        id: 'fictional',
        name: 'Fictional',
        description: 'Fantasy characters and mythical beings',
        icon: '🎭',
        modelCount: Object.keys(origamiModels.fictional).length,
        isActive: true
      }
    ];

    categories.forEach(category => {
      const docRef = db.collection('categories').doc(category.id);
      const processedData = { ...category };
      processedData.createdAt = Timestamp.now();
      processedData.updatedAt = Timestamp.now();
      categoriesBatch.set(docRef, processedData);
      console.log(`✅ Prepared category: ${category.name} (${category.modelCount} models)`);
    });
    await categoriesBatch.commit();
    console.log(`✅ Successfully seeded ${categories.length} categories`);

    // Create Sample User for Testing
    console.log('\n🔄 Creating sample user for testing...');
    const sampleUserRef = db.collection('users').doc('sample_user_123');
    await sampleUserRef.set({
      uid: 'sample_user_123',
      email: 'test@letscrease.com',
      username: 'OrigamiMaster',
      skillLevel: 'Intermediate',
      foldingHistory: ['fictional_butterfly', 'animals_spider'],
      quizScores: {
        'Artists_Beginner': 8,
        'Papers_Moderate': 7,
        'Folding Techniques_Intermediate': 9
      },
      achievements: ['first_fold', 'quiz_master'],
      totalPoints: 85,
      modelsCompleted: 12,
      averageQuizScore: 8.0,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      lastActiveAt: Timestamp.now(),
      preferences: {
        notifications: true,
        darkMode: false,
        autoPlay: true,
        language: 'en'
      }
    });
    console.log('✅ Sample user created for testing');

    // Summary
    console.log('\n🎉 Let\'s Crease Database Seeding Completed Successfully!');
    console.log('🔗 Check your Firebase console: https://console.firebase.google.com/project/lets-crease/firestore');
    
    console.log('\n📋 Collections Created:');
    console.log('   ✅ blog_posts - Artist profiles and educational content');
    console.log('   ✅ origami_models - Detailed model information with PDFs');
    console.log('   ✅ app_settings - Feature flags and configuration');
    console.log('   ✅ achievements - Gamification and user rewards');
    console.log('   ✅ user_activities - Comprehensive activity tracking');
    console.log('   ✅ categories - Origami model categories');
    console.log('   ✅ users - User profiles and progress tracking');

    console.log('\n🎯 Ready Features:');
    console.log('   • Comprehensive user activity tracking across all app features');
    console.log('   • Blog posts about famous origami artists and techniques');
    console.log('   • Detailed origami model database with PDF integration');
    console.log('   • Achievement system for user engagement');
    console.log('   • Configurable app settings and feature flags');
    console.log('   • Category-based model organization');

    console.log('\n💡 User Activity Tracking Includes:');
    console.log('   • Session duration and screen navigation');
    console.log('   • Model interaction and completion tracking');
    console.log('   • Quiz performance and timing analytics');
    console.log('   • Feature usage patterns and preferences');
    console.log('   • Error tracking and crash reporting');
    console.log('   • Social sharing and engagement metrics');

    console.log('\n🛡️ Next Steps:');
    console.log('   1. Update your Flutter app to use these Firestore collections');
    console.log('   2. Implement user activity tracking in your app code');
    console.log('   3. Test the quiz and blog functionality');
    console.log('   4. Configure Firebase security rules for production');

  } catch (error) {
    console.error('❌ Error during seeding:', error);
    process.exit(1);
  }
}

// Run the seeding
seedLetsCreaseDatabase();
