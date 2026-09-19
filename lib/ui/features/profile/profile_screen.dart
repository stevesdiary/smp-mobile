import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              title: Text('Profile', style: textTheme.headlineMedium),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar + name
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFF0F0FF),
                      child: Text(
                        'AO',
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Adaeze Obi', style: textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text('adaeze.obi@email.com', style: textTheme.bodyMedium),
                    const SizedBox(height: 24),

                    // Account section
                    _SectionCard(
                      children: [
                        _SettingsRow(
                          icon: Icons.person_outline,
                          label: 'Edit Profile',
                          onTap: () {},
                        ),
                        _SettingsRow(
                          icon: Icons.lock_outline,
                          label: 'Change Password',
                          onTap: () {},
                        ),
                        _SettingsRow(
                          icon: Icons.notifications_outlined,
                          label: 'Notification Preferences',
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // App section
                    _SectionCard(
                      children: [
                        _SettingsRow(
                          icon: Icons.info_outline,
                          label: 'About',
                          onTap: () {},
                        ),
                        _SettingsRow(
                          icon: Icons.help_outline,
                          label: 'Help & Support',
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sign out
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.logout, color: Color(0xFFBA1A1A)),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Color(0xFFBA1A1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBA1A1A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8E8E93).withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 22),
                const SizedBox(width: 16),
                Expanded(child: Text(label, style: textTheme.bodyLarge)),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 54, color: Color(0xFFC7C5D3)),
      ],
    );
  }
}
