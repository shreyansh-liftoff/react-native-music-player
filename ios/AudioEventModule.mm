//
//  AudioEventModule.mm
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>
#import <os/log.h>

@interface RCT_EXTERN_MODULE(AudioEventModule, RCTEventEmitter)

RCT_EXTERN_METHOD(emitStateChange:(NSString *)state message:(NSString *)message)
RCT_EXTERN_METHOD(emitProgressUpdate:(double)progress currentTime:(double)currentTime totalDuration:(double)totalDuration)

@end

@implementation AudioEventModule

RCT_EXPORT_MODULE();

static AudioEventModule *sharedInstance = nil;

+ (instancetype)sharedInstance {
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        sharedInstance = self;
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onAudioStateChange", @"onAudioProgress"];
}

- (void)emitStateChange:(NSString *)state message:(NSString *)message {
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObject:state forKey:@"state"];
    if (message) {
        [event setObject:message forKey:@"message"];
    }
    os_log(OS_LOG_DEFAULT, "Sending state change event");
    [self sendEventWithName:@"onAudioStateChange" body:event];
}

- (void)emitProgressUpdate:(double)progress currentTime:(double)currentTime totalDuration:(double)totalDuration {
    NSDictionary *event = @{
        @"progress": @(progress),
        @"currentTime": @(currentTime),
        @"totalDuration": @(totalDuration)
    };
    os_log(OS_LOG_DEFAULT, "Sending progress event");
    [self sendEventWithName:@"onAudioProgress" body:event];
}

@end