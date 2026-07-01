import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/app_strings.dart';
import '../models/favorite.dart';
import '../services/download_service.dart';
import '../services/favorites_service.dart';
import '../services/history_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_scope.dart';
import '../utils/media_utils.dart';
import '../utils/url_utils.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({
    super.key,
    required this.onDownloadComplete,
    required this.onFavoriteAdded,
  });

  final void Function({bool openTvTab}) onDownloadComplete;
  final VoidCallback onFavoriteAdded;

  @override
  State<BrowserScreen> createState() => BrowserScreenState();
}

class BrowserScreenState extends State<BrowserScreen>
    with AutomaticKeepAliveClientMixin {
  WebViewController? _controller;
  String _currentUrl = 'https://www.google.com';
  String _pageTitle = '';
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initController('https://www.google.com');
  }

  void loadUrl(String url) {
    final normalized = UrlUtils.normalize(url);
    setState(() => _currentUrl = normalized);
    _controller?.loadRequest(Uri.parse(normalized));
    HistoryService.instance.add(normalized);
  }

  void _initController(String initialUrl) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(SettingsService.instance.userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) async {
            final title = await _controller?.getTitle();
            final back = await _controller?.canGoBack() ?? false;
            final forward = await _controller?.canGoForward() ?? false;
            if (mounted) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
                _pageTitle = title ?? '';
                _canGoBack = back;
                _canGoForward = forward;
              });
            }
            await HistoryService.instance.add(url, title: title);
          },
          onNavigationRequest: (request) {
            if (UrlUtils.isDirectFileUrl(request.url)) {
              _downloadCurrentUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));

    _controller = controller;
  }

  Future<void> _downloadCurrentUrl([String? url]) async {
    final target = url ?? _currentUrl;
    if (!UrlUtils.isDirectFileUrl(target)) {
      if (!mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text(AppStrings.notDownloadablePageTitle),
          content: const Text(AppStrings.notDownloadablePageMessage),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final item = await DownloadService.instance.downloadFromUrl(target);
      widget.onDownloadComplete(
        openTvTab: MediaUtils.shouldOpenTvTabAfterDownload(item.fileName),
      );
      if (mounted) {
        final onTvTab = MediaUtils.shouldOpenTvTabAfterDownload(item.fileName);
        final isApk = MediaUtils.isApk(item.fileName);
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text(AppStrings.downloadSavedTitle),
            content: Text(
              isApk
                  ? AppStrings.downloadSavedApk(AppStrings.tvTitle)
                  : onTvTab
                      ? AppStrings.downloadSavedCast(AppStrings.tvTitle)
                      : AppStrings.downloadSavedFiles(AppStrings.filesTitle),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e is DownloadException ? e.message : e.toString();
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Download Failed'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _onFavoriteTap() async {
    if (FavoritesService.instance.hasUrl(_currentUrl)) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text(AppStrings.alreadySavedTitle),
          content: const Text(AppStrings.alreadySavedMessage),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    await _addFavorite();
  }

  Future<void> _addFavorite() async {
    final nameController = TextEditingController(text: _pageTitle.isNotEmpty
        ? _pageTitle
        : UrlUtils.displayHost(_currentUrl));

    final saved = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Add Favorite'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: nameController,
            placeholder: 'Name',
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true && nameController.text.trim().isNotEmpty) {
      await FavoritesService.instance.add(
        Favorite(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: nameController.text.trim(),
          url: _currentUrl,
          createdAt: DateTime.now(),
        ),
      );
      widget.onFavoriteAdded();
      if (mounted) {
        setState(() {});
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text(AppStrings.favoriteSavedTitle),
            content: const Text(AppStrings.favoriteSavedMessage),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
    nameController.dispose();
  }

  void _showUrlBar() {
    final palette = context.palette;
    final controller = TextEditingController(text: _currentUrl);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 120,
        color: palette.card,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  style: TextStyle(color: palette.label),
                  decoration: BoxDecoration(
                    color: palette.fieldBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  keyboardType: TextInputType.url,
                  onSubmitted: (value) {
                    Navigator.pop(ctx);
                    loadUrl(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pop(ctx);
                  loadUrl(controller.text);
                },
                child: const Text('GO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final palette = context.palette;
    final isFavorited = FavoritesService.instance.hasUrl(_currentUrl);

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: palette.navBarBackground,
        border: null,
        middle: GestureDetector(
          onTap: _showUrlBar,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _pageTitle.isNotEmpty
                    ? _pageTitle
                    : UrlUtils.displayHost(_currentUrl),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.1,
                  color: palette.label,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _currentUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        color: palette.secondaryLabel,
                      ),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 10,
                    color: AppColors.primary.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _onFavoriteTap,
          child: Icon(
            isFavorited ? CupertinoIcons.star_fill : CupertinoIcons.star,
            color: isFavorited ? AppColors.primary : null,
          ),
        ),
      ),
      child: Column(
        children: [
          if (_isLoading) const _LoadingBar(),
          Expanded(
            child: WebViewWidget(controller: _controller!),
          ),
          _BrowserToolbar(
            canGoBack: _canGoBack,
            canGoForward: _canGoForward,
            onBack: () => _controller?.goBack(),
            onForward: () => _controller?.goForward(),
            onReload: () => _controller?.reload(),
            onDownload: () => _downloadCurrentUrl(),
          ),
        ],
      ),
    );
  }
}

class _BrowserToolbar extends StatelessWidget {
  const _BrowserToolbar({
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
    required this.onReload,
    required this.onDownload,
  });

  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onReload;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(top: BorderSide(color: palette.separator)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolbarButton(
            icon: CupertinoIcons.chevron_back,
            enabled: canGoBack,
            onPressed: onBack,
          ),
          _ToolbarButton(
            icon: CupertinoIcons.chevron_forward,
            enabled: canGoForward,
            onPressed: onForward,
          ),
          _ToolbarButton(
            icon: CupertinoIcons.arrow_clockwise,
            enabled: true,
            onPressed: onReload,
          ),
          _ToolbarButton(
            icon: CupertinoIcons.arrow_down_circle,
            enabled: true,
            onPressed: onDownload,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      onPressed: enabled ? onPressed : null,
      child: Icon(
        icon,
        size: 24,
        color: enabled
            ? (color ?? AppColors.primary)
            : palette.secondaryLabel.withValues(alpha: 0.4),
      ),
    );
  }
}

class _LoadingBar extends StatefulWidget {
  const _LoadingBar();

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: 3,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * 0.35;
              final left = (constraints.maxWidth + barWidth) * _controller.value -
                  barWidth;
              return Stack(
                children: [
                  Container(color: AppColors.primary.withValues(alpha: 0.15)),
                  Positioned(
                    left: left,
                    width: barWidth,
                    top: 0,
                    bottom: 0,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
