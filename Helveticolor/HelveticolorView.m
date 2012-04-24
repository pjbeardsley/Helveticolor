//
//  HelveticolorView.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/3/12.
//  Copyright (c) 2012 Peter Beardsley. All rights reserved.
//

#import "HelveticolorView.h"

@implementation HelveticolorView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:3.0];
    }
    
    num_colors = 5;
    colors = [NSMutableArray arrayWithCapacity: num_colors];
    [colors addObject: @"2F798C"];
    [colors addObject: @"463E3B"];
    [colors addObject: @"B5AA2A"];
    [colors addObject: @"BA591D"];
    [colors addObject: @"E77D90"];
    
    cur_color_index = 0;
    
    return self;
}

- (NSColor *) colorFromHexRGB:(NSString *) inColorString
{
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
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

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    NSString *color_string = [colors objectAtIndex: cur_color_index];
    NSString *temp = [NSString stringWithString: @"#"];
    NSString *display_string = [temp stringByAppendingString: color_string];
    
    cur_color_index++;
    if (cur_color_index >= (num_colors - 1)) {
        cur_color_index = 0;
    }
    
    NSColor *color = [self colorFromHexRGB: color_string];
    
    NSSize size = [self bounds].size;
    
    NSRect rect;    
    rect.size = NSMakeSize(size.width, size.height);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];

    [color set];    
    [path fill];
    
    // calculate font point size based off screen height
    int font_size = (int)(rect.size.height * 0.25);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSFont fontWithName:@"Helvetica" size:font_size], 
                                    NSFontAttributeName,
                                    [NSColor whiteColor], 
                                    NSForegroundColorAttributeName,
                                    nil];
    
    NSAttributedString *currentText=[[NSAttributedString alloc] initWithString: display_string attributes: attributes];
    
    NSSize attrSize = [currentText size];
    int x_offset = (rect.size.width / 2) - (attrSize.width / 2);
    int y_offset = (rect.size.height / 2) - (attrSize.height / 2);
    [currentText drawAtPoint:NSMakePoint(x_offset, y_offset)];    
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    if (!configSheet)
	{
		if (![NSBundle loadNibNamed:@"ConfigSheet" owner:self]) 
		{
			NSLog( @"Failed to load configure sheet." );
		}
	}
		
	return configSheet;

}


- (IBAction)okClick:(id)sender
{
    
    
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:configSheet];
    
}


- (IBAction)cancelClick:(id)sender
{
    [[NSApplication sharedApplication] endSheet:configSheet];
    
}


@end
