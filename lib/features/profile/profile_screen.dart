import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/coming_soon.dart';
import '../../shared/widgets/glowing_background.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: GlowingBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: context.colors.blueHighlight,
                  child: Text(userName.substring(0, 1), style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w900, fontSize: 22)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: context.colors.ink, letterSpacing: -0.2)),
                    const SizedBox(height: 2),
                    Text('@raphael', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            _tile(context, Icons.verified_user_outlined, 'Identity verification'),
            _tile(context, Icons.lock_outline_rounded, 'Security & PIN'),
            _tile(context, Icons.people_outline_rounded, 'Beneficiaries'),
            _tile(context, Icons.notifications_none_rounded, 'Notifications'),
            _tile(context, Icons.support_agent_rounded, 'Support'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                ref.read(authStateProvider.notifier).state = false;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
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
