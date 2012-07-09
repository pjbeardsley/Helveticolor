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
static int const    PALETTE_CHANGE_INTERVAL = -60;

static NSString * const MODULE_NAME = @"com.pjbeardsley.Helveticolor";

static NSString * const SHOW_PALETTES_TYPE_DEFAULTS_KEY = @"ShowPalettesType";

static int const SHOW_PALETTES_TYPE_TOP    = 0;
static int const SHOW_PALETTES_TYPE_NEW    = 1;
static int const SHOW_PALETTES_TYPE_RANDOM = 2;

static NSString * const TOP_PALETTES_URL   = @"http://www.colourlovers.com/api/palettes/top";
static NSString * const NEW_PALETTES_URL   = @"http://www.colourlovers.com/api/palettes/new";
static NSString * const RANDOM_PALETTE_URL = @"http://www.colourlovers.com/api/palettes/random";


@synthesize curColorIndex;
@synthesize curPaletteIndex;
@synthesize configSheet;
@synthesize showPaletteTypePopUpButton;
@synthesize colors;
@synthesize palettes;
@synthesize paletteLastChanged;
@synthesize firstTime;

- (void)refreshPaletteListForType:(int) showPalettesType
{
    [self.palettes removeAllObjects];
    
    NSURL *url = nil;
    switch (showPalettesType)
    {
        case SHOW_PALETTES_TYPE_NEW:
            url = [NSURL URLWithString: NEW_PALETTES_URL];
            break;
        case SHOW_PALETTES_TYPE_RANDOM:
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
        NSXMLNode *curNode = nil;
        while (curNode = [e nextObject]) {
            [self.palettes addObject:[[[Palette alloc]initWithXMLNode: curNode] autorelease]];
        }
                
        
    } else {
        
        NSMutableArray *defaultColors = [NSMutableArray array];
            
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"2F798C"] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"463E3B"] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"B5AA2A"] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"BA591D"] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"E77D90"] autorelease]];    
    
        Palette *defaultPalette = [[[Palette alloc] initWithArray: defaultColors] autorelease];
        defaultPalette.title = @"";
        defaultPalette.userName = @"";
        
        [self.palettes addObject: defaultPalette];
    }
            
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self) {
                
        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MODULE_NAME];
        
        // Register our default values
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:SHOW_PALETTES_TYPE_TOP], SHOW_PALETTES_TYPE_DEFAULTS_KEY,
                                    nil]];   
        
        
        self.colors = [NSMutableArray array];
        self.palettes = [NSMutableArray array];

        [self refreshPaletteListForType:[[defaults objectForKey: SHOW_PALETTES_TYPE_DEFAULTS_KEY] intValue]];

        [self setAnimationTimeInterval: ANIMATION_TIME_INTERVAL];
    }
    
    self.curPaletteIndex = 0;
    self.paletteLastChanged = [NSDate date];
    self.curColorIndex = -1;
    self.firstTime = YES;
    
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
    
    if (self.firstTime) {
        Color *backgroundColor = [[[Color alloc]initWithHexValue: @"000000"] autorelease];
        
        [self drawFrameWithBackgroundColor:backgroundColor mainText:@"Helveticolor" secondaryText:@""];
        
        self.firstTime = NO;
        return;
    }
    
    if ((self.paletteLastChanged != nil) && ([self.paletteLastChanged timeIntervalSinceNow] <= PALETTE_CHANGE_INTERVAL)) {
        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MODULE_NAME];
        
        if ([[defaults objectForKey: SHOW_PALETTES_TYPE_DEFAULTS_KEY] intValue] == SHOW_PALETTES_TYPE_RANDOM) {
            [self refreshPaletteListForType:SHOW_PALETTES_TYPE_RANDOM];
            self.curColorIndex = -1;
        } else {
            self.curPaletteIndex++;
            if (self.curPaletteIndex == [self.palettes count]) {
                self.curPaletteIndex = 0;
            }
        }
        
        self.paletteLastChanged = [NSDate date];
    }
    
    Palette *palette = [self.palettes objectAtIndex: self.curPaletteIndex];
    
    self.curColorIndex++;
    if (self.curColorIndex == [palette.colors count]) {
        self.curColorIndex = -1;
        [self drawFullPaletteFrame:palette];
        return;
    }

    Color *color = (Color *)[palette.colors objectAtIndex: self.curColorIndex];    

    NSString *hexColorString = [[NSString stringWithString: @"#"] stringByAppendingString: color.hexValue];
    
    [self drawFrameWithBackgroundColor:color mainText:hexColorString secondaryText:[palette.title lowercaseString]];
}


- (void) drawFullPaletteFrame: (Palette *)palette
{
    NSSize size = [self bounds].size;
    int stepSize = round(size.width / 5);
    int curXPos = 0;

    NSEnumerator *e = [palette.colors objectEnumerator];
    
    Color *curColor = nil;
    while (curColor = [e nextObject]) {
                
        NSRect rect;
        rect.origin.x = curXPos;
        rect.origin.y = 0;
        rect.size = NSMakeSize(stepSize, size.height);

        NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];

        [[curColor colorValue] set];

        [path fill];

        NSColor *textColor;
        if ([[curColor hexValue] uppercaseString] == @"FFFFFF") {
            textColor = [NSColor blackColor];
        } else {
            textColor = [NSColor whiteColor];
        }
        
        
        int font_size = (int)(rect.size.height * 0.04);
        
        NSDictionary *mainTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSFont fontWithName:@"Helvetica" size:font_size], NSFontAttributeName,
                                            textColor, NSForegroundColorAttributeName,
                                            nil];
        
        NSString *hexColorString = [[NSString stringWithString: @"#"] stringByAppendingString: curColor.hexValue];        
        NSAttributedString *mainAttributedText = [[[NSAttributedString alloc] initWithString: hexColorString attributes: mainTextAttributes] autorelease];
                
        int y_offset = (curXPos + stepSize) * -1;

        // draw text
        [NSGraphicsContext saveGraphicsState];

        NSAffineTransform *rotateTransform = [NSAffineTransform transform];

        CGFloat degrees = 90;
        [rotateTransform rotateByDegrees:degrees];
        [rotateTransform concat];

        [mainAttributedText drawAtPoint:NSMakePoint(rect.size.height * 0.01, y_offset)];
        
        [NSGraphicsContext restoreGraphicsState];

        curXPos += stepSize;
    }
    
}


- (void) drawFrameWithBackgroundColor: (Color *)backgroundColor mainText: (NSString *)mainText secondaryText: (NSString *)secondaryText
{
    // draw the background
    NSSize size = [self bounds].size;
    
    NSRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size = NSMakeSize(size.width, size.height);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    
    [[backgroundColor colorValue] set];
    [path fill];
    
    NSColor *textColor;
    if ([[backgroundColor hexValue] uppercaseString] == @"FFFFFF") {
        textColor = [NSColor blackColor];
    } else {
        textColor = [NSColor whiteColor];
    }
    
    // draw primary text
    int font_size = (int)(rect.size.height * 0.25);
    
    NSDictionary *mainTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSFont fontWithName:@"Helvetica" size:font_size], NSFontAttributeName,
                                        textColor, NSForegroundColorAttributeName,
                                        nil];
    
    NSAttributedString *mainAttributedText = [[[NSAttributedString alloc] initWithString: mainText attributes: mainTextAttributes] autorelease];
    
    NSSize attrSize = [mainAttributedText size];
    int x_offset = (rect.size.width / 2) - (attrSize.width / 2);
    int y_offset = (rect.size.height / 2) - (attrSize.height / 2);
    
    [mainAttributedText drawAtPoint:NSMakePoint(x_offset, y_offset)];
    
    // draw secondary text
    font_size = (int)(rect.size.height * 0.04);
    NSDictionary *secondaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSFont fontWithName:@"Helvetica" size:font_size], NSFontAttributeName,
                                             textColor, NSForegroundColorAttributeName,
                                             nil];
    
    NSAttributedString *secondaryAttributedText = [[[NSAttributedString alloc] initWithString: secondaryText attributes: secondaryTextAttributes] autorelease];
    attrSize = [secondaryAttributedText size];
    
    
    x_offset = size.width - attrSize.width - 10;
    y_offset = 5;
    [secondaryAttributedText drawAtPoint:NSMakePoint(x_offset, y_offset)];
    
}


- (void) drawFrameWithBackgroundColorCG: (Color *)backgroundColor mainText: (NSString *)mainText secondaryText: (NSString *)secondaryText
{
    // draw the background
    NSSize size = [self bounds].size;
    
    NSRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size = NSMakeSize(size.width, size.height);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    
    [[backgroundColor colorValue] set];
    [path fill];
            
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);

    int fontSize = (int)(size.height * 0.25);
    CTFontDescriptorRef fd = CTFontDescriptorCreateWithNameAndSize(CFSTR("Helvetica"), fontSize);
    CTFontRef font = CTFontCreateWithFontDescriptor(fd, fontSize, NULL);
        
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (__bridge CFStringRef) mainText);

    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, [mainText length]), kCTFontAttributeName, font);

    // Create a color and add it as an attribute to the string.
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = { 1.0, 1.0, 1.0, 1.0 };
    CGColorRef white = CGColorCreate(rgbColorSpace, components);
    CGColorSpaceRelease(rgbColorSpace);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, [mainText length]), kCTForegroundColorAttributeName, white);
    
    CTLineRef line = CTLineCreateWithAttributedString(attrString);

    float flush = 0.5; // centered
    double penOffset = CTLineGetPenOffsetForFlush(line, flush, size.width);

    // Set text position and draw the line into the graphics context
    CGContextSetTextPosition(context, penOffset, (size.height / 2.0));
    
    CTLineDraw(line, context);
    CFRelease(line);

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

    [self.showPaletteTypePopUpButton removeAllItems];
    [self.showPaletteTypePopUpButton addItemWithTitle: @"Top Palettes"];
    [self.showPaletteTypePopUpButton addItemWithTitle: @"Newest Palettes"];
    [self.showPaletteTypePopUpButton addItemWithTitle: @"Random Palettes"];
    
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName: MODULE_NAME];
    [self.showPaletteTypePopUpButton selectItemAtIndex:[[defaults objectForKey: SHOW_PALETTES_TYPE_DEFAULTS_KEY] intValue]];
    
	return self.configSheet;
}


- (IBAction)okClick:(id)sender
{
    
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName: MODULE_NAME];
    
    // Update our defaults
    [defaults setObject:[NSNumber numberWithInt:[self.showPaletteTypePopUpButton indexOfSelectedItem]] forKey:SHOW_PALETTES_TYPE_DEFAULTS_KEY];
    
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
