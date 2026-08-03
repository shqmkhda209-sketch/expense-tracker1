import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../services/backup_service.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';

/// صفحه تنظیمات: تم، واحد پول، پشتیبان‌گیری/بازیابی، یادآوری روزانه و حذف کامل داده‌ها
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _backupService = BackupService();
  bool _busy = false;

  Future<void> _handleBackup(BuildContext context) async {
    setState(() => _busy = true);
    try {
      final transactions = context.read<TransactionProvider>().all;
      await _backupService.exportBackup(transactions);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.backupSuccess), backgroundColor: AppColors.primary),
        );
      }
    } catch (_) {
      // کاربر می‌تواند اشتراک‌گذاری را لغو کند؛ نیازی به نمایش خطا نیست
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
    setState(() => _busy = true);
    try {
      final transactions = await _backupService.pickAndParseBackup();
      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(AppStrings.restore),
          content: Text('تعداد ${transactions.length} تراکنش یافت شد. اطلاعات فعلی جایگزین می‌شود.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(AppStrings.cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text(AppStrings.restore)),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await context.read<TransactionProvider>().restoreFromBackup(transactions);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.restoreSuccess), backgroundColor: AppColors.primary),
          );
        }
      }
    } catch (e) {
      if (e.toString().contains('cancelled')) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.restoreError), backgroundColor: AppColors.expense),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteAll),
        content: const Text(AppStrings.deleteAllConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.delete, style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<TransactionProvider>().deleteAllTransactions();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.allDataDeleted)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingsSection(
              title: AppStrings.theme,
              children: [
                _ThemeSelector(themeProvider: themeProvider),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: AppStrings.currency,
              children: [
                _CurrencySelector(settingsProvider: settingsProvider),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: AppStrings.dailyReminder,
              children: [
                SwitchListTile(
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(AppStrings.dailyReminder, textAlign: TextAlign.right),
                  subtitle: const Text(AppStrings.dailyReminderDesc, textAlign: TextAlign.right),
                  value: settingsProvider.reminderEnabled,
                  onChanged: (v) => settingsProvider.setReminderEnabled(v),
                ),
                if (settingsProvider.reminderEnabled)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.reminderTime, textAlign: TextAlign.right),
                    trailing: Text(settingsProvider.reminderTime.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: settingsProvider.reminderTime,
                      );
                      if (picked != null) {
                        await settingsProvider.setReminderTime(picked);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'اطلاعات',
              children: [
                _SettingsTile(
                  icon: Icons.upload_file_outlined,
                  title: AppStrings.backup,
                  subtitle: AppStrings.backupDesc,
                  onTap: () => _handleBackup(context),
                ),
                _SettingsTile(
                  icon: Icons.download_outlined,
                  title: AppStrings.restore,
                  subtitle: AppStrings.restoreDesc,
                  onTap: () => _handleRestore(context),
                ),
                _SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  title: AppStrings.deleteAll,
                  subtitle: AppStrings.deleteAllDesc,
                  titleColor: AppColors.expense,
                  onTap: () => _handleDeleteAll(context),
                ),
              ],
            ),
            if (_busy) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: titleColor ?? AppColors.primary),
      title: Text(title, textAlign: TextAlign.right, style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, textAlign: TextAlign.right),
      onTap: onTap,
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeProvider themeProvider;
  const _ThemeSelector({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final options = {
      ThemeMode.light: AppStrings.lightTheme,
      ThemeMode.dark: AppStrings.darkTheme,
      ThemeMode.system: AppStrings.systemTheme,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        children: options.entries.map((e) {
          final selected = themeProvider.themeMode == e.key;
          return ChoiceChip(
            label: Text(e.value),
            selected: selected,
            selectedColor: AppColors.primary.withOpacity(0.18),
            onSelected: (_) => themeProvider.setThemeMode(e.key),
          );
        }).toList(),
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final SettingsProvider settingsProvider;
  const _CurrencySelector({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CurrencyType.values.map((c) {
          final selected = settingsProvider.currency == c;
          return ChoiceChip(
            label: Text(c.label),
            selected: selected,
            selectedColor: AppColors.primary.withOpacity(0.18),
            onSelected: (_) => settingsProvider.setCurrency(c),
          );
        }).toList(),
      ),
    );
  }
}
