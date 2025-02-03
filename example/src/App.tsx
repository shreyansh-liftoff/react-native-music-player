import { View, StyleSheet } from 'react-native';
import { usePlayerHook } from 'react-native-music-player';

export default function App() {
  const { totalDuration } = usePlayerHook({
    sourceUrl:
      'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3',
  });

  console.log('totalDuration', totalDuration);
  return <View style={styles.container} />;
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
