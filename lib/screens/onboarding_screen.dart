import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/mood_provider.dart';
import '../widgets/aurora_background.dart';
import 'mood_landing_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  int? _selectedStateIndex;
  int? _selectedVibeIndex;

  final List<Map<String, dynamic>> _stateOptions = [
    {
      'title': 'Overwhelmed or stressed',
      'subtitle': 'Looking for peace & quiet',
      'icon': Icons.grain_rounded,
      'color': Colors.deepPurpleAccent,
      'mood': Mood.chill,
    },
    {
      'title': 'Feeling low or heavy',
      'subtitle': 'Need gentle comfort',
      'icon': Icons.water_drop_outlined,
      'color': Colors.blueAccent,
      'mood': Mood.sad,
    },
    {
      'title': 'Need to concentrate',
      'subtitle': 'Clearing mental clutter',
      'icon': Icons.center_focus_strong_rounded,
      'color': Colors.cyan,
      'mood': Mood.focus,
    },
    {
      'title': 'Neutral & steady',
      'subtitle': 'Ready for a pleasant flow',
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.amber,
      'mood': Mood.happy,
    },
    {
      'title': 'Seeking energy & drive',
      'subtitle': 'Ready to move & create',
      'icon': Icons.bolt_rounded,
      'color': Colors.orangeAccent,
      'mood': Mood.energetic,
    },
  ];

  final List<Map<String, dynamic>> _environmentOptions = [
    {
      'title': 'Soothing ambient & lo-fi',
      'description': 'Soft textures to slow down your thoughts',
      'icon': Icons.nights_stay_rounded,
    },
    {
      'title': 'Acoustic & gentle melodies',
      'description': 'Organic instruments and warm harmonies',
      'icon': Icons.music_note_rounded,
    },
    {
      'title': 'Focus & binaural rhythms',
      'description': 'Steady audio flow for deep work',
      'icon': Icons.headphones_rounded,
    },
    {
      'title': 'Uplifting beats & high energy',
      'description': 'Rhythmic tracks to boost your mood',
      'icon': Icons.local_fire_department_rounded,
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);

    if (!mounted) return;

    // Apply initial mood preference if selected and start a new session
    if (_selectedStateIndex != null) {
      final selectedMood = _stateOptions[_selectedStateIndex!]['mood'] as Mood;
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      moodProvider.startNewSession(selectedMood);
    }

    // Transition smoothly into MoodSync's core experience
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MoodLandingPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Top Progress indicator
                Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentStep >= 1 ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Step Header
                if (_currentStep == 0) ...[
                  FadeInDown(
                    key: const ValueKey('step0_header'),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to MoodSync',
                          style: TextStyle(
                            color: Colors.cyanAccent.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'How are you feeling right now?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Take a moment for yourself. There are no right or wrong answers.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  FadeInDown(
                    key: const ValueKey('step1_header'),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A GENTLE CALIBRATION',
                          style: TextStyle(
                            color: Colors.purpleAccent.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'What kind of sound space do you need?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We will tailor your initial sessions based on your preference.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Question Options List
                Expanded(
                  child: _currentStep == 0
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _stateOptions.length,
                          itemBuilder: (context, index) {
                            final option = _stateOptions[index];
                            final isSelected = _selectedStateIndex == index;

                            return FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedStateIndex = index;
                                    });
                                  },
                                  child: GlassmorphicContainer(
                                    width: double.infinity,
                                    height: 72,
                                    borderRadius: 18,
                                    blur: 15,
                                    alignment: Alignment.center,
                                    border: isSelected ? 1.8 : 0.8,
                                    linearGradient: LinearGradient(
                                      colors: isSelected
                                          ? [
                                              (option['color'] as Color).withValues(alpha: 0.25),
                                              (option['color'] as Color).withValues(alpha: 0.10),
                                            ]
                                          : [
                                              Colors.white.withValues(alpha: 0.08),
                                              Colors.white.withValues(alpha: 0.03),
                                            ],
                                    ),
                                    borderGradient: LinearGradient(
                                      colors: isSelected
                                          ? [
                                              option['color'] as Color,
                                              (option['color'] as Color).withValues(alpha: 0.4),
                                            ]
                                          : [
                                              Colors.white.withValues(alpha: 0.15),
                                              Colors.white.withValues(alpha: 0.05),
                                            ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: (option['color'] as Color).withValues(alpha: 0.2),
                                            ),
                                            child: Icon(
                                              option['icon'] as IconData,
                                              color: option['color'] as Color,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  option['title'] as String,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  option['subtitle'] as String,
                                                  style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.5),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: option['color'] as Color,
                                              size: 22,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _environmentOptions.length,
                          itemBuilder: (context, index) {
                            final option = _environmentOptions[index];
                            final isSelected = _selectedVibeIndex == index;

                            return FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedVibeIndex = index;
                                    });
                                  },
                                  child: GlassmorphicContainer(
                                    width: double.infinity,
                                    height: 76,
                                    borderRadius: 18,
                                    blur: 15,
                                    alignment: Alignment.center,
                                    border: isSelected ? 1.8 : 0.8,
                                    linearGradient: LinearGradient(
                                      colors: isSelected
                                          ? [
                                              Colors.purpleAccent.withValues(alpha: 0.25),
                                              Colors.purpleAccent.withValues(alpha: 0.10),
                                            ]
                                          : [
                                              Colors.white.withValues(alpha: 0.08),
                                              Colors.white.withValues(alpha: 0.03),
                                            ],
                                    ),
                                    borderGradient: LinearGradient(
                                      colors: isSelected
                                          ? [
                                              Colors.purpleAccent,
                                              Colors.purpleAccent.withValues(alpha: 0.4),
                                            ]
                                          : [
                                              Colors.white.withValues(alpha: 0.15),
                                              Colors.white.withValues(alpha: 0.05),
                                            ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.purpleAccent.withValues(alpha: 0.2),
                                            ),
                                            child: Icon(
                                              option['icon'] as IconData,
                                              color: Colors.purpleAccent,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  option['title'] as String,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  option['description'] as String,
                                                  style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.5),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.purpleAccent,
                                              size: 22,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Navigation Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentStep = 0;
                          });
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip for now',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        if (_currentStep == 0) {
                          setState(() {
                            _currentStep = 1;
                          });
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              _currentStep == 0 ? 'Continue' : 'Begin Journey',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
