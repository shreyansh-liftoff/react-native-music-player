# `usePlayer` React Native Hook

`usePlayer` is a custom React hook that provides audio playback functionality for React Native applications. It allows you to control audio playback, including play, pause, stop, and seek (both forward and backward). The hook is designed to work with both Android and iOS using native modules for audio control and event handling.

---

## Features

- Play, pause, and stop audio.
- Seek forward and backward by a customizable interval.
- Tracks the progress of the audio playback.
- Supports both Android and iOS platforms.
- Auto-play feature on initialization (optional).
- Supports providing track metadata (title, artist, album, artwork).
- Efficient event handling for audio progress and state changes.

---

## Installation

Before using this hook, ensure that your project is set up to use native modules. You can install the `@shreyanshsingh/react-native-audio-player` package using npm or yarn:

```sh
npm install @shreyanshsingh/react-native-audio-player
