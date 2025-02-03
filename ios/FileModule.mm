//
//  FileModule.mm
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

#import <Foundation/Foundation.h>
#import <os/log.h>
#import "CacheModule.h"

@interface FileModule : NSObject

+ (instancetype)sharedInstance;
- (void)downloadFileFromURL:(NSURL *)remoteURL completion:(void (^)(NSURL * _Nullable, NSError * _Nullable))completion;

@end

@implementation FileModule {
    NSFileManager *_fileManager;
}

+ (instancetype)sharedInstance {
    static FileModule *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)downloadFileFromURL:(NSURL *)remoteURL completion:(void (^)(NSURL * _Nullable, NSError * _Nullable))completion {
    NSString *key = remoteURL.absoluteString;
    
    // Check cache
    NSURL *cachedURL = [[CacheModule sharedInstance] getCachedFileForKey:key];
    if (cachedURL) {
        completion(cachedURL, nil);
        return;
    }
    
    // Define destination path
    NSURL *documentsDirectory = [[_fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:remoteURL.lastPathComponent];
    
    // Check if file exists locally
    if ([_fileManager fileExistsAtPath:destinationURL.path]) {
        os_log_info(OS_LOG_DEFAULT, "File already exists locally: %{public}@", destinationURL.absoluteString);
        [[CacheModule sharedInstance] cacheFile:destinationURL forKey:key];
        completion(destinationURL, nil);
        return;
    }
    
    // Download the file
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:remoteURL completionHandler:^(NSURL * _Nullable localURL, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            os_log_error(OS_LOG_DEFAULT, "Download error: %{public}@", error.localizedDescription);
            completion(nil, error);
            return;
        }
        
        if (!localURL) {
            NSError *error = [NSError errorWithDomain:@"FileModule" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to download file."}];
            os_log_error(OS_LOG_DEFAULT, "Local URL is nil after download.");
            completion(nil, error);
            return;
        }
        
        NSError *moveError = nil;
        if (![_fileManager moveItemAtURL:localURL toURL:destinationURL error:&moveError]) {
            os_log_error(OS_LOG_DEFAULT, "Error moving downloaded file: %{public}@", moveError.localizedDescription);
            completion(nil, moveError);
            return;
        }
        
        os_log_info(OS_LOG_DEFAULT, "File downloaded to: %{public}@", destinationURL.absoluteString);
        
        // Cache the file
        [[CacheModule sharedInstance] cacheFile:destinationURL forKey:key];
        completion(destinationURL, nil);
    }];
    
    [task resume];
}

@end