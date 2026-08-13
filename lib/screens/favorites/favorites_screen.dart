import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/favorites_repository.dart';
import '../../widgets/folder_edit_dialog.dart';
import 'folder_detail_screen.dart';

// Favorites library: list of custom folders, each with a name and color
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _createFolder(BuildContext context) async {
    final repo = context.read<FavoritesRepository>();
    final result = await showDialog<(String, Color)>(
      context: context,
      builder: (_) => const FolderEditDialog(),
    );
    if (result != null) {
      await repo.createFolder(result.$1, result.$2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FavoritesRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _createFolder(context),
          ),
        ],
      ),
      body: repo.folders.isEmpty
          ? const Center(child: Text('Aucun dossier. Créez-en un !'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: repo.folders.length,
              itemBuilder: (context, i) {
                final folder = repo.folders[i];
                final count = folder.itemIds.length;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: folder.color,
                      child: const Icon(Icons.folder, color: Colors.white),
                    ),
                    title: Text(folder.name),
                    subtitle: Text('$count élément${count > 1 ? 's' : ''}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'rename') {
                          final result = await showDialog<(String, Color)>(
                            context: context,
                            builder: (_) => FolderEditDialog(
                              initialName: folder.name,
                              initialColor: folder.color,
                            ),
                          );
                          if (result != null) {
                            await repo.renameFolder(folder.id, result.$1);
                          }
                        } else if (value == 'delete') {
                          await repo.deleteFolder(folder.id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'rename', child: Text('Renommer')),
                        PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FolderDetailScreen(folderId: folder.id)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
