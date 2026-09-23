# MoodSync

Mood based music companion app

## 🧠 Adaptive Mood Progression

MoodSync uses an adaptive music progression system designed to create a gradual emotional journey based on the user's initial mood.

Instead of repeatedly asking the user how they feel, MoodSync uses the initially selected mood as the starting point and silently adjusts music recommendations as the session progresses.

## 🎵 Emotional Audio Model

Each song in the MoodSync library is assigned two emotional characteristics:

- Valence — represents the emotional tone of a song, ranging from negative to positive.
- Energy — represents the intensity of a song, ranging from calm to highly energetic.

These values allow MoodSync to compare songs based on their emotional characteristics rather than relying only on predefined mood categories.

## 🔄 Progressive Recommendation

The recommendation system evaluates the valence and energy of available songs when selecting the next track.

### The general flow is:

Starting Mood → Emotional Position → Song Selection → 75% Completion → Progression → Next Song

As the session continues, the target emotional position gradually changes, allowing the music to transition naturally rather than making sudden jumps between unrelated moods.

## 🎧 Listening Completion Threshold

A song is considered meaningfully listened to only after **75% of its duration** has been played.

Simply starting a song or manually skipping it does not advance the progression.

This prevents users from accidentally progressing the emotional journey by repeatedly skipping tracks.

## 🌱 Mood Progression Profiles

### Sad

The Sad progression is designed to last approximately 5–7 meaningfully listened songs.

The system gradually moves from more negative emotional characteristics toward a more neutral and comfortable range rather than immediately switching to highly positive music.

### Neutral

The Neutral progression is designed to last approximately 6–8 meaningfully listened songs.

The system gradually explores more positive emotional characteristics while maintaining a natural transition.

### Happy

Happy mode does not have a fixed progression endpoint.

The system can continue recommending songs indefinitely while remaining within an appropriate positive emotional range.

## 🛡️ Emotional Jump Prevention

MoodSync restricts large changes in valence and energy between consecutive recommendations.

For example, a highly negative, low-energy song should not be followed immediately by an extremely positive, high-energy song simply because both songs exist in the library.

Instead, the system searches for songs that provide a closer emotional transition.

This creates a smoother progression between songs.

## 🔀 Controlled Shuffle

MoodSync does not randomly shuffle the entire recommendation sequence.

Songs are selected according to their valence and energy characteristics.

When multiple songs have the same valence and energy values, those songs may be shuffled between one another to introduce variety while maintaining the same emotional position.

## 🎯 Session-Based Progression

The user's mood is selected once at the beginning of a session.

After that, MoodSync handles the progression automatically in the background.

There are no repeated mood check-ins or interruptions asking the user how they currently feel.

The progression is intended to remain subtle and invisible, with the music itself creating the transition.

## 🚧 Implementation Status

Adaptive Mood Progression — In Development

The current MoodSync architecture already contains song-level valence and energy metadata, mood states, and session state tracking. The adaptive recommendation logic is being implemented on top of this foundation.