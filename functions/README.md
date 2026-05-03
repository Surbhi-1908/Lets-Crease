# Let's Crease - Firebase Database Seeding

This directory contains the Firebase Functions and database seeding scripts for the Let's Crease origami app.

## 🚀 Quick Setup

### 1. Install Dependencies
```bash
cd functions
npm install
```

### 2. Download Firebase Service Account Key
1. Go to [Firebase Console](https://console.firebase.google.com/project/lets-crease/settings/serviceaccounts/adminsdk)
2. Click "Generate new private key"
3. Save the file as `lets-crease-firebase-adminsdk.json` in the `functions/` directory

### 3. Update Project Configuration
Edit `comprehensive_seed.js` and update:
```javascript
// Replace with your actual project ID
projectId: 'lets-crease'
```

### 4. Run Database Seeding
```bash
npm run seed
```

## 📊 What Gets Seeded

### Collections Created:
- **`blog_posts`** - Artist profiles and educational content (6 posts)
- **`origami_models`** - Detailed model information with PDF paths (8 models)
- **`app_settings`** - Feature flags and app configuration
- **`achievements`** - Gamification system (8 achievements)
- **`user_activities`** - Activity tracking structure
- **`categories`** - Model categories (6 categories)
- **`users`** - Sample user for testing

### User Activity Tracking
The system tracks comprehensive user activity including:
- **Session Tracking**: Duration, screen views, device info
- **Model Interactions**: Which models viewed, completion status, time spent
- **Quiz Activities**: Scores, timing, question-by-question analysis
- **Navigation Tracking**: Screen transitions and user flow
- **Feature Usage**: Which features are used most
- **Error Tracking**: Crashes and error reporting

## 🔧 Available Scripts

```bash
# Seed the database
npm run seed

# Deploy Firebase Functions
npm run deploy

# Start local emulator
npm run serve

# View function logs
npm run logs
```

## 📁 Data Structure

### Blog Posts
- Artist profiles (Akira Yoshizawa, Robert Lang, etc.)
- Educational content about origami techniques
- Paper types and materials guide

### Origami Models
- **Animals**: Spider, Brachiosaurus
- **Fictional**: Butterfly, Buddhist Monk, Ganesha, Lao-Tseu, Lighthouse, Magic Tower
- Each model includes: difficulty, time estimate, PDF path, step count

### User Activity Schema
```javascript
{
  userId: "string",
  sessionId: "string", 
  action: "string",
  timestamp: "timestamp",
  metadata: "object",
  // ... specific fields per activity type
}
```

## 🛡️ Security Rules

The Firestore security rules are configured to:
- Allow users to read/write their own data
- Public read access for blog posts and models
- Admin-only write access for app settings
- Comprehensive user activity tracking permissions

## 🚀 Deployment Steps

1. **Prepare Environment**:
   ```bash
   firebase login
   firebase use lets-crease
   ```

2. **Deploy Security Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

3. **Seed Database**:
   ```bash
   cd functions
   npm run seed
   ```

4. **Deploy Functions** (if needed):
   ```bash
   npm run deploy
   ```

## 📱 Flutter Integration

After seeding, update your Flutter app to use these collections:

### Example: Fetching Blog Posts
```dart
Stream<List<BlogModel>> getBlogPosts() {
  return FirebaseFirestore.instance
      .collection('blog_posts')
      .where('isActive', isEqualTo: true)
      .orderBy('publishedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BlogModel.fromFirestore(doc))
          .toList());
}
```

### Example: Tracking User Activity
```dart
Future<void> trackUserActivity({
  required String action,
  String? modelId,
  Map<String, dynamic>? metadata,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('user_activities')
      .add({
    'userId': user.uid,
    'action': action,
    'modelId': modelId,
    'metadata': metadata ?? {},
    'timestamp': FieldValue.serverTimestamp(),
    'sessionId': getCurrentSessionId(),
  });
}
```

## 🎯 Next Steps

1. **Test the seeded data** in your Firebase console
2. **Update your Flutter app** to use the new collections
3. **Implement user activity tracking** in your app code
4. **Configure analytics** and monitoring
5. **Set up production security rules**

## 📞 Support

If you encounter any issues:
1. Check the Firebase console for errors
2. Verify your service account key is correct
3. Ensure your project ID matches in the script
4. Check network connectivity and Firebase CLI setup

---

**Happy Folding! 🎨📄**
