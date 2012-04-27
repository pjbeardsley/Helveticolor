//
//  HelveticolorView.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/3/12.
//  Copyright (c) 2012 Peter Beardsley. All rights reserved.
//

#import "HelveticolorView.h"

@implementation HelveticolorView

static NSString * const MODULE_NAME = @"com.pjbeardsley.Helveticolor";

@synthesize curColorIndex;
@synthesize colorTableController;
@synthesize configSheet;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self) {
        
        NSMutableArray * default_colors = [NSMutableArray array];
        
        [default_colors addObject: @"2F798C"];
        [default_colors addObject: @"463E3B"];
        [default_colors addObject: @"B5AA2A"];
        [default_colors addObject: @"BA591D"];
        [default_colors addObject: @"E77D90"];
        
        ScreenSaverDefaults * defaults = [ScreenSaverDefaults defaultsForModuleWithName:MODULE_NAME];
        
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    default_colors, @"colors",
                                    nil]];
        
        [self setAnimationTimeInterval:3.0];
    }
    
    self.curColorIndex = 0;
    
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
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName: MODULE_NAME];
    
    NSArray *colors = [defaults arrayForKey: @"colors"];
    
    NSString *colorString = (NSString *)[colors objectAtIndex: self.curColorIndex];
    
    NSString *displayString = [[NSString stringWithString: @"#"] stringByAppendingString: colorString];
    
    self.curColorIndex++;
    if (curColorIndex == [colors count]) {
        curColorIndex = 0;
    }
    
    NSColor *color = [self colorFromHexRGB: colorString];
    
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
    
    NSAttributedString *currentText = [[NSAttributedString alloc] initWithString: displayString attributes: attributes];
    
    NSSize attrSize = [currentText size];
    int x_offset = (rect.size.width / 2) - (attrSize.width / 2);
    int y_offset = (rect.size.height / 2) - (attrSize.height / 2);
    [currentText drawAtPoint:NSMakePoint(x_offset, y_offset)];
    
    [currentText dealloc];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow *)configureSheet
{
            
    if (!self.configSheet)
	{
		if (![NSBundle loadNibNamed:@"ConfigSheet" owner:self]) 
		{
			NSLog( @"Failed to load configure sheet." );
		}
	}
    
	return self.configSheet;
}


- (IBAction)okClick:(id)sender
{
    
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName: MODULE_NAME];
    
    // Update our defaults
    [defaults setObject: [self.colorTableController colors] forKey:@"colors"];
    
    // Save the settings to disk
    [defaults synchronize];
    
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:self.configSheet];
    
}


- (IBAction)cancelClick:(id)sender
{
    [[NSApplication sharedApplication] endSheet:self.configSheet];
    
}


@end
