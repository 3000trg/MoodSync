import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

enum Mood {
  happy,
  sad,
  chill,
  focus,
  energetic,
  neutral,
}

class MoodState {
  final Mood mood;
  final double valence; // -1.0 (negative) -> +1.0 (positive)
  final double energy;  // 0.0 (low/calm) -> 1.0 (high/intensity)

  const MoodState({
    required this.mood,
    required this.valence,
    required this.energy,
  });

  static MoodState fromMood(Mood mood) {
    switch (mood) {
      case Mood.sad:
        return const MoodState(mood: Mood.sad, valence: -0.8, energy: 0.3);
      case Mood.chill:
        return const MoodState(mood: Mood.chill, valence: 0.2, energy: 0.25);
      case Mood.neutral:
        return const MoodState(mood: Mood.neutral, valence: 0.0, energy: 0.4);
      case Mood.focus:
        return const MoodState(mood: Mood.focus, valence: 0.3, energy: 0.65);
      case Mood.happy:
        return const MoodState(mood: Mood.happy, valence: 0.8, energy: 0.7);
      case Mood.energetic:
        return const MoodState(mood: Mood.energetic, valence: 0.85, energy: 0.95);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodState &&
          runtimeType == other.runtimeType &&
          mood == other.mood &&
          valence == other.valence &&
          energy == other.energy;

  @override
  int get hashCode => mood.hashCode ^ valence.hashCode ^ energy.hashCode;
}

class Song {
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String coverUrl;
  final String audioAssetPath;
  final Mood mood;
  final double valence;
  final double energy;

  Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.coverUrl,
    required this.audioAssetPath,
    required this.mood,
    required this.valence,
    required this.energy,
  });
}

class MoodProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ValueNotifier<Duration> positionNotifier = ValueNotifier<Duration>(Duration.zero);

  Mood _selectedMood = Mood.chill;
  Song? _currentSong;
  bool _isPlaying = false;

  List<Song> _activePlaylist = [];
  int _currentIndex = 0;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  MoodState? _startingState;
  MoodState? _previousState;
  MoodState _currentState = MoodState.fromMood(Mood.chill);
  final List<MoodState> _moodHistory = [];

  MoodProvider() {
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _audioPlayer.onPositionChanged.listen((pos) {
      // Throttle notifyListeners() to once-per-second to prevent 60 FPS full-app rebuild lag during audio playback
      final secondChanged = pos.inSeconds != _position.inSeconds;
      _position = pos;
      positionNotifier.value = pos;

      if (secondChanged) {
        notifyListeners();
      }
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      nextSong(); // Auto-play next song on completion!
    });
  }

  // Centralized Master Local Dataset of 50 MP3 assets
  static final List<Song> allLocalSongs = [
    Song(
      title: "Animals",
      artist: "Maroon 5",
      album: "V",
      duration: "3:51",
      coverUrl: "https://picsum.photos/seed/happy1/300/300",
      audioAssetPath: "assets/audio/Animals_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.85,
      energy: 0.90,
    ),
    Song(
      title: "Break Free",
      artist: "Ariana Grande ft. Zedd",
      album: "My Everything",
      duration: "3:35",
      coverUrl: "https://picsum.photos/seed/happy2/300/300",
      audioAssetPath: "assets/audio/Break Free_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.80,
      energy: 0.95,
    ),
    Song(
      title: "break up with your girlfriend, i'm bored",
      artist: "Ariana Grande",
      album: "thank u, next",
      duration: "3:10",
      coverUrl: "https://picsum.photos/seed/happy3/300/300",
      audioAssetPath: "assets/audio/break up with your girlfriend, i'm bored_spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.30,
      energy: 0.60,
    ),
    Song(
      title: "Burn",
      artist: "Ellie Goulding",
      album: "Halcyon Days",
      duration: "3:51",
      coverUrl: "https://picsum.photos/seed/happy4/300/300",
      audioAssetPath: "assets/audio/Burn_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.75,
      energy: 0.80,
    ),
    Song(
      title: "Chained To The Rhythm",
      artist: "Katy Perry ft. Skip Marley",
      album: "Witness",
      duration: "3:57",
      coverUrl: "https://picsum.photos/seed/happy5/300/300",
      audioAssetPath: "assets/audio/Chained To The Rhythm_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.70,
      energy: 0.75,
    ),
    Song(
      title: "Cheap Thrills (feat. Sean Paul)",
      artist: "Sia ft. Sean Paul",
      album: "This Is Acting",
      duration: "3:44",
      coverUrl: "https://picsum.photos/seed/happy6/300/300",
      audioAssetPath: "assets/audio/Cheap Thrills (feat. Sean Paul)_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.85,
      energy: 0.85,
    ),
    Song(
      title: "Cool for the Summer",
      artist: "Demi Lovato",
      album: "Confident",
      duration: "3:34",
      coverUrl: "https://picsum.photos/seed/happy7/300/300",
      audioAssetPath: "assets/audio/Cool for the Summer_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.80,
      energy: 0.90,
    ),
    Song(
      title: "Disturbia",
      artist: "Rihanna",
      album: "Good Girl Gone Bad: Reloaded",
      duration: "3:58",
      coverUrl: "https://picsum.photos/seed/happy8/300/300",
      audioAssetPath: "assets/audio/Disturbia_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.60,
      energy: 0.90,
    ),
    Song(
      title: "Eastside (with Halsey & Khalid)",
      artist: "benny blanco, Halsey & Khalid",
      album: "FRIENDS KEEP SECRETS",
      duration: "2:53",
      coverUrl: "https://picsum.photos/seed/chill1/300/300",
      audioAssetPath: "assets/audio/Eastside (with Halsey & Khalid)_spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.40,
      energy: 0.45,
    ),
    Song(
      title: "Firework",
      artist: "Katy Perry",
      album: "Teenage Dream",
      duration: "3:47",
      coverUrl: "https://picsum.photos/seed/happy9/300/300",
      audioAssetPath: "assets/audio/Firework_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.85,
      energy: 0.85,
    ),
    Song(
      title: "Gimme More",
      artist: "Britney Spears",
      album: "Blackout",
      duration: "4:11",
      coverUrl: "https://picsum.photos/seed/energetic1/300/300",
      audioAssetPath: "assets/audio/Gimme More_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.65,
      energy: 0.85,
    ),
    Song(
      title: "God is a woman",
      artist: "Ariana Grande",
      album: "Sweetener",
      duration: "3:17",
      coverUrl: "https://picsum.photos/seed/focus1/300/300",
      audioAssetPath: "assets/audio/God is a woman_spotdown.org.mp3",
      mood: Mood.focus,
      valence: 0.50,
      energy: 0.60,
    ),
    Song(
      title: "Grenade",
      artist: "Bruno Mars",
      album: "Doo-Wops & Hooligans",
      duration: "3:42",
      coverUrl: "https://picsum.photos/seed/sad1/300/300",
      audioAssetPath: "assets/audio/Grenade_spotdown.org.mp3",
      mood: Mood.sad,
      valence: -0.60,
      energy: 0.70,
    ),
    Song(
      title: "Hot N Cold",
      artist: "Katy Perry",
      album: "One of the Boys",
      duration: "3:40",
      coverUrl: "https://picsum.photos/seed/happy10/300/300",
      audioAssetPath: "assets/audio/Hot N Cold_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.80,
      energy: 0.85,
    ),
    Song(
      title: "How Deep Is Your Love",
      artist: "Calvin Harris & Disciples",
      album: "How Deep Is Your Love",
      duration: "3:32",
      coverUrl: "https://picsum.photos/seed/chill2/300/300",
      audioAssetPath: "assets/audio/How Deep Is Your Love_spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.50,
      energy: 0.70,
    ),
    Song(
      title: "Just Dance",
      artist: "Lady Gaga ft. Colby O'Donis",
      album: "The Fame",
      duration: "4:01",
      coverUrl: "https://picsum.photos/seed/energetic2/300/300",
      audioAssetPath: "assets/audio/Just Dance_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.85,
      energy: 0.90,
    ),
    Song(
      title: "Last Friday Night (T.G.I.F.)",
      artist: "Katy Perry",
      album: "Teenage Dream",
      duration: "3:50",
      coverUrl: "https://picsum.photos/seed/happy11/300/300",
      audioAssetPath: "assets/audio/Last Friday Night (T.G.I.F.)_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.90,
      energy: 0.90,
    ),
    Song(
      title: "Lights",
      artist: "Ellie Goulding",
      album: "Bright Lights",
      duration: "3:32",
      coverUrl: "https://picsum.photos/seed/happy12/300/300",
      audioAssetPath: "assets/audio/Lights_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.75,
      energy: 0.80,
    ),
    Song(
      title: "Love Me Harder",
      artist: "Ariana Grande & The Weeknd",
      album: "My Everything",
      duration: "3:56",
      coverUrl: "https://picsum.photos/seed/chill3/300/300",
      audioAssetPath: "assets/audio/Love Me Harder_spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.40,
      energy: 0.60,
    ),
    Song(
      title: "Love Me Like You Do",
      artist: "Ellie Goulding",
      album: "Fifty Shades of Grey",
      duration: "4:12",
      coverUrl: "https://picsum.photos/seed/chill4/300/300",
      audioAssetPath: "assets/audio/Love Me Like You Do_spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.60,
      energy: 0.55,
    ),
    Song(
      title: "Love The Way You Lie",
      artist: "Eminem ft. Rihanna",
      album: "Recovery",
      duration: "4:23",
      coverUrl: "https://picsum.photos/seed/sad2/300/300",
      audioAssetPath: "assets/audio/Love The Way You Lie_spotdown.org.mp3",
      mood: Mood.sad,
      valence: -0.70,
      energy: 0.85,
    ),
    Song(
      title: "Love You Like A Love Song",
      artist: "Selena Gomez & The Scene",
      album: "When the Sun Goes Down",
      duration: "3:08",
      coverUrl: "https://picsum.photos/seed/happy13/300/300",
      audioAssetPath: "assets/audio/Love You Like A Love Song_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.70,
      energy: 0.75,
    ),
    Song(
      title: "Mirrors",
      artist: "Justin Timberlake",
      album: "The 20/20 Experience",
      duration: "8:05",
      coverUrl: "https://picsum.photos/seed/focus2/300/300",
      audioAssetPath: "assets/audio/Mirrors_spotdown.org.mp3",
      mood: Mood.focus,
      valence: 0.50,
      energy: 0.60,
    ),
    Song(
      title: "New Rules",
      artist: "Dua Lipa",
      album: "Dua Lipa",
      duration: "3:29",
      coverUrl: "https://picsum.photos/seed/energetic3/300/300",
      audioAssetPath: "assets/audio/New Rules_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.75,
      energy: 0.85,
    ),
    Song(
      title: "no tears left to cry",
      artist: "Ariana Grande",
      album: "Sweetener",
      duration: "3:25",
      coverUrl: "https://picsum.photos/seed/happy14/300/300",
      audioAssetPath: "assets/audio/no tears left to cry_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.70,
      energy: 0.80,
    ),
    Song(
      title: "Nothin' on You (feat. Bruno Mars)",
      artist: "B.o.B ft. Bruno Mars",
      album: "B.o.B Presents: The Adventures of Bobby Ray",
      duration: "4:28",
      coverUrl: "https://picsum.photos/seed/happy15/300/300",
      audioAssetPath: "assets/audio/Nothin' on You (feat. Bruno Mars)_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.80,
      energy: 0.65,
    ),
    Song(
      title: "On The Floor",
      artist: "Jennifer Lopez ft. Pitbull",
      album: "Love?",
      duration: "4:44",
      coverUrl: "https://picsum.photos/seed/energetic4/300/300",
      audioAssetPath: "assets/audio/On The Floor_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.90,
      energy: 0.95,
    ),
    Song(
      title: "One More Night",
      artist: "Maroon 5",
      album: "Overexposed",
      duration: "3:39",
      coverUrl: "https://picsum.photos/seed/happy16/300/300",
      audioAssetPath: "assets/audio/One More Night_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.70,
      energy: 0.80,
    ),
    Song(
      title: "Outside (feat. Ellie Goulding)",
      artist: "Calvin Harris ft. Ellie Goulding",
      album: "Motion",
      duration: "3:47",
      coverUrl: "https://picsum.photos/seed/energetic5/300/300",
      audioAssetPath: "assets/audio/Outside (feat. Ellie Goulding)_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.60,
      energy: 0.85,
    ),
    Song(
      title: "Part Of Me",
      artist: "Katy Perry",
      album: "Teenage Dream: The Complete Confection",
      duration: "3:36",
      coverUrl: "https://picsum.photos/seed/energetic6/300/300",
      audioAssetPath: "assets/audio/Part Of Me_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.70,
      energy: 0.85,
    ),
    Song(
      title: "Perfect Strangers",
      artist: "Jonas Blue ft. JP Cooper",
      album: "Blue",
      duration: "3:16",
      coverUrl: "https://picsum.photos/seed/happy17/300/300",
      audioAssetPath: "assets/audio/Perfect Strangers_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.80,
      energy: 0.75,
    ),
    Song(
      title: "positions",
      artist: "Ariana Grande",
      album: "Positions",
      duration: "2:52",
      coverUrl: "https://picsum.photos/seed/chill5/300/300",
      audioAssetPath: "assets/audio/positions_spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.60,
      energy: 0.50,
    ),
    Song(
      title: "Promiscuous",
      artist: "Nelly Furtado ft. Timbaland",
      album: "Loose",
      duration: "4:02",
      coverUrl: "https://picsum.photos/seed/energetic7/300/300",
      audioAssetPath: "assets/audio/Promiscuous_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.80,
      energy: 0.85,
    ),
    Song(
      title: "Rather Be (feat. Jess Glynne)",
      artist: "Clean Bandit ft. Jess Glynne",
      album: "New Eyes",
      duration: "3:47",
      coverUrl: "https://picsum.photos/seed/happy18/300/300",
      audioAssetPath: "assets/audio/Rather Be (feat. Jess Glynne)_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.85,
      energy: 0.80,
    ),
    Song(
      title: "Rockabye (feat. Sean Paul & Anne-Marie)",
      artist: "Clean Bandit ft. Sean Paul & Anne-Marie",
      album: "What Is Love?",
      duration: "4:10",
      coverUrl: "https://picsum.photos/seed/happy19/300/300",
      audioAssetPath: "assets/audio/Rockabye (feat. Sean Paul & Anne-Marie)_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.70,
      energy: 0.80,
    ),
    Song(
      title: "Señorita",
      artist: "Shawn Mendes & Camila Cabello",
      album: "Shawn Mendes",
      duration: "3:11",
      coverUrl: "https://picsum.photos/seed/chill6/300/300",
      audioAssetPath: "assets/audio/Señorita_spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.65,
      energy: 0.55,
    ),
    Song(
      title: "Shape of You",
      artist: "Ed Sheeran",
      album: "÷",
      duration: "3:53",
      coverUrl: "https://picsum.photos/seed/happy20/300/300",
      audioAssetPath: "assets/audio/Shape of You_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.80,
      energy: 0.75,
    ),
    Song(
      title: "Side To Side",
      artist: "Ariana Grande ft. Nicki Minaj",
      album: "Dangerous Woman",
      duration: "3:46",
      coverUrl: "https://picsum.photos/seed/chill7/300/300",
      audioAssetPath: "assets/audio/Side To Side_spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.55,
      energy: 0.65,
    ),
    Song(
      title: "Starboy",
      artist: "The Weeknd ft. Daft Punk",
      album: "Starboy",
      duration: "3:50",
      coverUrl: "https://picsum.photos/seed/focus3/300/300",
      audioAssetPath: "assets/audio/Starboy_spotdown.org.mp3",
      mood: Mood.focus,
      valence: 0.40,
      energy: 0.70,
    ),
    Song(
      title: "Starving",
      artist: "Hailee Steinfeld & Grey ft. Zedd",
      album: "Haiz",
      duration: "3:01",
      coverUrl: "https://picsum.photos/seed/happy21/300/300",
      audioAssetPath: "assets/audio/Starving_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.75,
      energy: 0.70,
    ),
    Song(
      title: "Stitches",
      artist: "Shawn Mendes",
      album: "Handwritten",
      duration: "3:26",
      coverUrl: "https://picsum.photos/seed/sad3/300/300",
      audioAssetPath: "assets/audio/Stitches_spotdown.org.mp3",
      mood: Mood.sad,
      valence: -0.50,
      energy: 0.70,
    ),
    Song(
      title: "Teenage Dream",
      artist: "Katy Perry",
      album: "Teenage Dream",
      duration: "3:47",
      coverUrl: "https://picsum.photos/seed/happy22/300/300",
      audioAssetPath: "assets/audio/Teenage Dream_spotdown.org.mp3",
      mood: Mood.happy,
      valence: 0.85,
      energy: 0.80,
    ),
    Song(
      title: "There's Nothing Holdin' Me Back",
      artist: "Shawn Mendes",
      album: "Illuminate",
      duration: "3:19",
      coverUrl: "https://picsum.photos/seed/energetic8/300/300",
      audioAssetPath: "assets/audio/There's Nothing Holdin' Me Back_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.80,
      energy: 0.85,
    ),
    Song(
      title: "We Don't Talk Anymore (feat. Selena Gomez)",
      artist: "Charlie Puth ft. Selena Gomez",
      album: "Nine Track Mind",
      duration: "3:37",
      coverUrl: "https://picsum.photos/seed/sad4/300/300",
      audioAssetPath: "assets/audio/We Don't Talk Anymore (feat. Selena Gomez)_spotdown.org.mp3",
      mood: Mood.sad,
      valence: -0.40,
      energy: 0.55,
    ),
    Song(
      title: "We Found Love",
      artist: "Rihanna ft. Calvin Harris",
      album: "Talk That Talk",
      duration: "3:35",
      coverUrl: "https://picsum.photos/seed/energetic9/300/300",
      audioAssetPath: "assets/audio/We Found Love_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.85,
      energy: 0.95,
    ),
    Song(
      title: "What Do You Mean?",
      artist: "Justin Bieber",
      album: "Purpose",
      duration: "3:25",
      coverUrl: "https://picsum.photos/seed/chill8/300/300",
      audioAssetPath: "assets/audio/What Do You Mean__spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.60,
      energy: 0.60,
    ),
    Song(
      title: "What Goes Around...Comes Around",
      artist: "Justin Timberlake",
      album: "FutureSex/LoveSounds",
      duration: "5:13",
      coverUrl: "https://picsum.photos/seed/sad5/300/300",
      audioAssetPath: "assets/audio/What Goes Around...Comes Around - Radio Edit_spotdown.org.mp3",
      mood: Mood.sad,
      valence: -0.60,
      energy: 0.60,
    ),
    Song(
      title: "Wide Awake",
      artist: "Katy Perry",
      album: "Teenage Dream: The Complete Confection",
      duration: "3:41",
      coverUrl: "https://picsum.photos/seed/sad6/300/300",
      audioAssetPath: "assets/audio/Wide Awake_spotdown.org.mp3",
      mood: Mood.sad,
      valence: -0.40,
      energy: 0.50,
    ),
    Song(
      title: "Wildest Dreams",
      artist: "Taylor Swift",
      album: "1989",
      duration: "3:40",
      coverUrl: "https://picsum.photos/seed/chill9/300/300",
      audioAssetPath: "assets/audio/Wildest Dreams_spotdown.org.mp3",
      mood: Mood.chill,
      valence: 0.40,
      energy: 0.50,
    ),
    Song(
      title: "Youngblood",
      artist: "5 Seconds of Summer",
      album: "Youngblood",
      duration: "3:23",
      coverUrl: "https://picsum.photos/seed/energetic10/300/300",
      audioAssetPath: "assets/audio/Youngblood_spotdown.org.mp3",
      mood: Mood.energetic,
      valence: 0.70,
      energy: 0.85,
    ),
  ];

  // Getters
  Mood get selectedMood => _selectedMood;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  List<Song> get currentPlaylist => List.unmodifiable(_activePlaylist);
  int get currentIndex => _currentIndex;
  Duration get position => _position;
  Duration get duration => _duration;

  // Session State Getters
  MoodState? get startingState => _startingState;
  MoodState? get previousState => _previousState;
  MoodState get currentState => _currentState;
  List<MoodState> get moodHistory => List.unmodifiable(_moodHistory);

  Mood get startingMood => _startingState?.mood ?? _currentState.mood;
  Mood get currentMood => _currentState.mood;
  Mood? get previousMood => _previousState?.mood;

  double get startingValence => _startingState?.valence ?? _currentState.valence;
  double get currentValence => _currentState.valence;
  double get startingEnergy => _startingState?.energy ?? _currentState.energy;
  double get currentEnergy => _currentState.energy;

  // Progression Metrics
  double get valenceChange => currentValence - startingValence;
  double get energyChange => currentEnergy - startingEnergy;

  bool get hasMovedTowardPositiveValence => currentValence > startingValence + 0.05;
  bool get hasMovedTowardCalmerEnergy => currentEnergy < startingEnergy - 0.05;
  bool get hasMovedTowardHigherEnergy => currentEnergy > startingEnergy + 0.05;
  bool get hasMeaningfulProgression =>
      _moodHistory.length > 1 && (valenceChange.abs() >= 0.2 || energyChange.abs() >= 0.2);

  void startNewSession(Mood mood, {bool autoplay = false}) {
    _selectedMood = mood;

    final initialState = MoodState.fromMood(mood);
    _moodHistory.clear();
    _startingState = initialState;
    _currentState = initialState;
    _previousState = null;
    _moodHistory.add(initialState);

    _loadPlaylistForMood(mood, autoplay: autoplay);
  }

  void updateMood(Mood mood, {bool autoplay = false}) {
    updateMoodState(MoodState.fromMood(mood), autoplay: autoplay);
  }

  void updateMoodState(MoodState newState, {bool autoplay = false}) {
    _selectedMood = newState.mood;

    _previousState = _currentState;
    _currentState = newState;
    _moodHistory.add(newState);

    _loadPlaylistForMood(newState.mood, autoplay: autoplay);
  }

  void _loadPlaylistForMood(Mood mood, {bool autoplay = false}) {
    final filtered = allLocalSongs.where((s) => s.mood == mood).toList();
    _activePlaylist = filtered.isNotEmpty ? List.from(filtered) : List.from(allLocalSongs);
    _activePlaylist.shuffle(); // Randomized ONCE when new playlist is generated!
    _currentIndex = 0;
    if (_activePlaylist.isNotEmpty) {
      _currentSong = _activePlaylist[0];
      if (autoplay) {
        playCurrentSong();
      }
    }
  }

  String _cleanAssetPath(String path) {
    if (path.startsWith('assets/')) {
      return path.substring(7);
    }
    return path;
  }

  Future<void> playCurrentSong() async {
    if (_currentSong == null) return;
    try {
      final cleanPath = _cleanAssetPath(_currentSong!.audioAssetPath);
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(cleanPath));
      _isPlaying = true;
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }
    notifyListeners();
  }

  void setMood(Mood mood) {
    if (_startingState == null) {
      startNewSession(mood);
    } else {
      updateMood(mood);
    }
  }

  void playSong(Song song) {
    int index = _activePlaylist.indexWhere((s) => s.audioAssetPath == song.audioAssetPath);
    if (index != -1) {
      _currentIndex = index;
    } else {
      _activePlaylist = [song];
      _currentIndex = 0;
    }
    _currentSong = song;
    playCurrentSong();
  }

  void nextSong() {
    if (_activePlaylist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _activePlaylist.length;
    _currentSong = _activePlaylist[_currentIndex];
    playCurrentSong();
  }

  void previousSong() {
    if (_activePlaylist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _activePlaylist.length) % _activePlaylist.length;
    _currentSong = _activePlaylist[_currentIndex];
    playCurrentSong();
  }

  Future<void> seek(Duration newPosition) async {
    await _audioPlayer.seek(newPosition);
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else {
      if (_currentSong != null) {
        if (_audioPlayer.state == PlayerState.paused) {
          await _audioPlayer.resume();
        } else {
          await playCurrentSong();
        }
      }
    }
    notifyListeners();
  }

  Color get moodColor {
    switch (_selectedMood) {
      case Mood.happy:
        return Colors.amber;
      case Mood.sad:
        return Colors.blue;
      case Mood.chill:
        return Colors.deepPurpleAccent;
      case Mood.focus:
        return Colors.cyan;
      case Mood.energetic:
        return Colors.orange;
      case Mood.neutral:
        return Colors.tealAccent;
    }
  }

  List<Color> get auroraColors {
    switch (_selectedMood) {
      case Mood.happy:
        return [const Color(0xFFFFD700), const Color(0xFFFF8C00), const Color(0xFF0F172A)];
      case Mood.sad:
        return [const Color(0xFF1E3A8A), const Color(0xFF3B82F6), const Color(0xFF0F172A)];
      case Mood.chill:
        return [const Color(0xFF4C1D95), const Color(0xFF8B5CF6), const Color(0xFF0F172A)];
      case Mood.focus:
        return [const Color(0xFF0891B2), const Color(0xFF22D3EE), const Color(0xFF0F172A)];
      case Mood.energetic:
        return [const Color(0xFF991B1B), const Color(0xFFEF4444), const Color(0xFF0F172A)];
      case Mood.neutral:
        return [const Color(0xFF0D9488), const Color(0xFF14B8A6), const Color(0xFF0F172A)];
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
