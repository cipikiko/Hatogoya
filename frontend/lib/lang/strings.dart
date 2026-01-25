import 'package:flutter/material.dart';

import 'strings_en.dart';
import 'strings_sk.dart';
import 'strings_nl.dart';

class Tr {
  final String code; // 'en' | 'sk' | 'nl'
  const Tr(this.code);

  Map<String, String> get _map {
    switch (code) {
      case 'sk':
        return stringsSk;
      case 'nl':
        return stringsNl;
      case 'en':
      default:
        return stringsEn;
    }
  }

  String _t(String key) => _map[key] ?? stringsEn[key] ?? key;

  // --- expose keys as getters (pridáme ďalšie neskôr) ---
  String get settingsTitle => _t('settings_title');
  String get language => _t('language');
  String get languageSubtitle => _t('language_subtitle');

  String get retry => _t('retry');
  String get showLess => _t('show_less');
  String get seeAll => _t('see_all');
  String get loadMore => _t('load_more');

  // Settings screen
  String get darkMode => _t('dark_mode');
  String get darkModeOn => _t('dark_mode_on');
  String get darkModeOff => _t('dark_mode_off');

  String get notifications => _t('notifications');
  String get notificationsOn => _t('notifications_on');
  String get notificationsOff => _t('notifications_off');

  String get vibrations => _t('vibrations');
  String get vibrationsOn => _t('vibrations_on');
  String get vibrationsOff => _t('vibrations_off');

  String get privacyTerms => _t('privacy_terms');
  String get privacyTermsSubtitle => _t('privacy_terms_subtitle');

  // Dialog
  String get languageSelectTitle => _t('language_select_title');
  String get slovak => _t('lang_slovak');
  String get english => _t('lang_english');
  String get dutch => _t('lang_dutch');

  // Terms screen
  String get termsTitle => _t('terms_title');
  String get privacyPolicyTitle => _t('privacy_policy_title');
  String get privacyPolicyBody => _t('privacy_policy_body');
  String get termsOfUseTitle => _t('terms_of_use_title');
  String get termsOfUseBody => _t('terms_of_use_body');
  String get contactTitle => _t('contact_title');
  String get contactBody => _t('contact_body');

  // Bottom menu
  String get menuProfile => _t('menu_profile');
  String get menuLogout => _t('menu_logout');
  String get menuLogin => _t('menu_login');
  String get menuRegister => _t('menu_register');
  String get menuSettings => _t('menu_settings');
  String get menuAbout => _t('menu_about');

  // About screen
  String get aboutTitle => _t('about_title');
  String get aboutAppName => _t('about_app_name');
  String get aboutVersion => _t('about_version');
  String get aboutDescription => _t('about_description');
  String get aboutAuthors => _t('about_authors');

  // Profile screen
  String get profilePlantsDiscovered => _t('profile_plants_discovered');
  String get profileRecentActivity => _t('profile_recent_activity');
  String get profileTotalVisits => _t('profile_total_visits');
  String get profilePlantsFound => _t('profile_plants_found');

  String get profileTitle => _t('profile_title');
  String get profileSubtitle => _t('profile_subtitle');

  String profileProgressPlants(int found, int total) =>
      _t('profile_progress_plants')
          .replaceAll('{found}', '$found')
          .replaceAll('{total}', '$total');

  String get profileSubmitCtaTitle => _t('profile_submit_cta_title');
  String get profileSubmitCtaSubtitle => _t('profile_submit_cta_subtitle');

  String get profileActivity1 => _t('profile_activity_1');
  String get profileActivity2 => _t('profile_activity_2');
  String get profileActivity3 => _t('profile_activity_3');

  // ✅ NEW (for your ProfileScreen changes)
  String get profileNoActivity => _t('profile_no_activity');
  String get profileRecently => _t('profile_recently');
  String profileDiscoveredPlant(String name) =>
      _t('profile_discovered_plant').replaceAll('{name}', name);

  String get profileGuest => _t('profile_guest');
  String profileHello(String name) =>
      _t('profile_hello').replaceAll('{name}', name);

  // Submit dialog
  String get submitTitle => _t('submit_title');
  String get submitSubtitle => _t('submit_subtitle');
  String get submitUploadTitle => _t('submit_upload_title');
  String get submitUploadHint => _t('submit_upload_hint');

  String get submitFieldPlantName => _t('submit_field_plant_name');
  String get submitHintPlantName => _t('submit_hint_plant_name');

  String get submitFieldScientificName => _t('submit_field_scientific_name');
  String get submitHintScientificName => _t('submit_hint_scientific_name');

  String get submitFieldLocation => _t('submit_field_location');
  String get submitHintLocation => _t('submit_hint_location');

  String get submitFieldDescription => _t('submit_field_description');
  String get submitHintDescription => _t('submit_hint_description');

  String get submitInfoReview => _t('submit_info_review');

  String get cancel => _t('cancel');
  String get submitButton => _t('submit_button');

  // Discover screen
  String get discoverTitle => _t('discover_title');
  String get discoverSubtitle => _t('discover_subtitle');
  String get discoverSearchHint => _t('discover_search_hint');

  String get discoverScanTitle => _t('discover_scan_title');
  String get discoverScanSubtitle => _t('discover_scan_subtitle');

  String get discoverCollectionTitle => _t('discover_collection_title');

  String discoverCollectionProgress(int found, int total) =>
      _t('discover_collection_progress')
          .replaceAll('{found}', '$found')
          .replaceAll('{total}', '$total');

  String discoverCollectionPercent(int percent) =>
      _t('discover_collection_percent')
          .replaceAll('{percent}', '$percent');

  String get discoverLastCollected => _t('discover_last_collected');
  String get discoverNotDiscoveredYet => _t('discover_not_discovered_yet');

  // Home / News
  String get homeHeaderTitle => _t('home_header_title');
  String get homeHeaderSubtitle => _t('home_header_subtitle');

  String get homeTopStory => _t('home_top_story');
  String get homeLatest => _t('home_latest');

  String get homeFailedLoad => _t('home_failed_load');
  String get homeRetry => _t('home_retry');
  String get homeCouldNotOpen => _t('home_could_not_open');

  String get homeSeeAll => _t('home_see_all');
  String get homeShowLess => _t('home_show_less');
  String get homeLoadMore => _t('home_load_more');

  String homeShowingOf(int shown, int total) =>
      _t('home_showing_of')
          .replaceAll('{shown}', '$shown')
          .replaceAll('{total}', '$total');

  String get homeEmptyTitle => _t('home_empty_title');
  String get homeEmptySubtitle => _t('home_empty_subtitle');
  String plantDescription(int id) => _t('plant_${id}_desc');

  // Top story Education
  String get homeTopEduTitle => _t('home_top_edu_title');
  String get homeTopEduSubtitle => _t('home_top_edu_subtitle');
  String get homeTagFeatured => _t('home_tag_featured');

  // Tags
  String get homeTagStory => _t('home_tag_story');
  String get homeTagAnnouncement => _t('home_tag_announcement');
  String get homeTagUpdate => _t('home_tag_update');

  String get homeFallbackWalkTitle => _t('home_fallback_walk_title');
  String get homeFallbackWalkSubtitle => _t('home_fallback_walk_subtitle');

  String get homeFallbackVisionTitle => _t('home_fallback_vision_title');
  String get homeFallbackVisionSubtitle => _t('home_fallback_vision_subtitle');

  String get homeFallbackProcessTitle => _t('home_fallback_process_title');
  String get homeFallbackProcessSubtitle => _t('home_fallback_process_subtitle');

  String get homeTapToOpen => _t('home_tap_to_open');

  // Plants screen
  String get plantsTitle => _t('plants_title');
  String get plantsSubtitle => _t('plants_subtitle');
  String get plantsSearchHint => _t('plants_search_hint');

  String get plantsOpenWikipedia => _t('plants_open_wikipedia');
  String get plantsCouldNotOpenLink => _t('plants_could_not_open_link');

  String get plantsSortDefault => _t('plants_sort_default');
  String get plantsSortAzOn => _t('plants_sort_az_on');
  String get plantsSortZaOn => _t('plants_sort_za_on');

  // Auth / Login / Register / Forgot password
  String get loginTitle => _t('login_title');
  String get loginWelcomeTitle => _t('login_welcome_title');
  String get loginWelcomeSubtitle => _t('login_welcome_subtitle');
  String get loginUsernameLabel => _t('login_username_label');
  String get loginPasswordLabel => _t('login_password_label');
  String get loginButton => _t('login_button');
  String get loginNoAccount => _t('login_no_account');
  String get loginGoRegister => _t('login_go_register');

  String get loginFillAllFields => _t('login_fill_all_fields');
  String get loginSuccess => _t('login_success');
  String get loginInvalidCreds => _t('login_invalid_cres');
  String get loginDevOffline => _t('login_dev_offline');

  String get registerTitle => _t('register_title');
  String get registerHeaderTitle => _t('register_header_title');
  String get registerHeaderSubtitle => _t('register_header_subtitle');
  String get registerNameLabel => _t('register_name_label');
  String get registerEmailLabel => _t('register_email_label');
  String get registerPasswordLabel => _t('register_password_label');
  String get registerConfirmPasswordLabel => _t('register_confirm_password_label');
  String get registerButton => _t('register_button');
  String get registerAlreadyHave => _t('register_already_have');
  String get registerGoLogin => _t('register_go_login');

  String get registerFillAllFields => _t('register_fill_all_fields');
  String get registerPasswordsMismatch => _t('register_passwords_mismatch');
  String get registerSuccess => _t('register_success');
  String get registerError => _t('register_error');

  String get forgotTitle => _t('forgot_title');
  String get forgotHeaderTitle => _t('forgot_header_title');
  String get forgotHeaderSubtitle => _t('forgot_header_subtitle');
  String get forgotEmailLabel => _t('forgot_email_label');
  String get forgotSendButton => _t('forgot_send_button');
  String get forgotSendSuccess => _t('forgot_send_success');
  String get forgotSendError => _t('forgot_send_error');
  String get loginForgotPassword => _t('login_forgot_password');

  // Opening hours
  String get openingHoursTitle => _t('opening_hours_title');
  String get openingHoursNowOpen => _t('opening_hours_now_open');
  String get openingHoursNowClosed => _t('opening_hours_now_closed');

  String get weekdayMon => _t('weekday_mon');
  String get weekdayTue => _t('weekday_tue');
  String get weekdayWed => _t('weekday_wed');
  String get weekdayThu => _t('weekday_thu');
  String get weekdayFri => _t('weekday_fri');
  String get weekdaySat => _t('weekday_sat');
  String get weekdaySun => _t('weekday_sun');

  String get openingHoursClosed => _t('opening_hours_closed');
  String get openingHoursNote => _t('opening_hours_note');
  String get ok => _t('ok');

  String get mapOffsiteTitle => _t('map_offsite_title');
  String get mapOffsiteBody => _t('map_offsite_body');

  String get webEducationTitle => _t('web_education_title');
  String get commonDiscovered => _t('common_discovered');
  String get scanLoginFirst => _t('scan_login_first');

  String get apiUnexpectedResponseFormat => _t('api_unexpected_response_format');
  String get apiQrNotOurs => _t('api_qr_not_ours');
  String get apiScanFailed => _t('api_scan_failed');
  String get apiProfileLoadFailed => _t('api_profile_load_failed');
}

extension TrX on BuildContext {
  Tr get tr => Tr(_LangAccessor.codeOf(this));
}

/// Toto je len bridge – code sa bude brať z LangService (cez inherited-ish prístup)
class _LangAccessor {
  static String codeOf(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_LangInherited>();
    return inherited?.code ?? 'en';
  }
}

/// Toto použijeme v main.dart ako “provider” jazyka cez widget tree
class LangProvider extends InheritedWidget {
  final String code;
  const LangProvider({super.key, required this.code, required super.child});

  @override
  bool updateShouldNotify(covariant LangProvider oldWidget) => oldWidget.code != code;
}

// alias typ, aby extension našla správny typ (nemení funkcionalitu)
typedef _LangInherited = LangProvider;
