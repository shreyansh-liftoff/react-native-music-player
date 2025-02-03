//
//  CacheModule.mm
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

#import <Foundation/Foundation.h>
#import <os/log.h>

@interface CacheModule : NSObject

+ (instancetype)sharedInstance;
- (NSURL *)getCachedFileForKey:(NSString *)key;
- (void)cacheFile:(NSURL *)url forKey:(NSString *)key;

@end

@implementation CacheModule {
    NSCache<NSString *, NSURL *> *_cache;
}

+ (instancetype)sharedInstance {
    static CacheModule *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (NSURL *)getCachedFileForKey:(NSString *)key {
    NSURL *cachedURL = [_cache objectForKey:key];
    if (cachedURL) {
        os_log(OS_LOG_DEFAULT, "Cache hit for key: %{public}@", key);
        return cachedURL;
    }
    os_log(OS_LOG_DEFAULT, "Cache miss for key: %{public}@", key);
    return nil;
}

- (void)cacheFile:(NSURL *)url forKey:(NSString *)key {
    [_cache setObject:url forKey:key];
    os_log(OS_LOG_DEFAULT, "Cached file for key: %{public}@", key);
}

@end