//
//  Wire.m
//  
//
//  Created by Vyacheslav Beltyukov on 18/01/2023.
//

#import <Foundation/Foundation.h>

@interface PBWiringLauncher : NSObject

@end

@implementation PBWiringLauncher

+ (void)load {
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
