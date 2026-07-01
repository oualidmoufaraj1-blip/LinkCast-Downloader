/// Centralized user-facing copy.
abstract final class AppStrings {
  static const String appName = 'LinkCast Downloader';
  static const String appShortName = 'LinkCast';
  static const String tagline = 'Download · Cast · Browse';
  static const String supportEmail = 'support@linkcast.app';

  static const String homeTitle = 'Home';
  static const String browserTitle = 'Browse';
  static const String filesTitle = 'Library';
  static const String tvTitle = 'Cast';
  static const String favoritesTitle = 'Saved';
  static const String settingsTitle = 'Settings';

  static const String urlPlaceholder = 'Paste a link, search, or enter a code';
  static const String shortCodeHint =
      'Numeric codes (e.g. 12345) open shortened links automatically.';

  static const String castFeatureTitle = 'Cast to TV';
  static const String castFeatureSubtitle =
      'Stream video and audio to Apple TV or AirPlay devices';

  static const String primaryAction = 'Continue';

  static const String emptyUrlMessage =
      'Enter a URL, search term, or short code to continue.';

  static const String savedToLibraryTitle = 'Saved to Library';
  static String savedToLibraryApk(String castTab) =>
      'Open $castTab → Apps for TV installation steps.';
  static String savedToLibraryCast(String castTab) =>
      'Your file is ready. Open $castTab to stream it.';
  static String savedToLibraryFiles(String libraryTab) =>
      'Your download is available in $libraryTab.';

  static const String downloadSavedTitle = 'Downloaded';
  static String downloadSavedApk(String castTab) =>
      'File saved. Open $castTab → Apps for install steps.';
  static String downloadSavedCast(String castTab) =>
      'File saved. Open $castTab to stream or manage it.';
  static String downloadSavedFiles(String libraryTab) =>
      'File saved to $libraryTab.';

  static const String notDownloadablePageTitle = 'Not a Downloadable File';
  static const String notDownloadablePageMessage =
      'This web page cannot be saved as a file. Open a direct link to a file '
      '(such as .mp4, .mp3, or .apk), or enter a download URL on Home.';

  static const String alreadySavedTitle = 'Already Saved';
  static const String alreadySavedMessage =
      'This page is already in your Saved list.';

  static const String favoriteSavedTitle = 'Saved';
  static const String favoriteSavedMessage = 'Added to your Saved list.';
}
