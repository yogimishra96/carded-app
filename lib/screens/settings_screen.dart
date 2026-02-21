import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppUser? _user;
  bool _googleSheetSynced = false;

  @override
  void initState() { super.initState(); _loadUser(); }

  Future<void> _loadUser() async {
    final user = await AuthService.instance.getUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _showChangePassword() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    await showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Change Password', style: AppTextStyles.heading3),
          const SizedBox(height: 20),
          AppTextField(label: 'Current Password', hint: '', controller: oldCtrl, obscureText: true),
          const SizedBox(height: 14),
          AppTextField(label: 'New Password', hint: 'Minimum 6 characters', controller: newCtrl, obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final result = await AuthService.instance.changePassword(oldCtrl.text, newCtrl.text);
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result.success ? 'Password updated!' : (result.message ?? 'Failed')),
                backgroundColor: result.success ? AppColors.success : AppColors.error));
            },
            child: const Text('Update Password')),
        ])));
    oldCtrl.dispose(); newCtrl.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'), content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Logout')),
        ]));
    if (confirm == true) {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.pop(context)), title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6)]),
          child: Row(children: [
            Container(width: 56, height: 56,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFF8B5CF6)]), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(_user?.fullName.isNotEmpty == true ? _user!.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_user?.fullName ?? 'User', style: AppTextStyles.heading3),
              Text(_user?.email ?? '', style: AppTextStyles.bodySecondary),
              Text(_user?.phone ?? '', style: AppTextStyles.bodySecondary),
            ])),
          ])),
        const SizedBox(height: 16),
        _SettingsGroup(items: [_SettingsTile(icon: Icons.lock_outline, label: 'Change Password', onTap: _showChangePassword)]),
        const SizedBox(height: 12),
        _SettingsGroup(items: [
          _SettingsTile(icon: Icons.table_chart_outlined, label: 'Google Sheet Sync',
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _googleSheetSynced ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(_googleSheetSynced ? 'Connected' : 'Not Connected',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _googleSheetSynced ? AppColors.success : AppColors.warning))),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
            ]),
            onTap: () { setState(() => _googleSheetSynced = !_googleSheetSynced);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_googleSheetSynced ? 'Google Sheet sync enabled (coming soon)' : 'Disabled'), backgroundColor: AppColors.accent)); })
        ]),
        const SizedBox(height: 12),
        _SettingsGroup(items: [_SettingsTile(icon: Icons.logout, label: 'Logout', labelColor: AppColors.error, iconColor: AppColors.error, onTap: _logout)]),
        const SizedBox(height: 24),
        const Center(child: Text('Carded v1.0.0 · MVP', style: AppTextStyles.caption)),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> items;
  const _SettingsGroup({required this.items});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6)]),
    child: Column(children: items));
}

class _SettingsTile extends StatelessWidget {
  final IconData icon; final String label; final Color? labelColor; final Color? iconColor; final Widget? trailing; final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label, this.labelColor, this.iconColor, this.trailing, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(onTap: onTap,
    leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
    title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: labelColor ?? AppColors.textPrimary)),
    trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4));
}
