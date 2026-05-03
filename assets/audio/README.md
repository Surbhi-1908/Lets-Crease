# Audio Assets

This folder contains background music files for the Let's Crease! origami app.

## Required Audio Files

To enable background music functionality with shuffle support, add multiple audio files for each category:

### Quiz Music (5 files recommended):
1. **quiz_music1.mp3**
2. **quiz_music2.mp3** 
3. **quiz_music3.mp3**
4. **quiz_music4.mp3**
5. **quiz_music5.mp3**

### Blog Music (5 files recommended):
1. **blog_music1.mp3**
2. **blog_music2.mp3**
3. **blog_music3.mp3** 
4. **blog_music4.mp3**
5. **blog_music5.mp3**

### Folding Music (5 files recommended):
1. **folding_music1.mp3**
2. **folding_music2.mp3**
3. **folding_music3.mp3**
4. **folding_music4.mp3** 
5. **folding_music5.mp3**

### App Startup Music (5 files recommended):
1. **app_music1.mp3**
2. **app_music2.mp3**
3. **app_music3.mp3**
4. **app_music4.mp3**
5. **app_music5.mp3**

## Audio File Requirements

- **Format**: MP3 (recommended for cross-platform compatibility)
- **Duration**: 2-5 minutes (files will loop automatically)
- **Volume**: Should be mixed at moderate levels (the app sets volume to 30%)
- **Style**: Calm, ambient, non-distracting background music suitable for concentration
- **Size**: Keep under 5MB each for optimal app performance

## Shuffle Functionality

- The app automatically shuffles between available files in each category
- Each time you enter a section (Quiz, Blog, Folding), a random track is selected
- If fewer than 5 files are available, the app will cycle through what's available
- Fallback to single file naming (quiz_music.mp3) if numbered files aren't found

## Usage

The audio files are controlled by:
- Settings toggles in the app's Settings page
- Automatic playback when entering relevant sections
- Random selection from available files for variety
- Graceful fallback if files are missing (no errors shown to user)

## Notes

- Audio files are optional - the app will function normally without them
- You can add fewer than 5 files per category if desired
- Users can toggle music on/off for each section independently
- Music stops automatically when switching between sections or exiting the app
- The shuffle algorithm ensures variety in your listening experience
