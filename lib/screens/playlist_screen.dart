import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/mood_provider.dart';
import '../widgets/aurora_background.dart';
import '../widgets/gemini_halo_widget.dart';
import 'home_screen.dart';
import 'now_playing_screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  bool _showHalo = false;
  bool _hasAutoNavigated = false;
  bool _isDimmed = false;

  @override
  void initState() {
    super.initState();
    // 1. Start entrance animation for list items
    // 2. When first song settles (800ms), start the halo and dim other songs
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showHalo = true;
          _isDimmed = true; // Dramatic focus on 1st song
        });
      }
    });

    // 3. After one full halo cycle (approx 3 seconds total from start), 
    // remove the dimming to reveal the full list
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) {
        setState(() {
          _isDimmed = false;
        });
      }
    });

    // 4. Cinematic auto-navigation to full screen
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted && !_hasAutoNavigated) {
        _hasAutoNavigated = true;
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const NowPlayingScreen(fromPlaylist: true),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final playlist = moodProvider.currentPlaylist;
    final moodColor = moodProvider.moodColor;

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100), // Space for AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeInDown(
                child: Text(
                  "${moodProvider.selectedMood.name[0].toUpperCase()}${moodProvider.selectedMood.name.substring(1)} Vibes",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  "${playlist.length} tracks curated for you",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: playlist.length,
                itemBuilder: (context, index) {
                  final song = playlist[index];
                  final isCurrent = moodProvider.currentSong == song;

                  // The first song stays bright, others dim temporarily
                  final shouldBeDimmed = _isDimmed && !isCurrent;

                  Widget item = _SongListItem(
                    index: index + 1,
                    song: song,
                    isCurrent: isCurrent,
                    isDimmed: shouldBeDimmed,
                    moodColor: moodColor,
                    onTap: () => moodProvider.playSong(song),
                  );

                  // Wrap the currently playing song with the Gemini halo
                  if (isCurrent) {
                    item = GeminiHaloWidget(
                      color: moodColor,
                      isActive: _showHalo,
                      child: item,
                    );
                  }

                  return FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 100 * index),
                    child: item,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 100), // Space for mini player
          ],
        ),
        floatingActionButton: const MiniPlayer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: -1, // No tab selected on this screen
          onTap: (index) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: index)),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}

class _SongListItem extends StatelessWidget {
  final int index;
  final Song song;
  final bool isCurrent;
  final bool isDimmed;
  final Color moodColor;
  final VoidCallback onTap;

  const _SongListItem({
    required this.index,
    required this.song,
    required this.isCurrent,
    required this.isDimmed,
    required this.moodColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: isDimmed ? 0.3 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isCurrent 
                ? moodColor.withValues(alpha: 0.1) 
                : Colors.white.withValues(alpha: 0.05),
            border: null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  "$index",
                  style: TextStyle(
                    color: isCurrent ? moodColor : Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.coverUrl,
                  width: 48,
                  height: 48,
                  cacheWidth: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        color: isCurrent ? moodColor : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                song.album,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 16),
              if (isCurrent)
                Icon(Icons.check_circle, color: moodColor, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 12),
              Text(
                song.duration,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
