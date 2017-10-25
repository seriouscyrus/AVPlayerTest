//
//  AVPlayerTestTests.m
//  AVPlayerTestTests
//
//  Created by George Brown on 16.02.17.
//  Copyright © 2017 Serious Cyrus. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>

@interface AVPlayerTestTests : XCTestCase

// Do we need a context?  Let's have one anyway.
@property (nonatomic)   EAGLContext *context;

@end

@implementation AVPlayerTestTests

- (void)setUp {
    [super setUp];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testAVPlayer
{
    NSDictionary *pbOptions = @{
                                (NSString *)kCVPixelBufferPixelFormatTypeKey        : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                                (NSString *)kCVPixelBufferIOSurfacePropertiesKey    : [NSDictionary dictionary],
                                (NSString *)kCVPixelBufferOpenGLESCompatibilityKey  : @YES
                                };
    AVPlayerItemVideoOutput *output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pbOptions];
    XCTAssertNotNil(output);

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"SampleVideo_1280x720_10mb" withExtension:@"mp4"];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:fileURL];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

    if (playerItem.status != AVPlayerItemStatusReadyToPlay) {
        [self keyValueObservingExpectationForObject:playerItem
                                            keyPath:@"status"
                                            handler:
         ^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
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
                     return YES;
                     break;
             }
         }];

        [self waitForExpectationsWithTimeout:100 handler:nil];
    }

    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {

        [playerItem addOutput:output];
        player.rate = 1.0;
        player.muted = YES;
        [player play];
        CMTime vTime = [output itemTimeForHostTime:CACurrentMediaTime()];
        // This is what we're testing
        BOOL foundFrame = [output hasNewPixelBufferForItemTime:vTime];
        XCTAssertTrue(foundFrame);
        if (!foundFrame) {
            // Cycle over for ten seconds
            for (int i = 0; i < 10; i++) {
                sleep(1);
                vTime = [output itemTimeForHostTime:CACurrentMediaTime()];
                foundFrame = [output hasNewPixelBufferForItemTime:vTime];
                if (foundFrame) {
                    NSLog(@"Got frame at %i", i);
                    break;
                } else {
                    NSLog(@"Current time = %f", CACurrentMediaTime());
                    NSLog(@"Calculate time = %lld", vTime.value);
                }
                if (i == 9) {
                    XCTFail(@"Failed to acquire");
                }
            }
        }

    }
}


@end
