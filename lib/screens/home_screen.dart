import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/mood_provider.dart';
import '../widgets/aurora_background.dart';
import 'now_playing_screen.dart';
import 'playlist_screen.dart';
import 'mood_landing_page.dart';
import 'explore_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _tabs = [
    const HomeTab(),
    const ExploreScreen(),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Ensure aurora shows through
        extendBody: true,
        body: IndexedStack(
          clipBehavior: Clip.none,
          index: _currentIndex,
          children: _tabs,
        ),
        floatingActionButton: const MiniPlayer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Apple Music Style Ultra-Bold Header
        SliverAppBar(
          expandedHeight: 140.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              _getGreeting(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: -1,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Quick Access Grid (Tidal Inspired Modular Style)
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final moods = [
                  {'mood': Mood.happy, 'label': 'Happy Mix', 'color': Colors.amber},
                  {'mood': Mood.sad, 'label': 'Sad Melodies', 'color': Colors.blue},
                  {'mood': Mood.chill, 'label': 'Chill Vibes', 'color': Colors.deepPurpleAccent},
                  {'mood': Mood.focus, 'label': 'Deep Focus', 'color': Colors.cyan},
                  {'mood': Mood.energetic, 'label': 'High Energy', 'color': Colors.orange},
                ];
                if (index >= moods.length) return null;
                final m = moods[index];
                final moodProvider = Provider.of<MoodProvider>(context, listen: false);

                return FadeIn(
                  delay: Duration(milliseconds: 50 * index),
                  child: GestureDetector(
                    onTap: () {
                      moodProvider.updateMood(m['mood'] as Mood);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlaylistScreen()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: (m['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (m['color'] as Color).withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: (m['color'] as Color).withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [m['color'] as Color, (m['color'] as Color).withValues(alpha: 0.3)],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.music_note, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              m['label'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: 5,
            ),
          ),
        ),

        // Apple Music style shelf title
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'Recently Played',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ),

        // Recently Played Carousel (Apple/Spotify Hybrid)
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: MoodProvider.allLocalSongs.length < 6 ? MoodProvider.allLocalSongs.length : 6,
              itemBuilder: (context, index) {
                final song = MoodProvider.allLocalSongs[index];
                final moodProvider = Provider.of<MoodProvider>(context, listen: false);

                return GestureDetector(
                  onTap: () => moodProvider.playSong(song),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            song.coverUrl,
                            width: 160,
                            height: 160,
                            cacheWidth: 320,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 160,
                              height: 160,
                              color: Colors.white10,
                              child: const Icon(Icons.music_note, color: Colors.white38, size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          song.title,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artist,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Made For You List (Tidal High-Fi Style)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Text(
              'Made For You',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = MoodProvider.allLocalSongs[(index + 6) % MoodProvider.allLocalSongs.length];
                final moodProvider = Provider.of<MoodProvider>(context, listen: false);

                return GestureDetector(
                  onTap: () => moodProvider.playSong(song),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Image.network(
                            song.coverUrl,
                            width: 100,
                            height: 100,
                            cacheWidth: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.white10,
                              child: const Icon(Icons.album_rounded, color: Colors.white38, size: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${song.artist} • MoodSync',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 36),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: 5,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 150)),
      ],
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: RepaintBoundary(
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 70,
          borderRadius: 35,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.12),
              const Color(0xFFFFFFFF).withValues(alpha: 0.06),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.2),
              const Color(0xFFFFFFFF).withValues(alpha: 0.05),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => onTap(0),
                child: _NavBarItem(icon: Icons.home_filled, isSelected: currentIndex == 0),
              ),
              GestureDetector(
                onTap: () => onTap(1),
                child: _NavBarItem(icon: Icons.explore_outlined, isSelected: currentIndex == 1),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MoodLandingPage()),
                  (route) => false,
                ),
                child: const _NavBarItem(icon: Icons.mood_rounded, isSelected: false),
              ),
              GestureDetector(
                onTap: () => onTap(2),
                child: _NavBarItem(icon: Icons.library_music_outlined, isSelected: currentIndex == 2),
              ),
              GestureDetector(
                onTap: () => onTap(3),
                child: _NavBarItem(icon: Icons.person_outlined, isSelected: currentIndex == 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  const _NavBarItem({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white38,
          size: 28,
        ),
        if (isSelected) ...[
          const SizedBox(height: 4),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}

class MiniPlayer extends StatelessWidget {
  final bool fromPlaylist;
  const MiniPlayer({super.key, this.fromPlaylist = false});

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final currentSong = moodProvider.currentSong;
    final moodColor = moodProvider.moodColor;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => NowPlayingScreen(fromPlaylist: fromPlaylist),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: RepaintBoundary(
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 70,
            borderRadius: 35, // Consistently rounded pill shape
            blur: 15,
            alignment: Alignment.center,
            border: 1.5,
            linearGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E2E2E),
                  Color(0xFF1A1A1A),
                ],
                stops: [0.1, 1]),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                moodColor.withValues(alpha: 0.8),
                moodColor.withValues(alpha: 0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildSpotifyLayout(currentSong, moodProvider, moodColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotifyLayout(Song? currentSong, MoodProvider moodProvider, Color moodColor) {
    return Row(
      children: [
        if (currentSong != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              currentSong.coverUrl,
              width: 42,
              height: 42,
              cacheWidth: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 42,
                height: 42,
                color: moodColor.withValues(alpha: 0.3),
                child: const Icon(Icons.music_note_rounded, color: Colors.white54, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentSong?.title ?? "No Song Selected",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                currentSong?.artist ?? "Vibe with MoodSync",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => moodProvider.previousSong(),
          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => moodProvider.togglePlay(),
          child: GlassmorphicContainer(
            width: 44,
            height: 44,
            borderRadius: 22,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                moodColor.withValues(alpha: 0.3),
                moodColor.withValues(alpha: 0.1),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                moodColor.withValues(alpha: 0.5),
                moodColor.withValues(alpha: 0.1),
              ],
            ),
            child: Icon(
              moodProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => moodProvider.nextSong(),
          icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
