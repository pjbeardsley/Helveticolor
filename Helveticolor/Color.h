//
//  Color.h
//  Helveticolor
//
//  Created by Peter Beardsley on 4/29/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Color : NSObject <NSCoding>
{
    NSString *hexValue;
    NSNumber *width;
}

@property (copy) NSString *hexValue;
@property (copy) NSNumber *width;

- (id) initWithHexValue: (NSString *)newHexValue andWidth: (NSNumber *)width;
- (NSColor *) colorValue;
- (CGFloat) calculateColorBrightness;

@end
