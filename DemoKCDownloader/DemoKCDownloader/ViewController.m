//
//  ViewController.m
//  DemoKCDownloader
//
//  Created by Tran Vinh Kinh on 11/10/15.
//  Copyright © 2015 Keeley Soft. All rights reserved.
//

#import "ViewController.h"
#import "KCDownloader.h"

@interface ViewController ()<KCDownloaderDelegate>{
    UILabel *lbProgress;
    UIButton *btnDownload;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    btnDownload = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDownload setBackgroundColor:[UIColor blueColor]];
    [btnDownload setTitle:@"Download" forState:UIControlStateNormal];
    [btnDownload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDownload addTarget:self action:@selector(btnDownload_tap) forControlEvents:UIControlEventTouchUpInside];
    [btnDownload setFrame:CGRectMake(self.view.frame.size.width/2 - 50, 50, 100, 50)];
    [self.view addSubview:btnDownload];
    
    
    lbProgress = [[UILabel alloc] init];
    [lbProgress setFrame:CGRectMake(20, 120, self.view.frame.size.width - 40, 50)];
    [lbProgress setTextAlignment:NSTextAlignmentCenter];
    [lbProgress setTextColor:[UIColor blackColor]];
    [self.view addSubview:lbProgress];
}

- (void) btnDownload_tap{
    KCDownloader *downloader = [[KCDownloader alloc] initWithDownloadLink:@"https://github.com/kinhchendev/KCDownloader/blob/master/ConcurrencyProgrammingGuide.pdf"];
    downloader.delegate = self;
    [downloader startDownload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KCDownloaderDelegate

- (void) KC_didStartDownload:(KCDownloader *) downloader{
    NSLog(@"KC did start download with path: %@", downloader.downloadLink);
}

- (void) KC_didCancelDownload:(KCDownloader *) downloader{
    NSLog(@"KC did cancel download with path: %@", downloader.downloadLink);
}

- (void) KC_didConnect:(KCDownloader *) downloader TotalBytes:(long) totalBytes{
    NSLog(@"KC did connect with path: %@ and total bytes: %ld", downloader.downloadLink, totalBytes);
}

- (void) KC_didFailToConnect:(KCDownloader *) downloader WithError:(NSError *) error{
    NSLog(@"KC did fail to connect with path: %@ and error: %@", downloader.downloadLink, error.description);
}

- (void) KC_didDownload:(KCDownloader *) downloader ReceivedBytes:(long) receivedBytes Percentage:(float) percent{
    NSLog(@"KC did download with path: %@ and bytes: %ld and percentage: %f", downloader.downloadLink, receivedBytes, percent);
}

- (void) KC_didFinishDownload:(KCDownloader *) downloader WithData:(NSData *) downloadedData{
    NSLog(@"KC did finish download with path: %@", downloader.downloadLink);
}

- (void) KC_didWriteDownloadedFileToPath:(NSString *) filePath{
    NSLog(@"KC did write downloaded file to path: %@", filePath);
}

- (void) KC_didFailToWriteDownloadedFileToPath:(NSString *) filePath WithError:(NSError *) error{
    NSLog(@"KC did fail to write downloaded file to path: %@ and error: %@", filePath, error.description);
}

@end
