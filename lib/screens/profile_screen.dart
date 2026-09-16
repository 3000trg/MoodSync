import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Apple Music Style Profile Header
          FadeInDown(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        blurRadius: 50,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage('https://picsum.photos/seed/user/300/300'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: const Text(
              'Terence Mood',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Tidal-Style Modular Stats Grid
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: _ProfileTile(label: 'Vibe Syncs', value: '1.2k', icon: Icons.bolt, color: Colors.amber)),
                SizedBox(width: 12),
                Expanded(child: _ProfileTile(label: 'Total Hours', value: '482', icon: Icons.timer, color: Colors.blueAccent)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: _ProfileTile(label: 'Followers', value: '243', icon: Icons.people, color: Colors.purpleAccent)),
                SizedBox(width: 12),
                Expanded(child: _ProfileTile(label: 'Rank', value: '#12', icon: Icons.emoji_events, color: Colors.greenAccent)),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Modular Settings (Clean Apple Style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      _CompactProfileRow(icon: Icons.history, title: 'Listening History'),
                      _CompactProfileRow(icon: Icons.notifications_none, title: 'Notifications'),
                      _CompactProfileRow(icon: Icons.privacy_tip_outlined, title: 'Privacy & Security'),
                      _CompactProfileRow(icon: Icons.logout, title: 'Sign Out', isDestructive: true),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 150),
        ],
      ),
    ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CompactProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;

  const _CompactProfileRow({
    required this.icon,
    required this.title,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
      onTap: () {},
    );
  }
}
