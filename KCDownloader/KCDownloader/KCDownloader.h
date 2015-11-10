//
//  KCDownloader.h
//  KCDownloader
//
//  Created by Kinh Tran on 11/10/15.
//  Copyright © 2015 Keeley Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

// Error domain
#define KCDOWNLOADER_ERROR_DOMAIN   @"kcdownloader.keeleysoft.com"

// Error code for KCDownloader
#define KCDOWNLOADER_ERROR_UNKNOWN          -1
#define KCDOWNLOADER_ERROR_NO_LINK          -2
#define KCDOWNLOADER_ERROR_NOINTERNET       -3
#define KCDOWNLOADER_ERROR_404              -4
#define KCDOWNLOADER_ERROR_PATH_NOT_FOUND   -5

@protocol KCDownloaderDelegate;

@interface KCDownloader : NSObject{
    
}

@property (nonatomic)           bool releaseAfterFinishDownload;
@property (nonatomic, retain)   NSString *downloadLink;
@property (nonatomic, retain)   NSString *downloadedFilePath;
@property (nonatomic)           bool createPathIfNotExist;

@property (nonatomic, assign) id<KCDownloaderDelegate> delegate;

- (id) init;
- (id) initWithDownloadLink:(NSString *) link;
- (id) initWithDownloadLink:(NSString *) link SaveToPath:(NSString *) path;


- (void) startDownload;
- (void) cancelDownload;

@end


@protocol KCDownloaderDelegate <NSObject>

@required
- (void) KC_didStartDownload:(KCDownloader *) downloader;
- (void) KC_didCancelDownload:(KCDownloader *) downloader;

- (void) KC_didConnect:(KCDownloader *) downloader TotalBytes:(long) totalBytes;
- (void) KC_didFailToConnect:(KCDownloader *) downloader WithError:(NSError *) error;

- (void) KC_didDownload:(KCDownloader *) downloader ReceivedBytes:(long) receivedBytes Percentage:(float) percent;
- (void) KC_didFinishDownload:(KCDownloader *) downloader WithData:(NSData *) downloadedData;

@optional
- (void) KC_didWriteDownloadedFileToPath:(NSString *) filePath;
- (void) KC_didFailToWriteDownloadedFileToPath:(NSString *) filePath WithError:(NSError *) error;

@end