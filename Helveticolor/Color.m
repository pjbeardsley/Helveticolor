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

- init
{
    if (self = [super init])
    {
        hexValue = @"000000";
    }
    
    return self;
}

- (id)initWithHexValue:(NSString *)newHexValue
{
    if (self = [super init])
    {
        hexValue = newHexValue;
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
              colorWithCalibratedRed: (float)redByte	/ 0xff
              green: (float)greenByte/ 0xff
              blue:	(float)blueByte	/ 0xff
              alpha: 1.0];
    
	return result;
}


@end
