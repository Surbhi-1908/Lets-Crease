import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final String skillLevel;
  final bool isDarkMode;
  final bool quizMusicEnabled;
  final bool blogMusicEnabled;
  final bool tutorialMusicEnabled;
  final bool appMusicEnabled;
  final bool dailyReminderEnabled;
  final bool quizAlertsEnabled;
  final bool blogUpdatesEnabled;

  const SettingsState({
    this.skillLevel = 'Beginner',
    this.isDarkMode = false,
    this.quizMusicEnabled = true,
    this.blogMusicEnabled = true,
    this.tutorialMusicEnabled = true,
    this.appMusicEnabled = true,
    this.dailyReminderEnabled = true,
    this.quizAlertsEnabled = true,
    this.blogUpdatesEnabled = true,
  });

  SettingsState copyWith({
    String? skillLevel,
    bool? isDarkMode,
    bool? quizMusicEnabled,
    bool? blogMusicEnabled,
    bool? tutorialMusicEnabled,
    bool? appMusicEnabled,
    bool? dailyReminderEnabled,
    bool? quizAlertsEnabled,
    bool? blogUpdatesEnabled,
  }) {
    return SettingsState(
      skillLevel: skillLevel ?? this.skillLevel,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      quizMusicEnabled: quizMusicEnabled ?? this.quizMusicEnabled,
      blogMusicEnabled: blogMusicEnabled ?? this.blogMusicEnabled,
      tutorialMusicEnabled: tutorialMusicEnabled ?? this.tutorialMusicEnabled,
      appMusicEnabled: appMusicEnabled ?? this.appMusicEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      quizAlertsEnabled: quizAlertsEnabled ?? this.quizAlertsEnabled,
      blogUpdatesEnabled: blogUpdatesEnabled ?? this.blogUpdatesEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void setSkillLevel(String level) {
    state = state.copyWith(skillLevel: level);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void toggleQuizMusic(bool value) {
    state = state.copyWith(quizMusicEnabled: value);
  }

  void toggleBlogMusic(bool value) {
    state = state.copyWith(blogMusicEnabled: value);
  }

  void toggleTutorialMusic(bool value) {
    state = state.copyWith(tutorialMusicEnabled: value);
  }

  void toggleAppMusic(bool value) {
    state = state.copyWith(appMusicEnabled: value);
  }

  void toggleDailyReminder() {
    state = state.copyWith(dailyReminderEnabled: !state.dailyReminderEnabled);
  }

  void toggleQuizAlerts() {
    state = state.copyWith(quizAlertsEnabled: !state.quizAlertsEnabled);
  }

  void toggleBlogUpdates() {
    state = state.copyWith(blogUpdatesEnabled: !state.blogUpdatesEnabled);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
