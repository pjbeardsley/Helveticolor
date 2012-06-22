//
//  HelveticolorView.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/3/12.
//  Copyright (c) 2012 Peter Beardsley. All rights reserved.
//

#import "HelveticolorView.h"
#import "Color.h"

@implementation HelveticolorView

static double const ANIMATION_TIME_INTERVAL = 3.0;
static int const PALETTE_REFRESH_INTERVAL   = -300;

static NSString * const MODULE_NAME = @"com.pjbeardsley.Helveticolor";

static NSString * const RANDOM_PALETTE_URL = @"http://www.colourlovers.com/api/palettes/random";
static NSString * const NEW_PALETTES_URL   = @"http://www.colourlovers.com/api/palettes/new";
static NSString * const TOP_PALETTES_URL   = @"http://www.colourlovers.com/api/palettes/top";

@synthesize curColorIndex;
@synthesize configSheet;
@synthesize colors;
@synthesize colorsLastUpdated;

- (void)refreshPaletteList
{
    [self.colors removeAllObjects];
    
    NSError *error = nil;
    NSXMLDocument *xmlDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString: RANDOM_PALETTE_URL] options:0 error:&error] autorelease];
   
    if (nil != xmlDoc){
        
        NSArray *colorNodes = [xmlDoc nodesForXPath:@"palettes/palette/colors/hex" error:&error];
        
        NSEnumerator *e = [colorNodes objectEnumerator];
        NSXMLNode *curNode;
        
        while (curNode = [e nextObject]) {
            [self.colors addObject: [[[Color alloc]initWithHexValue: [curNode objectValue]] autorelease]];
        }
        
    } else {
        [self.colors addObject: [[[Color alloc]initWithHexValue: @"2F798C"] autorelease]];
        [self.colors addObject: [[[Color alloc]initWithHexValue: @"463E3B"] autorelease]];
        [self.colors addObject: [[[Color alloc]initWithHexValue: @"B5AA2A"] autorelease]];
        [self.colors addObject: [[[Color alloc]initWithHexValue: @"BA591D"] autorelease]];
        [self.colors addObject: [[[Color alloc]initWithHexValue: @"E77D90"] autorelease]];
    }
    
    self.colorsLastUpdated = [NSDate date];
        
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self) {
        self.colors = [NSMutableArray array];
        [self refreshPaletteList];
        
        [self setAnimationTimeInterval: ANIMATION_TIME_INTERVAL];
    }
    
    self.curColorIndex = 0;
    
    return self;
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
    if (self.colorsLastUpdated != nil) {
        if ([self.colorsLastUpdated timeIntervalSinceNow] <= PALETTE_REFRESH_INTERVAL) {
            [self refreshPaletteList];
        }
    }
        
    Color *color = (Color *)[self.colors objectAtIndex: self.curColorIndex];
    
    NSString *displayString = [[NSString stringWithString: @"#"] stringByAppendingString: [color hexValue]];
    
    self.curColorIndex++;
    if (curColorIndex == [self.colors count]) {
        curColorIndex = 0;
    }
    
    NSColor *colorValue = [color colorValue];
    
    NSSize size = [self bounds].size;
    
    NSRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size = NSMakeSize(size.width, size.height);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];

    [colorValue set];    
    [path fill];
    
    // calculate font point size based off screen height
    int font_size = (int)(rect.size.height * 0.25);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSFont fontWithName:@"Helvetica" size:font_size], 
                                    NSFontAttributeName,
                                    [NSColor whiteColor], 
                                    NSForegroundColorAttributeName,
                                    nil];
    
    NSAttributedString *currentText = [[[NSAttributedString alloc] initWithString: displayString attributes: attributes] autorelease];
    
    NSSize attrSize = [currentText size];
    int x_offset = (rect.size.width / 2) - (attrSize.width / 2);
    int y_offset = (rect.size.height / 2) - (attrSize.height / 2);
    [currentText drawAtPoint:NSMakePoint(x_offset, y_offset)];
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
    //[defaults setObject: [self.colorTableController colors] forKey:@"colors"];
    
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
