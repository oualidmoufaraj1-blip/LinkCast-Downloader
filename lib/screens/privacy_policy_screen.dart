import 'package:flutter/cupertino.dart';

import '../constants/app_strings.dart';
import '../theme/app_theme_scope.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Privacy Policy'),
        backgroundColor: palette.navBarBackground,
        border: null,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            'Last updated: June 24, 2026',
            style: TextStyle(
              fontSize: 13,
              color: palette.secondaryLabel,
            ),
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Overview',
            body:
                '${AppStrings.appName} helps you browse the web and save files to your device. '
                'This policy explains what information the app handles and how it is used.',
          ),
          const _Section(
            title: 'Information we collect',
            body:
                'The app stores URLs you enter, browsing history, saved bookmarks, and downloaded files '
                'locally on your device. This data stays on your device unless you choose to share a file.',
          ),
          const _Section(
            title: 'Information we do not collect',
            body:
                'We do not operate a user account system, do not sell personal data, and do not use '
                'third-party analytics or advertising SDKs in this app.',
          ),
          const _Section(
            title: 'Network activity',
            body:
                'When you enter a URL, search the web, or download a file, the app connects directly '
                'to the websites and servers you request. Those third parties may collect data according '
                'to their own policies.',
          ),
          const _Section(
            title: 'Data storage & deletion',
            body:
                'Downloads are saved in the app documents folder. You can delete individual files in '
                'Library, clear browsing history in Settings, or remove the app to delete all local data.',
          ),
          const _Section(
            title: 'Children\'s privacy',
            body: 'The app is not directed at children under 13.',
          ),
          _Section(
            title: 'Contact',
            body:
                'Questions about this policy can be sent to ${AppStrings.supportEmail}.',
          ),
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
      padding: const EdgeInsets.only(bottom: 20),
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
      ),
    );
  }
}
