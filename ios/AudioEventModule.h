//
//  AudioEventModule.h
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

@interface AudioEventModule : RCTEventEmitter <RCTBridgeModule>

+ (instancetype)sharedInstance;

/**
 * Emits an event to notify about audio state changes.
 *
 * @param state The new state of the audio player.
 * @param message An optional message providing additional details about the state change.
 */
- (void)emitStateChange:(NSString *)state message:(NSString *)message;

/**
 * Emits an event to update progress of the audio playback.
 *
 * @param progress The progress of the audio playback as a fraction (0.0 to 1.0).
 * @param currentTime The current playback time in seconds.
 * @param totalDuration The total duration of the audio in seconds.
 */
- (void)emitProgressUpdate:(double)progress currentTime:(double)currentTime totalDuration:(double)totalDuration;

@end
