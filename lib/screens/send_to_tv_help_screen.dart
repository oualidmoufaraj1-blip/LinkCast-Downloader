import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme_scope.dart';

class SendToTvHelpScreen extends StatelessWidget {
  const SendToTvHelpScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => const SendToTvHelpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Cast to TV guide'),
        backgroundColor: palette.navBarBackground,
        border: null,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: const [
          _Section(
            title: 'Overview',
            body:
                'Casting works differently depending on the file type.\n\n'
                'Download the file first from Home or Browse. For video and audio streaming, '
                'your iPhone and TV must be on the same Wi‑Fi network, and the TV must support '
                'AirPlay (Apple TV or an AirPlay-compatible smart TV).',
          ),
          _Section(
            title: 'Method 1: Cast tab',
            body:
                'Open the Cast tab from the bottom bar. Use the filter to view your library:',
          ),
          _Bullets(items: [
            'All — every supported downloaded file',
            'Video — .mp4, .mov, and similar formats',
            'Audio — .mp3, .m4a, and similar formats',
            'Apps — .apk installer packages',
          ]),
          _Section(
            title: 'Tap a file',
            body: 'Tap a file to continue:',
          ),
          _Bullets(items: [
            'Video or audio opens the cast player with AirPlay controls.',
            'APK files open an on-TV install guide.',
            'Other files can be shared through the iOS share sheet.',
          ]),
          _Section(
            title: 'Method 2: Library tab',
            body:
                'Open Library and tap a downloaded file. For supported media or APK files, '
                'choose Cast or open the install guide.',
          ),
          _Section(
            title: 'Streaming video or audio',
            body:
                'After tapping Cast, the player opens. Tap the AirPlay icon and select your TV. '
                'Playback streams from your iPhone to the selected device.',
          ),
          _Section(
            title: 'APK files',
            body:
                'APK files cannot be installed on iPhone or streamed via AirPlay. '
                'The app shows an install guide instead.\n\n'
                'On a compatible Android TV or streaming box, use a file manager or browser on the TV, '
                'enter the same link or short code you used on iPhone, then download and install on the TV.\n\n'
                'You can also use Share to move the APK to another device.',
          ),
          _Section(
            title: 'Supported file types',
            body: '',
          ),
          _Bullets(items: [
            'Video (.mp4, .mov, etc.) — AirPlay',
            'Audio (.mp3, .m4a, etc.) — AirPlay',
            'APK — install guide (not AirPlay)',
            'PDF, ZIP, images, and other files — share only',
          ]),
          _Section(
            title: 'Troubleshooting',
            body: '',
          ),
          _Bullets(items: [
            'No TV in the list? Confirm same Wi‑Fi and AirPlay enabled on the TV.',
            'APK missing? Open Cast and choose Apps or All — not Video or Audio.',
            'File not listed? Switch tabs to refresh, or restart the app.',
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: palette.label,
            ),
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: palette.label,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•  ',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: palette.label,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
