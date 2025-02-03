//
//  AudioModule.h
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioModule : NSObject <RCTBridgeModule, AVAudioPlayerDelegate>

/**
 * Configures the media player info for lock screen and notification controls.
 *
 * @param title The title of the audio.
 * @param artist The artist of the audio.
 * @param album The album name of the audio.
 * @param duration The total duration of the audio as a string.
 */
- (void)setMediaPlayerInfo:(NSString *)title artist:(NSString *)artist album:(NSString *)album duration:(NSString *)duration;

/**
 * Downloads an audio file from a remote URL and plays it.
 *
 * @param remoteURL The remote URL of the audio file.
 * @param resolver A promise resolve block for returning the local URL of the downloaded audio file.
 * @param rejecter A promise reject block for handling download errors.
 */
- (void)downloadAndPlayAudio:(NSURL *)remoteURL resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter;

/**
 * Plays an audio file from the specified local URL.
 *
 * @param url The local URL of the audio file.
 */
- (void)playAudioFrom:(NSURL *)url;

/**
 * Pauses the currently playing audio.
 */
- (void)pauseAudio;

/**
 * Stops the audio playback and resets the state.
 */
- (void)stopAudio;

/**
 * Seeks to a specific time in the audio playback.
 *
 * @param timeInSeconds The time in seconds to seek to.
 */
- (void)seek:(double)timeInSeconds;

/**
 * Retrieves the total duration of an audio file.
 *
 * @param remoteURL The remote URL of the audio file.
 * @param resolver A promise resolve block for returning the duration of the audio in seconds.
 * @param rejecter A promise reject block for handling errors during the duration retrieval process.
 */
- (void)getTotalDuration:(NSURL *)remoteURL resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter;

@end
