//
//  AppDelegate.m
//  ExampleMacAppNoARC
//
//  Created by Eric Roy on 2012-12-15.
//  Copyright (c) 2012 Example. All rights reserved.
//

#import "AppDelegate.h"
#import "TSTapstream.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [TSTapstream createWithAccountName:@"sdktest" developerSecret:@"YGP2pezGTI6ec48uti4o1w"];
    
    TSTapstream *tracker = [TSTapstream instance];
    
    
    TSEvent *e = [TSEvent eventWithName:@"test-event" oneTimeOnly:NO];
    [e addValue:@"John Doe" forKey:@"player"];
    [e addIntegerValue:5 forKey:@"score"];
    [tracker fireEvent:e];
    
    e = [TSEvent eventWithName:@"test-event-oto" oneTimeOnly:YES];
    [tracker fireEvent:e];
    
    TSHit *h = [TSHit hitWithTrackerName:@"test-tracker"];
    [h addTag:@"tag1"];
    [h addTag:@"tag2"];
    [tracker fireHit:h completion:^(TSResponse *response) {
        if (response.status >= 200 && response.status < 300)
        {
            // Success
        }
        else
        {
            // Error
        }
    }];

}

@end
