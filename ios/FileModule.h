#import <Foundation/Foundation.h>

@interface FileModule : NSObject

+ (instancetype)sharedInstance;
- (void)downloadFileFromURL:(NSURL *)remoteURL completion:(void (^)(NSURL * _Nullable, NSError * _Nullable))completion;

@end