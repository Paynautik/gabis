import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/session/session.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/coming_soon.dart';
import '../../shared/widgets/glowing_background.dart';
import '../../shared/widgets/user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final handle = userName.split(RegExp(r'\s+')).first.toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: GlowingBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                UserAvatar(
                  radius: 32,
                  showEditBadge: true,
                  onTap: () => showAvatarSheet(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: context.colors.ink, letterSpacing: -0.2)),
                      const SizedBox(height: 2),
                      Text('@$handle', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit name',
                  icon: Icon(Icons.edit_outlined, color: context.colors.bluePrimary),
                  onPressed: () => _editName(context, ref, userName),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.badge_outlined, color: context.colors.bluePrimary),
              title: Text('Name on the account',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: context.colors.ink)),
              subtitle: Text(userName, style: TextStyle(color: context.colors.inkSoft)),
              trailing: Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft),
              onTap: () => _editName(context, ref, userName),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.face_retouching_natural_rounded, color: context.colors.bluePrimary),
              title: Text('Your picture',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: context.colors.ink)),
              subtitle: Text(_pictureLabel(ref.watch(userAvatarProvider)),
                  style: TextStyle(color: context.colors.inkSoft)),
              trailing: Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft),
              onTap: () => showAvatarSheet(context),
            ),
            _tile(context, Icons.verified_user_outlined, 'Identity verification'),
            _tile(context, Icons.lock_outline_rounded, 'Security & PIN'),
            _tile(context, Icons.people_outline_rounded, 'Beneficiaries'),
            _tile(context, Icons.notifications_none_rounded, 'Notifications'),
            _tile(context, Icons.support_agent_rounded, 'Support'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () async {
                // Goes through the session so the local copy — the name
                // included — is wiped rather than left for the next person.
                await ref.read(sessionProvider).signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }

  /// The name shows on the card, the greeting and the account details, so it
  /// is edited in one place and read from the account everywhere else.
  Future<void> _editName(
      BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Name on the account'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          decoration: const InputDecoration(hintText: 'Ada Okonkwo'),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (name == null || name.trim().length < 2) return;

    await ref.read(profileNameProvider.notifier).set(name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Name updated.')));
  }

  String _pictureLabel(String? avatar) {
    if (Avatar.isPhoto(avatar)) return 'A photo you uploaded';
    if (Avatar.isFun(avatar)) {
      return 'Character ${Avatar.funFaces[Avatar.funIndexOf(avatar)]}';
    }
    return 'Your initials';
  }

  Widget _tile(BuildContext context, IconData icon, String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: context.colors.bluePrimary),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: context.colors.ink)),
      trailing: Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft),
      onTap: () => showComingSoon(context, label),
    );
  }
}
