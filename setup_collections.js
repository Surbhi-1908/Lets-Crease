const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('./path/to/your/serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function createCollections() {
  console.log('Creating Firestore collections...');

  // Sample documents for each collection
  const collections = [
    {
      name: 'users',
      doc: {
        uid: 'sample_user',
        email: 'sample@example.com',
        displayName: 'Sample User',
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      }
    },
    {
      name: 'quiz_results',
      doc: {
        userId: 'sample_user',
        category: 'Artists',
        skillLevel: 'Beginner',
        score: 8,
        totalQuestions: 10,
        completedAt: admin.firestore.FieldValue.serverTimestamp()
      }
    },
    {
      name: 'quizzes',
      doc: {
        question: 'Who is considered the father of modern origami?',
        options: ['Akira Yoshizawa', 'Robert Lang', 'John Montroll', 'Lang Mu'],
        correctAnswerIndex: 0,
        category: 'Artists',
        skillLevel: 'Beginner',
        explanation: 'Akira Yoshizawa revolutionized origami with wet-folding techniques.'
      }
    },
    {
      name: 'blog_posts',
      doc: {
        title: 'Getting Started with Origami',
        content: 'Learn the basics of paper folding...',
        authorId: 'sample_user',
        published: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      }
    },
    {
      name: 'blog_comments',
      doc: {
        postId: 'sample_post',
        userId: 'sample_user',
        content: 'Great tutorial!',
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      }
    },
    {
      name: 'user_profiles',
      doc: {
        userId: 'sample_user',
        displayName: 'Sample User',
        bio: 'Origami enthusiast',
        joinedAt: admin.firestore.FieldValue.serverTimestamp()
      }
    },
    {
      name: 'origami_models',
      doc: {
        title: 'Paper Crane Tutorial',
        category: 'Traditional Origami',
        difficulty: 'Beginner',
        createdBy: 'sample_user',
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      }
    },
    {
      name: 'user_favorites',
      doc: {
        userId: 'sample_user',
        favorites: { models: [], blogPosts: [] },
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }
    },
    {
      name: 'user_progress',
      doc: {
        userId: 'sample_user',
        skillLevels: { Artists: 'Beginner' },
        totalPoints: 0,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }
    },
    {
      name: 'notifications',
      doc: {
        userId: 'sample_user',
        type: 'welcome',
        title: 'Welcome!',
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      }
    },
    {
      name: 'app_config',
      doc: {
        version: '1.0.0',
        categories: ['Artists', 'Papers', 'Folding Techniques', 'Traditional Origami'],
        skillLevels: ['Beginner', 'Moderate', 'Intermediate'],
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }
    }
  ];

  // Create collections with sample documents
  for (const collection of collections) {
    try {
      await db.collection(collection.name).doc('sample').set(collection.doc);
      console.log(`✅ Created collection: ${collection.name}`);
    } catch (error) {
      console.error(`❌ Error creating ${collection.name}:`, error);
    }
  }

  console.log('🎉 All collections created successfully!');
  process.exit(0);
}

createCollections().catch(console.error);
