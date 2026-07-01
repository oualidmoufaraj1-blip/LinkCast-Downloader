import 'package:flutter/cupertino.dart';

import '../constants/app_strings.dart';
import '../models/favorite.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_scope.dart';
import '../utils/url_utils.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.onOpenUrl,
  });

  final void Function(String url) onOpenUrl;

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void refresh() => setState(() {});

  Future<void> _addFavorite() async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    final saved = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('New Favorite'),
        content: Column(
          children: [
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: nameController,
              placeholder: 'Name',
              autofocus: true,
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: urlController,
              placeholder: 'URL',
              keyboardType: TextInputType.url,
            ),
          ],
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

    if (saved == true &&
        nameController.text.trim().isNotEmpty &&
        urlController.text.trim().isNotEmpty) {
      await FavoritesService.instance.add(
        Favorite(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: nameController.text.trim(),
          url: UrlUtils.normalize(urlController.text.trim()),
          createdAt: DateTime.now(),
        ),
      );
      refresh();
    }

    nameController.dispose();
    urlController.dispose();
  }

  Future<void> _editFavorite(Favorite favorite) async {
    final nameController = TextEditingController(text: favorite.name);
    final urlController = TextEditingController(text: favorite.url);

    final saved = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Edit Favorite'),
        content: Column(
          children: [
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: nameController,
              placeholder: 'Name',
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: urlController,
              placeholder: 'URL',
              keyboardType: TextInputType.url,
            ),
          ],
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

    if (saved == true) {
      await FavoritesService.instance.update(
        Favorite(
          id: favorite.id,
          name: nameController.text.trim(),
          url: UrlUtils.normalize(urlController.text.trim()),
          createdAt: favorite.createdAt,
        ),
      );
      refresh();
    }

    nameController.dispose();
    urlController.dispose();
  }

  Future<void> _deleteFavorite(Favorite favorite) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Favorite?'),
        content: Text('Remove "${favorite.name}"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FavoritesService.instance.remove(favorite.id);
      refresh();
    }
  }

  void _showOptions(Favorite favorite) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(favorite.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onOpenUrl(favorite.url);
            },
            child: const Text('Open in Browser'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _editFavorite(favorite);
            },
            child: const Text('Edit'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _deleteFavorite(favorite);
            },
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final favorites = FavoritesService.instance.favorites;

    final palette = context.palette;

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(AppStrings.favoritesTitle),
        backgroundColor: palette.navBarBackground,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _addFavorite,
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: favorites.isEmpty
          ? EmptyState(
              icon: CupertinoIcons.star,
              title: 'No saved links',
              subtitle: 'Bookmark pages you visit often for one-tap access.',
              actionLabel: 'Add bookmark',
              onAction: _addFavorite,
            )
          : CupertinoFormSection.insetGrouped(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                for (final fav in favorites)
                  CupertinoListTile(
                    leading: Builder(
                      builder: (context) {
                        final palette = context.palette;
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: palette.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            CupertinoIcons.star_fill,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        );
                      },
                    ),
                    title: Text(fav.name),
                    subtitle: Text(
                      UrlUtils.displayHost(fav.url),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: () => _showOptions(fav),
                      child: const Icon(CupertinoIcons.ellipsis, size: 18),
                    ),
                    onTap: () => widget.onOpenUrl(fav.url),
                  ),
              ],
            ),
    );
  }
}
