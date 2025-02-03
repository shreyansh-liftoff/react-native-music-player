#import <Foundation/Foundation.h>

@interface CacheModule : NSObject

+ (instancetype)sharedInstance;
- (NSURL *)getCachedFileForKey:(NSString *)key;
- (void)cacheFile:(NSURL *)url forKey:(NSString *)key;

@end