/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import { SafeAreaView, ScrollView, StyleSheet, Text, View } from 'react-native';
import usePlayer from '../../hooks/usePlayer';
import { mockAudioContent, mockTrackInfo } from '../../data/mockData';
import AudioPlayerMedia from './audioPlayerMedia';
import AudioPlayerContent from './audioPlayerContent';
import AudioPlayerDuration from './playerDuration';
import PlayerControls from './audioPlayerControls';

function Player(): React.JSX.Element {
  const {
    playSound,
    pauseSound,
    isPlaying,
    isLoading,
    totalDuration,
    progress,
    elapsedTime,
    onSeekForward,
    onSeekBackward,
  } = usePlayer({
    sourceUrl:
      'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3',
    autoPlay: false,
    trackInfo: mockTrackInfo,
  });

  const onPlay = () => {
    playSound();
  };

  const onPause = () => {
    pauseSound();
  };

  const MockContent = (
    <View style={styles.mockContent}>
      <Text style={styles.mockContentTitle}>{mockAudioContent.title}</Text>
      <Text style={styles.mockContentArtist}>{mockAudioContent.artist}</Text>
    </View>
  );

  return (
    <SafeAreaView>
      <ScrollView>
        <AudioPlayerMedia
          thumbnail={require('./assets/images/sample-image.jpg')}
        />
        <AudioPlayerContent content={MockContent} />
        <AudioPlayerDuration
          totalDuration={totalDuration}
          currentDuration={elapsedTime}
          progress={progress}
        />
        <PlayerControls
          isPlaying={isPlaying}
          onPlay={onPlay}
          onPause={onPause}
          isLoading={isLoading}
          onSeekForward={onSeekForward}
          onSeekBackward={onSeekBackward}
        />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  mockContent: {
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    textAlign: 'center',
  },
  mockContentTitle: {
    fontSize: 24,
    marginVertical: 5,
    fontWeight: 'bold',
  },
  mockContentArtist: {
    fontSize: 18,
    marginVertical: 5,
  },
});

export default Player;
