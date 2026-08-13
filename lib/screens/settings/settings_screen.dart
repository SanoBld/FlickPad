import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_settings.dart';
import '../../widgets/folder_edit_dialog.dart';

// App settings: theme, notifications, data saver, region/language
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          _sectionHeader(context, 'Apparence'),
          SwitchListTile(
            title: const Text('Material You'),
            subtitle: const Text('Utiliser les couleurs du thème du téléphone'),
            value: settings.useDynamicColor,
            onChanged: (v) => settings.setDynamicColor(v),
          ),
          if (!settings.useDynamicColor)
            ListTile(
              title: const Text('Couleur d\'accent'),
              trailing: CircleAvatar(backgroundColor: settings.accentColor, radius: 14),
              onTap: () => _pickAccentColor(context, settings),
            ),
          const Divider(),
          _sectionHeader(context, 'Général'),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Alertes pour les nouvelles sorties'),
            value: settings.notificationsEnabled,
            onChanged: (v) => settings.setNotifications(v),
          ),
          SwitchListTile(
            title: const Text('Mode économie de données'),
            subtitle: const Text('Charge des images en plus basse résolution'),
            value: settings.dataSaverEnabled,
            onChanged: (v) => settings.setDataSaver(v),
          ),
          const Divider(),
          _sectionHeader(context, 'Contenu'),
          ListTile(
            title: const Text('Région'),
            subtitle: Text(settings.region),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickRegion(context, settings),
          ),
          ListTile(
            title: const Text('Langue'),
            subtitle: Text(settings.language == 'fr' ? 'Français' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickLanguage(context, settings),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Future<void> _pickAccentColor(BuildContext context, AppSettings settings) async {
    final color = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Couleur d\'accent'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: kFolderColors.map((c) {
                return GestureDetector(
                  onTap: () => Navigator.pop(dialogContext, c),
                  child: CircleAvatar(backgroundColor: c, radius: 18),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
    if (color != null) await settings.setAccentColor(color);
  }

  Future<void> _pickRegion(BuildContext context, AppSettings settings) async {
    const regions = ['FR', 'US', 'GB', 'DE', 'ES', 'IT', 'CA', 'BE', 'CH'];
    final region = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Région'),
        children: regions
            .map((r) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext, r),
                  child: Text(r),
                ))
            .toList(),
      ),
    );
    if (region != null) await settings.setRegion(region);
  }

  Future<void> _pickLanguage(BuildContext context, AppSettings settings) async {
    final language = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Langue'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'fr'),
            child: const Text('Français'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'en'),
            child: const Text('English'),
          ),
        ],
      ),
    );
    if (language != null) await settings.setLanguage(language);
  }
}
