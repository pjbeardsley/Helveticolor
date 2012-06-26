//
//  HelveticolorView.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/3/12.
//  Copyright (c) 2012 Peter Beardsley. All rights reserved.
//

#import "HelveticolorView.h"
#import "Color.h"
#import "Palette.h"

@implementation HelveticolorView

static double const ANIMATION_TIME_INTERVAL = 3.0;
static int const PALETTE_CHANGE_INTERVAL = -30;
static int const PALETTE_LIST_REFRESH_INTERVAL   = -600;

static NSString * const MODULE_NAME = @"com.pjbeardsley.Helveticolor";

static NSString * const TOP_PALETTES_URL   = @"http://www.colourlovers.com/api/palettes/top";
static NSString * const NEW_PALETTES_URL   = @"http://www.colourlovers.com/api/palettes/new";
static NSString * const RANDOM_PALETTE_URL = @"http://www.colourlovers.com/api/palettes/random";

@synthesize curColorIndex;
@synthesize curPaletteIndex;
@synthesize configSheet;
@synthesize colors;
@synthesize palettes;
@synthesize paletteListLastChanged;
@synthesize paletteListLastUpdated;

- (void)refreshPaletteList
{
    [self.palettes removeAllObjects];

    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MODULE_NAME];
    
    NSLog(@"!!pcb debug: %@", [defaults integerForKey:@"ShowPalettes"]);
    NSURL *url;
    switch ([defaults integerForKey:@"ShowPalettes"])
    {
        case 1:
            url = [NSURL URLWithString: NEW_PALETTES_URL];
            break;
        case 2:
            url = [NSURL URLWithString: RANDOM_PALETTE_URL];
            break;
        default:
            url = [NSURL URLWithString: TOP_PALETTES_URL];
            
    }

    NSError *error = nil;
    NSXMLDocument *xmlDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error] autorelease];
   
    if (nil != xmlDoc){
        NSArray *paletteNodes = [xmlDoc nodesForXPath:@"palettes/palette" error:&error];
        NSEnumerator *e = [paletteNodes objectEnumerator];
        NSXMLNode *curNode;
        while (curNode = [e nextObject]) {
            [self.palettes addObject:[[[Palette alloc]initWithXMLNode: curNode] autorelease]];
        }
                
        
    } else {
        
        NSMutableArray *defaultColors = [[NSMutableArray alloc] autorelease];
        
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"2F798C"] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"463E3B"] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"B5AA2A"] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"BA591D"] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"E77D90"] autorelease]];
        
        [self.palettes addObject: [[[Palette alloc] initWithArray: defaultColors] autorelease]];
    }
    
    self.paletteListLastUpdated = [NSDate date];
        
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self) {
        
        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MODULE_NAME];
        
        // Register our default values
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    @"0", @"ShowPalettes",
                                    nil]];        
        self.colors = [NSMutableArray array];
        self.palettes = [NSMutableArray array];
        
        [self refreshPaletteList];
        
        [self setAnimationTimeInterval: ANIMATION_TIME_INTERVAL];
    }
    
    self.curPaletteIndex = 0;
    self.paletteListLastChanged = [NSDate date];
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
    if (self.paletteListLastUpdated != nil) {
        if ([self.paletteListLastUpdated timeIntervalSinceNow] <= PALETTE_LIST_REFRESH_INTERVAL) {
            [self refreshPaletteList];
        }
    }
    
    if (self.paletteListLastChanged != nil) {
    
        if ([self.paletteListLastChanged timeIntervalSinceNow] <= PALETTE_CHANGE_INTERVAL) {
            self.curPaletteIndex++;
            if (self.curPaletteIndex == [self.palettes count]) {
                self.curPaletteIndex = 0;
            }
            self.paletteListLastChanged = [NSDate date];

        }
    }
    Palette *palette = [self.palettes objectAtIndex: self.curPaletteIndex];
    
    Color *color = (Color *)[palette.colors objectAtIndex: self.curColorIndex];    
    
    NSString *hexColorString = [[NSString stringWithString: @"#"] stringByAppendingString: [color hexValue]];
    
    self.curColorIndex++;
    if (self.curColorIndex == [palette.colors count]) {
        self.curColorIndex = 0;
    }
    
    NSColor *colorValue = [color colorValue];
    
    // draw the background
    NSSize size = [self bounds].size;
    
    NSRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size = NSMakeSize(size.width, size.height);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];

    [colorValue set];    
    [path fill];
    
    // draw hex color

    int font_size = (int)(rect.size.height * 0.25);
    
    NSDictionary *hexColorAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSFont fontWithName:@"Helvetica" size:font_size], NSFontAttributeName,
                                        [NSColor whiteColor], NSForegroundColorAttributeName,
                                        nil];
    
    NSAttributedString *hexColorText = [[[NSAttributedString alloc] initWithString: hexColorString attributes: hexColorAttributes] autorelease];
    
    NSSize attrSize = [hexColorText size];
    int x_offset = (rect.size.width / 2) - (attrSize.width / 2);
    int y_offset = (rect.size.height / 2) - (attrSize.height / 2);
    
    [hexColorText drawAtPoint:NSMakePoint(x_offset, y_offset)];
    
    // draw palette title
    font_size = (int)(rect.size.height * 0.04);

    NSDictionary *paletteTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSFont fontWithName:@"Helvetica" size:font_size], NSFontAttributeName,
                                            [NSColor whiteColor], NSForegroundColorAttributeName,
                                            nil];
    
    NSAttributedString *paletteTitleText = [[[NSAttributedString alloc] initWithString: palette.title attributes: paletteTitleAttributes] autorelease];
    attrSize = [paletteTitleText size];

    
    x_offset = size.width - attrSize.width - 10;
    y_offset = 5;
    [paletteTitleText drawAtPoint:NSMakePoint(x_offset, y_offset)];
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
