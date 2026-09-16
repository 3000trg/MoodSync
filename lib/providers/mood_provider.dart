import 'package:flutter/material.dart';

enum Mood {
  happy,
  sad,
  chill,
  focus,
  energetic,
}

class Song {
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String coverUrl;

  Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.coverUrl,
  });
}

class MoodProvider with ChangeNotifier {
  Mood _selectedMood = Mood.chill;
  Song? _currentSong;
  bool _isPlaying = false;

  final Map<Mood, List<Song>> _moodSongs = {
    Mood.happy: [
      Song(title: "Golden Sunbeams", artist: "Sunny Day Collective", album: "Solar Vibes", duration: "3:45", coverUrl: "https://picsum.photos/seed/happy1/300/300"),
      Song(title: "Walking on Air", artist: "Joy Joy", album: "Cloud 9", duration: "2:58", coverUrl: "https://picsum.photos/seed/happy2/300/300"),
      Song(title: "Summer Breeze", artist: "Beachside Trio", album: "Coastal Living", duration: "4:12", coverUrl: "https://picsum.photos/seed/happy3/300/300"),
      Song(title: "Talk Dirty (feat. 2 Chainz)", artist: "Jason Derulo", album: "Tattoos", duration: "2:58", coverUrl: "https://picsum.photos/seed/happy4/300/300"),
      Song(title: "Moves Like Jagger", artist: "Maroon 5", album: "Hands All Over", duration: "3:21", coverUrl: "https://picsum.photos/seed/happy5/300/300"),
    ],
    Mood.sad: [
      Song(title: "Midnight Rain", artist: "The Blue Echoes", album: "Stormy Nights", duration: "5:10", coverUrl: "https://picsum.photos/seed/sad1/300/300"),
      Song(title: "Distant Memories", artist: "Echo Valley", album: "Forgotten", duration: "4:32", coverUrl: "https://picsum.photos/seed/sad2/300/300"),
      Song(title: "Loneliness in Minor", artist: "Piano Solos", album: "Empty Rooms", duration: "3:45", coverUrl: "https://picsum.photos/seed/sad3/300/300"),
      Song(title: "Treat You Better", artist: "Shawn Mendes", album: "Illuminate", duration: "3:08", coverUrl: "https://picsum.photos/seed/sad4/300/300"),
    ],
    Mood.chill: [
      Song(title: "Lofi Horizon", artist: "Cloud Nine Beats", album: "Study Session", duration: "2:50", coverUrl: "https://picsum.photos/seed/chill1/300/300"),
      Song(title: "Gentle Waves", artist: "Ocean Drift", album: "Blue Waters", duration: "6:15", coverUrl: "https://picsum.photos/seed/chill2/300/300"),
      Song(title: "After Hours", artist: "Night Owl", album: "City Lights", duration: "3:58", coverUrl: "https://picsum.photos/seed/chill3/300/300"),
      Song(title: "Side To Side", artist: "Ariana Grande", album: "Dangerous Woman", duration: "3:46", coverUrl: "https://picsum.photos/seed/chill4/300/300"),
    ],
    Mood.focus: [
      Song(title: "Neural Flow", artist: "Deep Work Project", album: "Brainwaves", duration: "8:00", coverUrl: "https://picsum.photos/seed/focus1/300/300"),
      Song(title: "Binary Beats", artist: "Code Rhythm", album: "Syntax", duration: "4:20", coverUrl: "https://picsum.photos/seed/focus2/300/300"),
      Song(title: "The Library", artist: "Ambient Scholar", album: "History", duration: "5:30", coverUrl: "https://picsum.photos/seed/focus3/300/300"),
    ],
    Mood.energetic: [
      Song(title: "Thunder Strike", artist: "Electric Pulse", album: "Voltage", duration: "3:15", coverUrl: "https://picsum.photos/seed/energetic1/300/300"),
      Song(title: "High Voltage", artist: "Circuit Breakers", album: "Currents", duration: "4:02", coverUrl: "https://picsum.photos/seed/energetic2/300/300"),
      Song(title: "Neon Racing", artist: "Synth Racer", album: "Overdrive", duration: "2:45", coverUrl: "https://picsum.photos/seed/energetic3/300/300"),
      Song(title: "Beauty And A Beat", artist: "Justin Bieber", album: "Believe", duration: "3:47", coverUrl: "https://picsum.photos/seed/energetic4/300/300"),
    ],
  };

  Mood get selectedMood => _selectedMood;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  List<Song> get currentPlaylist => _moodSongs[_selectedMood] ?? [];

  void setMood(Mood mood) {
    _selectedMood = mood;
    _isPlaying = true;
    
    // Automatically select the 1st song from the list after shuffling
    final playlist = _moodSongs[_selectedMood] ?? [];
    if (playlist.isNotEmpty) {
      playlist.shuffle(); // Randomize the order
      _currentSong = playlist[0];
    }
    
    notifyListeners();
  }

  void playSong(Song song) {
    _currentSong = song;
    _isPlaying = true;
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
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
    }
  }
}
