# `usePlayer` Hook

`usePlayer` is a custom React hook that provides comprehensive audio playback functionality for React Native applications. It allows you to control audio playback, including play, pause, stop, and seek (both forward and backward). The hook is designed to work with both Android and iOS using native modules for audio control and event handling.

---

## Features

- Play, pause, and stop audio.
- Seek forward and backward by a customizable interval.
- Tracks the progress of the audio playback.
- Supports both Android and iOS platforms.
- Auto-play feature on initialization (optional).
- Supports providing track metadata (title, artist, album, artwork).
- Efficient event handling for audio progress and state changes.
- Volume control.
- Looping and shuffling of tracks.
- Background playback support.
- Handling of audio interruptions (e.g., incoming calls).

---

## Components

### `AudioPlayer` Component

The `AudioPlayer` component is a prebuilt user interface that integrates seamlessly with the `react-native-audio-player` hook. It provides a ready-to-use audio player UI that can be easily customized and configured.

#### Features

- Prebuilt UI for audio playback control.
- Seamless integration with the `react-native-audio-player` hook.
- Customizable appearance and behavior.
- Displays track metadata (title, artist, album, artwork).
- Responsive design for both Android and iOS platforms.
- Volume control interface.
- Loop and shuffle controls.
- Background playback controls.

---

## Installation

Before using this hook, ensure that your project is set up to use native modules. You can install the `@shreyanshsingh/react-native-audio-player` package using npm or yarn:

```sh
npm install @shreyanshsingh/react-native-audio-player
```

---

## Usage

Here is a basic example of how to use the `react-native-audio-player` hook in your React Native application:

```jsx
import React from 'react';
import { View, Text } from 'react-native';
import { useAudioPlayer } from '@shreyanshsingh/react-native-audio-player';

const App = () => {
    const {
        play,
        pause,
        stop,
        seekForward,
        seekBackward,
        currentTrack,
        isPlaying,
        progress,
    } = useAudioPlayer();

    return (
        <View>
            <Text>Now Playing: {currentTrack.title}</Text>
            <Text>Artist: {currentTrack.artist}</Text>
            <Text>Progress: {progress}</Text>
            <Button title={isPlaying ? 'Pause' : 'Play'} onPress={isPlaying ? pause : play} />
            <Button title="Stop" onPress={stop} />
            <Button title="Seek Forward" onPress={seekForward} />
            <Button title="Seek Backward" onPress={seekBackward} />
        </View>
    );
};

export default App;
```

For more detailed usage and advanced configurations, refer to the official documentation.
