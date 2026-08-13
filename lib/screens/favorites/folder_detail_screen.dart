import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/favorites_repository.dart';
import '../../widgets/media_card.dart';
import '../details/details_screen.dart';

// Shows saved media items inside one folder, with move/remove actions
class FolderDetailScreen extends StatelessWidget {
  final String folderId;

  const FolderDetailScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FavoritesRepository>();
    final folder = repo.folders.firstWhere((f) => f.id == folderId);
    final items = repo.itemsInFolder(folderId);

    return Scaffold(
      appBar: AppBar(title: Text(folder.name)),
      body: items.isEmpty
          ? const Center(child: Text('Ce dossier est vide'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return GestureDetector(
                  onLongPress: () => _showActions(context, repo, item.id),
                  child: MediaCard(
                    item: item,
                    width: double.infinity,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DetailsScreen(item: item)),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showActions(BuildContext context, FavoritesRepository repo, String itemId) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_move_outline),
              title: const Text('Déplacer vers...'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showMoveDialog(context, repo, itemId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Retirer du dossier'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await repo.removeFromFolder(folderId, itemId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveDialog(BuildContext context, FavoritesRepository repo, String itemId) {
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Déplacer vers'),
        children: repo.folders
            .where((f) => f.id != folderId)
            .map((f) => SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await repo.moveItem(itemId, folderId, f.id);
                  },
                  child: Row(
                    children: [
                      CircleAvatar(radius: 8, backgroundColor: f.color),
                      const SizedBox(width: 10),
                      Text(f.name),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
