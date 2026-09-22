import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../providers/mood_provider.dart';
import '../widgets/aurora_background.dart';
import 'playlist_screen.dart';

class NowPlayingScreen extends StatelessWidget {
  final bool fromPlaylist;

  const NowPlayingScreen({super.key, this.fromPlaylist = false});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final song = moodProvider.currentSong;
    final moodColor = moodProvider.moodColor;

    if (song == null) return const Scaffold();

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              const Spacer(),

              // Album Art
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: moodColor.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        song.coverUrl,
                        cacheWidth: 800,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Song Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInLeft(
                            child: Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FadeInLeft(
                            delay: const Duration(milliseconds: 100),
                            child: Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Progress Bar (Seeker)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ValueListenableBuilder<Duration>(
                  valueListenable: moodProvider.positionNotifier,
                  builder: (context, currentPosition, child) {
                    final durationMs = moodProvider.duration.inMilliseconds;
                    final positionRatio = durationMs > 0
                        ? (currentPosition.inMilliseconds / durationMs).clamp(0.0, 1.0)
                        : 0.0;

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            activeTrackColor: moodColor,
                            inactiveTrackColor: Colors.white10,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: positionRatio,
                            onChanged: (v) {
                              if (durationMs > 0) {
                                final seekMs = (v * durationMs).round();
                                moodProvider.seek(Duration(milliseconds: seekMs));
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(currentPosition),
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                              Text(
                                durationMs > 0
                                    ? _formatDuration(moodProvider.duration)
                                    : song.duration,
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle, color: Colors.white54, size: 24),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 48),
                      onPressed: () => moodProvider.previousSong(),
                    ),
                    // Play/Pause
                    GestureDetector(
                      onTap: () => moodProvider.togglePlay(),
                      child: RepaintBoundary(
                        child: GlassmorphicContainer(
                          width: 80,
                          height: 80,
                          borderRadius: 40,
                          blur: 15,
                          alignment: Alignment.center,
                          border: 1.5,
                          linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.05),
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
                            size: 44,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 48),
                      onPressed: () => moodProvider.nextSong(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.repeat, color: Colors.white54, size: 24),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // "See List" Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: GestureDetector(
                    onTap: () {
                      if (fromPlaylist) {
                        Navigator.pop(context);
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const PlaylistScreen()),
                        );
                      }
                    },
                    child: RepaintBoundary(
                      child: GlassmorphicContainer(
                        width: 160,
                        height: 50,
                        borderRadius: 25,
                        blur: 15,
                        alignment: Alignment.center,
                        border: 1,
                        linearGradient: LinearGradient(
                          colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
                        ),
                        borderGradient: LinearGradient(
                          colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'See List',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
