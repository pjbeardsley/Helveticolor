//
//  Color.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/29/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "Color.h"

@implementation Color

@synthesize hexValue;
@synthesize width;

- init
{
    if (self = [super init])
    {
        self.hexValue = @"000000";
        self.width = [NSNumber numberWithFloat:1.0];
    }
    
    return self;
}

- (id)initWithHexValue:(NSString *)newHexValue andWidth: (NSNumber *)newWidth
{
    if (self = [super init])
    {
        self.hexValue = newHexValue;
        self.width = newWidth;
    }
    
    return self;
    
    
}

- (NSColor *) colorValue
{
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != self.hexValue)
	{
		NSScanner *scanner = [NSScanner scannerWithString:self.hexValue];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
    
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
    
	result = [NSColor
              colorWithCalibratedRed: (float)redByte / 0xff
              green: (float)greenByte / 0xff
              blue:	(float)blueByte	/ 0xff
              alpha: 1.0];
    
	return result;
}

- (CGFloat) calculateColorBrightness
{
    return (([[self colorValue] redComponent] * 299) + ([[self colorValue] greenComponent] * 587) + ([[self colorValue] blueComponent] * 114)) / 1000.0;
}


@end
