import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

// Audio Provider for background music management
final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});

class AudioState {
  final bool isMusicEnabled;
  final bool isCurrentlyPlaying;
  final String? currentTrack;

  const AudioState({
    this.isMusicEnabled = true,
    this.isCurrentlyPlaying = false,
    this.currentTrack,
  });

  AudioState copyWith({
    bool? isMusicEnabled,
    bool? isCurrentlyPlaying,
    String? currentTrack,
  }) {
    return AudioState(
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isCurrentlyPlaying: isCurrentlyPlaying ?? this.isCurrentlyPlaying,
      currentTrack: currentTrack ?? this.currentTrack,
    );
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _effectsPlayer = AudioPlayer();
  
  AudioNotifier() : super(const AudioState()) {
    _loadSettings();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(0.3); // Set to 30% volume for background music
    
    // Listen for player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      developer.log('Audio player state changed: $state');
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        // Update our state when audio stops
        this.state = this.state.copyWith(isCurrentlyPlaying: false);
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final musicEnabled = prefs.getBool('global_music') ?? true;
    state = state.copyWith(
      isMusicEnabled: musicEnabled,
    );
    
    // Auto-start music if enabled
    if (musicEnabled) {
      await playGlobalBackgroundMusic();
    }
  }

  Future<void> toggleGlobalMusic(bool enabled) async {
    try {
      developer.log('Toggling global music: $enabled');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('global_music', enabled);
      state = state.copyWith(isMusicEnabled: enabled);
      
      if (enabled) {
        developer.log('Music enabled - starting background music');
        // Always try to start music when enabled, even if state shows playing
        await _forceStartGlobalMusic();
      } else {
        developer.log('Music disabled - stopping background music');
        // Stop music when disabled
        await stopMusic();
      }
      developer.log('Music toggle completed successfully');
    } catch (e) {
      developer.log('Error toggling global music: $e');
    }
  }

  Future<void> _forceStartGlobalMusic() async {
    try {
      // Stop any currently playing music first
      await _audioPlayer.stop();
      
      // Use a default pleasant background music
      final audioFile = _getRandomAudioFile('home');
      await _audioPlayer.play(AssetSource(audioFile));
      await _audioPlayer.setVolume(0.3);
      state = state.copyWith(
        isCurrentlyPlaying: true,
        currentTrack: 'global',
      );
      developer.log('Global background music force started successfully');
    } catch (e) {
      developer.log('Error force starting global background music: $e');
    }
  }

  Future<void> playGlobalBackgroundMusic() async {
    // Check global music setting
    if (!state.isMusicEnabled) return;
    
    // Don't restart if already playing
    if (state.isCurrentlyPlaying) return;
    
    try {
      // Use a default pleasant background music
      final audioFile = _getRandomAudioFile('home');
      await _audioPlayer.play(AssetSource(audioFile));
      await _audioPlayer.setVolume(0.3);
      state = state.copyWith(
        isCurrentlyPlaying: true,
        currentTrack: 'global',
      );
      developer.log('Global background music started successfully');
    } catch (e) {
      developer.log('Error playing global background music: $e');
    }
  }

  Future<void> playBackgroundMusic(String category) async {
    // For backward compatibility, just call global music
    await playGlobalBackgroundMusic();
  }

  Future<void> playSoundEffect(String soundName) async {
    try {
      await _effectsPlayer.play(AssetSource('audio/effects/$soundName.mp3'));
      developer.log('Playing sound effect: $soundName');
      developer.log('Sound effect played successfully');
    } catch (e) {
      developer.log('Error playing sound effect: $e');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop();
      state = state.copyWith(
        isCurrentlyPlaying: false,
        currentTrack: null,
      );
      developer.log('Music stopped successfully');
    } catch (e) {
      developer.log('Error stopping music: $e');
      // Update state even if stop fails
      state = state.copyWith(
        isCurrentlyPlaying: false,
        currentTrack: null,
      );
    }
  }

  Future<void> stopAll() async {
    try {
      await _audioPlayer.stop();
      await _effectsPlayer.stop();
      state = state.copyWith(
        isCurrentlyPlaying: false,
        currentTrack: null,
      );
      developer.log('All audio stopped');
    } catch (e) {
      developer.log('Error stopping all audio: $e');
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _audioPlayer.pause();
      state = state.copyWith(isCurrentlyPlaying: false);
      developer.log('Background music paused');
    } catch (e) {
      developer.log('Error pausing music: $e');
    }
  }

  Future<void> resumeMusic() async {
    try {
      await _audioPlayer.resume();
      state = state.copyWith(isCurrentlyPlaying: true);
      developer.log('Background music resumed');
    } catch (e) {
      developer.log('Error resuming music: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      developer.log('Audio volume set to: $volume');
    } catch (e) {
      developer.log('Error setting volume: $e');
    }
  }

  Future<void> setMuted(bool isMuted) async {
    try {
      await _audioPlayer.setVolume(isMuted ? 0.0 : 0.3);
      developer.log('Audio muted: $isMuted');
    } catch (e) {
      developer.log('Error setting mute: $e');
    }
  }

  String _getRandomAudioFile(String category) {
    // Return appropriate audio file based on category using only available files
    switch (category.toLowerCase()) {
      case 'home':
      case 'simulator':
      case 'folding':
        return 'audio/folding_music1.mp3';
      case 'categories':
        return 'audio/folding_music4.mp3';
      case 'quiz':
      case 'quizzes':
        return 'audio/quiz_music1.mp3';
      case 'blog':
      case 'world':
        return 'audio/folding_music5.mp3';
      default:
        return 'audio/folding_music1.mp3';
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _effectsPlayer.dispose();
    super.dispose();
  }
}
