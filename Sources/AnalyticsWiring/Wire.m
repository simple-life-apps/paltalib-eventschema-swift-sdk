//
//  Wire.m
//  
//
//  Created by Vyacheslav Beltyukov on 18/01/2023.
//

#import "Wire.h"

@implementation PBWiringLauncher

+ (void)wire {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    NSBundle* bundle = [NSBundle bundleForClass:self];
    
    if ([bundle.bundlePath hasSuffix:@"xctest"]) {
        return;
    }
    
    Class class = [bundle classNamed:@"PBEventsWiring"];
    [[[class alloc] init] performSelector:@selector(wireStack)];
#pragma GCC diagnostic pop
}

@end
