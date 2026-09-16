import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Bold Apple Music Style Header
        SliverAppBar(
          expandedHeight: 120.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              'Library',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.0,
                  ),
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () {}),
            const SizedBox(width: 8),
          ],
        ),

        // High-Fi Filters (Tidal Inspired)
        const SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _TextFilter(label: 'Playlists', isActive: true),
                _TextFilter(label: 'Artists'),
                _TextFilter(label: 'Albums'),
                _TextFilter(label: 'Downloaded'),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Featured (Large Artwork - Apple Style)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: FadeInLeft(
                    child: const _LargeLibraryCard(
                      title: 'Liked Songs',
                      subtitle: '124 tracks',
                      gradient: [Color(0xFF450AF5), Color(0xFFC4EFD9)],
                      icon: Icons.favorite,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FadeInRight(
                    child: const _LargeLibraryCard(
                      title: 'Sync Mix',
                      subtitle: 'Based on your vibes',
                      gradient: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                      icon: Icons.auto_awesome,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Refined List (Tidal Space/Typography)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return FadeInUp(
                delay: Duration(milliseconds: 50 * index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://picsum.photos/seed/library$index/200/200',
                        width: 60,
                        height: 60,
                        cacheWidth: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      'Collection #$index',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Updated yesterday',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.2)),
                    onTap: () {},
                  ),
                ),
              );
            },
            childCount: 8,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 150)),
      ],
    );
  }
}

class _TextFilter extends StatelessWidget {
  final String label;
  final bool isActive;
  const _TextFilter({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 12,
              height: 2,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}

class _LargeLibraryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;

  const _LargeLibraryCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
