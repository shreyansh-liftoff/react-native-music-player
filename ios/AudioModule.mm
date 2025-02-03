//
//  AudioModule.mm
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import <os/log.h>
#import "FileModule.h"
#import "AudioEventModule.h"

@interface AudioModule : NSObject <RCTBridgeModule, AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, assign) NSTimeInterval currentPlaybackPosition;
@property (nonatomic, strong) NSURL *audioURL;
@end

@implementation AudioModule

RCT_EXPORT_MODULE();

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpSession];
    }
    return self;
}

- (void)setUpSession {
    @try {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        if ([session respondsToSelector:@selector(setCategory:mode:options:error:)]) {
            [session setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:0 error:nil];
        } else {
            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        }
        [session setActive:YES error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

RCT_EXPORT_METHOD(setMediaPlayerInfo:(NSString *)title artist:(NSString *)artist album:(NSString *)album duration:(NSString *)duration) {
    NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary dictionary];
    nowPlayingInfo[MPMediaItemPropertyTitle] = title;
    nowPlayingInfo[MPMediaItemPropertyArtist] = artist;
    nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album;
    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration;
    nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = @1.0;
    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @0.0;

    // Log the nowPlayingInfo dictionary
    os_log(OS_LOG_DEFAULT, "Now Playing Info: %@", nowPlayingInfo.description);

    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
}

RCT_EXPORT_METHOD(downloadAndPlayAudio:(NSURL *)remoteURL resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  [[FileModule sharedInstance] downloadFileFromURL:remoteURL completion:^(NSURL *localURL, NSError *error) {
        if (error) {
            rejecter(@"DOWNLOAD_ERROR", @"Failed to download audio", error);
        } else {
            self.audioURL = localURL;
            [self playAudioFrom:localURL];
            resolver(localURL.absoluteString);
        }
    }];
}

RCT_EXPORT_METHOD(playAudioFrom:(NSURL *)url) {
    @try {
        if (self.audioPlayer) {
            [self.audioPlayer pause];
        }
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.currentTime = self.currentPlaybackPosition;
        [self.audioPlayer play];
        self.isPlaying = YES;
        [[AudioEventModule sharedInstance] emitStateChange:@"playing" message:@""];
        [self startProgressUpdates];
        [self setupMediaPlayerNotificationView];
    } @catch (NSException *exception) {
        os_log(OS_LOG_DEFAULT, "Error initializing audio player: %@", exception.reason);
        [[AudioEventModule sharedInstance] emitStateChange:@"error" message:exception.reason];
    }
}

RCT_EXPORT_METHOD(pauseAudio) {
    self.currentPlaybackPosition = self.audioPlayer.currentTime;
    [self.audioPlayer pause];
    self.isPlaying = NO;
    [[AudioEventModule sharedInstance] emitStateChange:@"paused" message:@""];
    [self stopProgressUpdates];
}

RCT_EXPORT_METHOD(stopAudio) {
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    self.isPlaying = NO;
    self.currentPlaybackPosition = 0.0;
    [[AudioEventModule sharedInstance] emitStateChange:@"stopped" message:@""];
    [self stopProgressUpdates];
}

RCT_EXPORT_METHOD(seek:(double)timeInSeconds) {
    if (self.audioPlayer) {
        self.currentPlaybackPosition = timeInSeconds;
        self.audioPlayer.currentTime = timeInSeconds;
        [self sendProgressUpdate];
        [[AudioEventModule sharedInstance] emitStateChange:@"seeking" message:[NSString stringWithFormat:@"Seeked to %f seconds", timeInSeconds]];
    }
}

RCT_EXPORT_METHOD(getTotalDuration:(NSURL *)remoteURL resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
    [[FileModule sharedInstance] downloadFileFromURL:remoteURL completion:^(NSURL *localURL, NSError *error) {
        if (error) {
            rejecter(@"DOWNLOAD_ERROR", @"Failed to download audio", error);
        } else {
            @try {
                self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:localURL error:nil];
                [self.audioPlayer prepareToPlay];
                NSTimeInterval duration = self.audioPlayer.duration;
                if (duration != 0) {
                    resolver(@(duration));
                } else {
                    rejecter(@"ERROR", @"Failed to retrieve total duration", nil);
                }
            } @catch (NSException *exception) {
                rejecter(@"ERROR", @"Failed to initialize audio player", nil);
            }
        }
    }];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [[AudioEventModule sharedInstance] emitStateChange:@"completed" message: @""];
        [self stopProgressUpdates];
    } else {
        [[AudioEventModule sharedInstance] emitStateChange:@"error" message:@"Playback failed"];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    if (error) {
        os_log(OS_LOG_DEFAULT, "Audio decode error: %@", error.localizedDescription);
        [[AudioEventModule sharedInstance] emitStateChange:@"error" message:error.localizedDescription];
    }
}

- (void)setupMediaPlayerNotificationView {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

    commandCenter.playCommand.enabled = YES;
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [self playAudioFrom:self.audioURL];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    commandCenter.pauseCommand.enabled = YES;
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [self pauseAudio];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    commandCenter.stopCommand.enabled = YES;
    [commandCenter.stopCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [self stopAudio];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

- (void)startProgressUpdates {
    [self stopProgressUpdates];

    os_log(OS_LOG_DEFAULT, "Attempting to start progress update timer...");

    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (!self.audioPlayer.isPlaying) {
                os_log(OS_LOG_DEFAULT, "Audio player is not playing, skipping progress update");
                [self stopProgressUpdates];
                return;
            }

            os_log(OS_LOG_DEFAULT, "Timer fired - Current time: %.2f", self.audioPlayer.currentTime);
            [self sendProgressUpdate];
        }];

        if (self.progressTimer) {
            [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
            os_log(OS_LOG_DEFAULT, "Successfully created and scheduled timer");
        } else {
            os_log(OS_LOG_DEFAULT, "Failed to create timer");
        }
    });
}

- (void)stopProgressUpdates {
    if (self.progressTimer) {
        [self.progressTimer invalidate];
        os_log(OS_LOG_DEFAULT, "Timer invalidated");
    }
    self.progressTimer = nil;
}

- (void)sendProgressUpdate {
    if (self.audioPlayer) {
        double progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
        double currentTime = self.audioPlayer.currentTime;
        double totalDuration = self.audioPlayer.duration;
        [[AudioEventModule sharedInstance] emitProgressUpdate:progress currentTime:currentTime totalDuration:totalDuration];
    }
}

- (void)dealloc {
    self.audioPlayer = nil;
}

@end
