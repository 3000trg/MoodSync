import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../providers/mood_provider.dart';
import '../widgets/aurora_background.dart';
import 'loading_screen.dart';

class MoodLandingPage extends StatelessWidget {
  const MoodLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                FadeInDown(
                  child: Text(
                    'Welcome to MoodSync',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Pick a vibe to start your session',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: const MoodGrid(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MoodGrid extends StatelessWidget {
  const MoodGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final moods = [
      {'mood': Mood.happy, 'label': 'Happy', 'emoji': '☀', 'color': Colors.amber},
      {'mood': Mood.sad, 'label': 'Sad', 'emoji': '🌧', 'color': Colors.blue},
      {'mood': Mood.chill, 'label': 'Chill', 'emoji': '🌙', 'color': Colors.deepPurpleAccent},
      {'mood': Mood.focus, 'label': 'Focus', 'emoji': '⚡', 'color': Colors.cyan},
      {'mood': Mood.energetic, 'label': 'Energetic', 'emoji': '🔥', 'color': Colors.orange},
    ];

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final m = moods[index];
        return MoodCard(
          mood: m['mood'] as Mood,
          label: m['label'] as String,
          emoji: m['emoji'] as String,
          color: m['color'] as Color,
        );
      },
    );
  }
}

class MoodCard extends StatelessWidget {
  final Mood mood;
  final String label;
  final String emoji;
  final Color color;

  const MoodCard({
    super.key,
    required this.mood,
    required this.label,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final moodProvider = Provider.of<MoodProvider>(context, listen: false);
        moodProvider.startNewSession(mood);
        
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoadingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 24,
        blur: 20,
        alignment: Alignment.center,
        border: 1.5,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
