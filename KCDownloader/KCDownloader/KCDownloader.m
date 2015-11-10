//
//  KCDownloader.m
//  KCDownloader
//
//  Created by Tran Vinh Kinh on 11/10/15.
//  Copyright © 2015 Keeley Soft. All rights reserved.
//

#import "KCDownloader.h"

@interface KCDownloader()<NSURLConnectionDelegate>{
    bool releaseAfterFinishDownload;
    NSString *downloadLink;
    NSString *downloadedFilePath;
    bool createPathIfNotExist;
    
    NSURLConnection *currentConnection;
    NSMutableData *receivedData;
    long totalBytes;
}

@end

@implementation KCDownloader

@synthesize releaseAfterFinishDownload, downloadLink, downloadedFilePath, createPathIfNotExist;
@synthesize delegate;

#pragma mark - Initial

- (id) init{
    self = [super init];
    if (self) {
        // init default configuration
        releaseAfterFinishDownload = NO;
        downloadLink = nil;
        downloadedFilePath = nil;
        createPathIfNotExist = NO;
    }
    return self;
}

- (id) initWithDownloadLink:(NSString *)link{
    self = [self init];
    if (self) {
        self.downloadLink = link;
    }
    return self;
}

- (id)initWithDownloadLink:(NSString *)link SaveToPath:(NSString *)path{
    self = [self init];
    if (self) {
        self.downloadLink = link;
        self.downloadedFilePath = path;
    }
    return self;
}

#pragma mark - Functions

- (void) startDownload{
    NSURL *currentURL = [NSURL URLWithString:downloadLink];
    if (currentURL && downloadLink) {
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:currentURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
        
        if (currentConnection) {
            [currentConnection release];
            currentConnection = nil;
        }
        [self resetDownloader];
        
        receivedData = [[NSMutableData alloc] initWithLength:0];

        currentConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self     startImmediately:YES];
        
        if (delegate && [delegate respondsToSelector:@selector(KC_didStartDownload:)]) {
            [delegate KC_didStartDownload:self];
        }
    }
    else{
        if (delegate && [delegate respondsToSelector:@selector(KC_didFailToConnect:WithError:)]) {
            NSError *error = [KCDownloader generateErrorWithDomain:KCDOWNLOADER_ERROR_DOMAIN Code:KCDOWNLOADER_ERROR_NO_LINK Description:@"Download link not set or bad link"];
            [delegate KC_didFailToConnect:self WithError:error];
        }
    }
}

- (void) cancelDownload{
    if (currentConnection) {
        [currentConnection cancel];
        [currentConnection release];
        currentConnection = nil;
    }
    
    if (delegate && [delegate respondsToSelector:@selector(KC_didCancelDownload:)]) {
        [delegate KC_didCancelDownload:self];
    }
}

- (void) resetDownloader{
    if (receivedData) {
        [receivedData release];
        receivedData = nil;
    }
    
    totalBytes = 0;
}

#pragma mark - NSURLConnectionDelegate + NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"connection did fail with error: %@", error.description);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [receivedData setLength:0];
    totalBytes = [response expectedContentLength];
    
    if (delegate && [delegate respondsToSelector:@selector(KC_didConnect:TotalBytes:)]) {
        [delegate KC_didConnect:self TotalBytes:totalBytes];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
    
    float percent = (float)[receivedData length] / (float)totalBytes;
    
    if (delegate && [delegate respondsToSelector:@selector(KC_didDownload:ReceivedBytes:Percentage:)]) {
        [delegate KC_didDownload:self ReceivedBytes:[receivedData length] Percentage:percent];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (delegate && [delegate respondsToSelector:@selector(KC_didFinishDownload:WithData:)]) {
        [delegate KC_didFinishDownload:self WithData:receivedData];
    }
    
    if (downloadedFilePath && downloadedFilePath.length>1) {
        NSRange slashRange = [downloadedFilePath rangeOfString:@"/" options:NSBackwardsSearch];
        if (slashRange.location != NSNotFound) {
            NSString *folderPath = [downloadedFilePath substringToIndex:slashRange.location];
            bool isFolder = NO;
            bool folderExist = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isFolder];
            if (folderExist==NO) {
                if (createPathIfNotExist==NO) {
                    if (delegate && [delegate respondsToSelector:@selector(KC_didFailToWriteDownloadedFileToPath:WithError:)]) {
                        NSError *err = [KCDownloader generateErrorWithDomain:KCDOWNLOADER_ERROR_DOMAIN Code:KCDOWNLOADER_ERROR_PATH_NOT_FOUND Description:@"Folder path not exist"];
                        [delegate KC_didFailToWriteDownloadedFileToPath:downloadedFilePath WithError:err];
                    }
                }
                else{
                    NSError *errCreate = nil;
                    bool createResult = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&errCreate];
                    if (createResult) {
                        [self saveFile:downloadedFilePath WithData:receivedData];
                        if (delegate && [delegate respondsToSelector:@selector(KC_didWriteDownloadedFileToPath:)]) {
                            [delegate KC_didWriteDownloadedFileToPath:downloadedFilePath];
                        }
                    }
                    else{
                        if (delegate && [delegate respondsToSelector:@selector(KC_didFailToWriteDownloadedFileToPath:WithError:)]) {
                            NSError *err = [KCDownloader generateErrorWithDomain:KCDOWNLOADER_ERROR_DOMAIN Code:KCDOWNLOADER_ERROR_UNKNOWN Description:@"Cannot create folder with given file path"];
                            [delegate KC_didFailToWriteDownloadedFileToPath:downloadedFilePath WithError:err];
                        }
                    }
                }
            }
            else{
                if (isFolder) {
                    [self saveFile:downloadedFilePath WithData:receivedData];
                    if (delegate && [delegate respondsToSelector:@selector(KC_didWriteDownloadedFileToPath:)]) {
                        [delegate KC_didWriteDownloadedFileToPath:downloadedFilePath];
                    }
                }
            }
            
        }
    }
    
    if (releaseAfterFinishDownload) {
        [currentConnection release];
        currentConnection = nil;
        
        [self resetDownloader];
    }
}

- (void) saveFile:(NSString *) filePath WithData:(NSData *) fileData{
    [fileData writeToFile:filePath atomically:fileData];
}

#pragma mark - Utilities

+ (NSError *) generateErrorWithDomain:(NSString *) errDomain Code:(int) errCode Description:(NSString *) errDesc{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errDesc };
    
    NSError *error = [NSError errorWithDomain:errDomain
                                         code:errCode
                                     userInfo:userInfo];
    
    return error;
}

@end
