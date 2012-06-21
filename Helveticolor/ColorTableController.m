//
//  ColorTableController.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/23/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "ColorTableController.h"

@implementation ColorTableController

static NSString * const MODULE_NAME = @"com.pjbeardsley.Helveticolor";

@synthesize colors;

- (void)awakeFromNib {
    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setHTTPMethod:@"GET"];
//    [request setURL:[NSURL URLWithString:@"http://www.colourlovers.com/api/palettes/random"]];
//    
//    NSError *error = [[NSError alloc] init];
//    NSHTTPURLResponse *responseCode = nil;
//    
//    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
//    
//    
//    if([responseCode statusCode] == 200){
//
//    
//        NSString *colorXml = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
//        
//        NSLog(@"%@", colorXml);
//
//    } else {
//
//        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName: MODULE_NAME];    
//        self.colors = [NSMutableArray arrayWithArray:[defaults arrayForKey: @"colors"]];
//    }
    
}


@end
