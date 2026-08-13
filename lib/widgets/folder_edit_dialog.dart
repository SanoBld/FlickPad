import 'package:flutter/material.dart';

const List<Color> kFolderColors = [
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.pink,
];

// Dialog to create or rename a folder and pick its color
class FolderEditDialog extends StatefulWidget {
  final String? initialName;
  final Color? initialColor;

  const FolderEditDialog({super.key, this.initialName, this.initialColor});

  @override
  State<FolderEditDialog> createState() => _FolderEditDialogState();
}

class _FolderEditDialogState extends State<FolderEditDialog> {
  late final TextEditingController _controller;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _selectedColor = widget.initialColor ?? kFolderColors.first;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Nouveau dossier' : 'Renommer le dossier'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nom du dossier'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kFolderColors.map((color) {
              final selected = color.toARGB32() == _selectedColor.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected ? Border.all(color: Colors.white, width: 3) : null,
                    boxShadow: selected ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context, (name, _selectedColor));
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
