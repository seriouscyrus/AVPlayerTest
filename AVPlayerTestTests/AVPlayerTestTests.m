//
//  AVPlayerTestTests.m
//  AVPlayerTestTests
//
//  Created by George Brown on 16.02.17.
//  Copyright © 2017 Serious Cyrus. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerTestTests : XCTestCase

@end

@implementation AVPlayerTestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testAVPlayer
{
    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"SampleVideo_1280x720_10mb" withExtension:@"mp4"];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:fileURL];
    [self keyValueObservingExpectationForObject:playerItem
                                        keyPath:@"status" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
                                            AVPlayerItem *oPlayerItem = (AVPlayerItem *)observedObject;
                                            switch (oPlayerItem.status) {
                                                case AVPlayerItemStatusFailed:
                                                {
                                                    XCTFail(@"Video failed");
                                                    return YES;
                                                }
                                                    break;
                                                case AVPlayerItemStatusUnknown:
                                                    return NO;
                                                    break;
                                                    case AVPlayerItemStatusReadyToPlay:
                                                {
                                                    return YES;
                                                }
                                                default:
                                                    break;
                                            }
                                        }];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    NSDictionary *pbOptions = @{
                                (NSString *)kCVPixelBufferPixelFormatTypeKey        : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                                (NSString *)kCVPixelBufferIOSurfacePropertiesKey    : [NSDictionary dictionary],
                                (NSString *)kCVPixelBufferOpenGLESCompatibilityKey  : @YES
                                };
    AVPlayerItemVideoOutput *output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pbOptions];
    XCTAssertNotNil(output);
    [self waitForExpectationsWithTimeout:100 handler:nil];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [playerItem addOutput:output];
        player.rate = 1.0;
        player.muted = YES;
        [player play];
        CMTime vTime = [output itemTimeForHostTime:CACurrentMediaTime()];
        BOOL foundFrame = [output hasNewPixelBufferForItemTime:vTime];
        XCTAssertTrue(foundFrame);
        if (!foundFrame) {
            sleep(1);
            // Cycle over for ten seconds
            for (int i = 0; i < 10; i++) {
                vTime = [output itemTimeForHostTime:CACurrentMediaTime()];
                foundFrame = [output hasNewPixelBufferForItemTime:vTime];
                if (foundFrame) {
                    NSLog(@"Got frame at %i", i);
                    break;
                } else {
                    sleep(1);
                }
            }
        }

    }
}


@end
