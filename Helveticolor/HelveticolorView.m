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
#import "NSAttributedString+Hyperlink.h"

@implementation HelveticolorView

static NSString * const kModuleName = @"com.pjbeardsley.Helveticolor";

static NSString * const kUserAgent        = @"Helveticolor(+http://pjbeardsley.github.com/Helveticolor)";
static NSString * const kTopPalettesUrl   = @"http://www.colourlovers.com/api/palettes/top?showPaletteWidths=1";
static NSString * const kNewPalettesUrl   = @"http://www.colourlovers.com/api/palettes/new?showPaletteWidths=1";
static NSString * const kRandomPaletteUrl = @"http://www.colourlovers.com/api/palettes/random?showPaletteWidths=1";

static NSString * const kShowPalettesTypeDefaultsKey      = @"ShowPalettesType";
static NSString * const kPaletteChangeIntervalDefaultsKey = @"PaletteChangeInterval";

static NSString * const kCacheFilePath = @"~/Library/Preferences/com.pjbeardsley.Helveticolor.plist";

static double const kAnimationTimeInterval    = 3.0;
static double const kColorBrightnessThreshold = 0.9;


typedef enum {
    kShowPalettesTop,
    kShowPalettesNew,
    kShowPalettesRandom
} ShowPalettesType;

typedef enum {
    kFullPaletteOrientationVertical,
    kFullPaletteOrientationHorizontal    
} FullPaletteOrientation;

@synthesize curColorIndex;
@synthesize curPaletteIndex;
@synthesize configSheet;
@synthesize colourLoversLink;
@synthesize paletteChangeIntervalSlider;
@synthesize showPaletteTypePopUpButton;
@synthesize colors;
@synthesize palettes;
@synthesize paletteChangeInterval;
@synthesize paletteLastChanged;
@synthesize firstTime;
@synthesize curOrientation;

- (void)refreshPaletteListForType:(int) showPalettesType
{
    [self.palettes removeAllObjects];
        
    NSURL *url = nil;
    switch (showPalettesType)
    {
        case kShowPalettesNew:
            url = [NSURL URLWithString: kNewPalettesUrl];
            break;
        case kShowPalettesRandom:
            url = [NSURL URLWithString: kRandomPaletteUrl];
            break;
        default:
            url = [NSURL URLWithString: kTopPalettesUrl];
            
    }
            
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];

    NSURLResponse* response = nil;
    NSError *error = nil;

    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                    returningResponse:&response
                                    error:&error];    
    
    if (data == nil) {
        [self readPalettesFromCache];
        return;
    }
    
    NSXMLDocument *xmlDoc = [[[NSXMLDocument alloc] initWithData:data options:0 error:&error] autorelease];

    if (xmlDoc == nil){
        [self readPalettesFromCache];
        return;
    }
    
    NSArray *paletteNodes = [xmlDoc nodesForXPath:@"palettes/palette" error:&error];
    NSEnumerator *e = [paletteNodes objectEnumerator];
    NSXMLNode *curNode = nil;
    while (curNode = [e nextObject]) {
        [self.palettes addObject:[[[Palette alloc]initWithXMLNode: curNode] autorelease]];
    }
    
    [self writePalettesToCache];
}


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self != nil) {
                
        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleName];
        
        // Register our default values
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kShowPalettesTop], kShowPalettesTypeDefaultsKey,
                                    [NSNumber numberWithInt:3], kPaletteChangeIntervalDefaultsKey,
                                    nil]];   
        
        self.colors = [NSMutableArray array];
        self.palettes = [NSMutableArray array];

        [self refreshPaletteListForType:[[defaults objectForKey:kShowPalettesTypeDefaultsKey] intValue]];

        [self setAnimationTimeInterval:kAnimationTimeInterval];
    }
    
    self.curPaletteIndex = 0;
    self.paletteLastChanged = [NSDate date];
    self.curColorIndex = -1;
    self.firstTime = YES;
    self.curOrientation = kFullPaletteOrientationHorizontal;
    
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
    
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleName];

    if (self.firstTime) {
            
        [self drawSplashScreen];
        
        self.firstTime = NO;
        return;
    }
    
    int palleteChangeInterval = [[defaults objectForKey: kPaletteChangeIntervalDefaultsKey] intValue];
    
    if (paletteChangeInterval < 3) {
        paletteChangeInterval = 3;
    }

    if (paletteChangeInterval > 9) {
        paletteChangeInterval = 9;
    }
    
    if ((self.paletteLastChanged != nil) && ([self.paletteLastChanged timeIntervalSinceNow] <= (palleteChangeInterval * -60))) {
        
        if ([[defaults objectForKey: kShowPalettesTypeDefaultsKey] intValue] == kShowPalettesRandom) {
            [self refreshPaletteListForType:kShowPalettesRandom];
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
        self.curOrientation = (self.curOrientation == kFullPaletteOrientationVertical) ? kFullPaletteOrientationHorizontal : kFullPaletteOrientationVertical;

        [self drawFullPaletteFrame:palette orientation: self.curOrientation];
        
        return;
    }

    Color *color = (Color *)[palette.colors objectAtIndex: self.curColorIndex];    
        
    [self drawFrameForColor:color withPaletteTitle:[palette.title lowercaseString]];
}


- (void) drawSplashScreen
{

    Color *color = [[[Color alloc]initWithHexValue: @"000000" andWidth:[NSNumber numberWithFloat:1.0]] autorelease];
    
    // draw the background
    NSSize size = [self bounds].size;
    
    NSRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size = NSMakeSize(size.width, size.height);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    
    [[color colorValue] set];
    [path fill];
    
    NSColor *textColor = [NSColor whiteColor];
    
    // draw main title
    int fontSize = (int)(rect.size.height * 0.25);
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSFont fontWithName:@"Helvetica Neue" size:fontSize], NSFontAttributeName,
                                        textColor, NSForegroundColorAttributeName,
                                        nil];
    
    NSAttributedString *attributedText = [[[NSAttributedString alloc] initWithString: @"Helveticolor" attributes: textAttributes] autorelease];
    
    NSSize attrSize = [attributedText size];
    int xOffset = (rect.size.width / 2) - (attrSize.width / 2);
    int yOffset = (rect.size.height / 2) - (attrSize.height / 2);
    
    [attributedText drawAtPoint:NSMakePoint(xOffset, yOffset)];
    
    // draw "powered by"
    fontSize = (int)(rect.size.height * 0.0225);

    textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSFont fontWithName:@"Helvetica Neue" size:fontSize], NSFontAttributeName,
                        textColor, NSForegroundColorAttributeName,
                        nil];
    
    attributedText = [[[NSAttributedString alloc] initWithString: @"powered by" attributes: textAttributes] autorelease];
    attrSize = [attributedText size];
    xOffset = (rect.size.width / 2) - (attrSize.width / 2);
    yOffset = (rect.size.height * 0.15);
    
    [attributedText drawAtPoint:NSMakePoint(xOffset, yOffset)];
    
    // draw COLOURLovers logo
    fontSize = (int)(rect.size.height * 0.04);
    
    textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSFont fontWithName:@"Arial Bold" size:fontSize], NSFontAttributeName,
                        [NSColor colorWithCalibratedRed:(193.0 / 255.0) green:(193.0 / 255.0) blue:(193.0 / 255.0) alpha:1.0], NSForegroundColorAttributeName,
                        [NSNumber numberWithFloat:(fontSize / -20.0)], NSKernAttributeName,
                        nil];
    
    NSMutableAttributedString *colourLoversLogo = [[[NSMutableAttributedString alloc] initWithString: @"COLOUR" attributes: textAttributes] autorelease];
    
    textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSFont fontWithName:@"Arial" size:fontSize], NSFontAttributeName,
                        [NSColor colorWithCalibratedRed:(239.0 / 255.0) green:(239.0 / 255.0) blue:(239.0 / 255.0) alpha:1.0], NSForegroundColorAttributeName,
                        [NSNumber numberWithFloat:(fontSize / -28.0)], NSKernAttributeName,
                        nil];
                        
    NSMutableAttributedString *loversText = [[[NSMutableAttributedString alloc] initWithString: @"lovers" attributes: textAttributes] autorelease];
    
    [colourLoversLogo appendAttributedString:loversText];
                            
    attrSize = [colourLoversLogo size];
    xOffset = (rect.size.width / 2) - (attrSize.width / 2);
    yOffset = (rect.size.height * 0.10);
    
    [colourLoversLogo drawAtPoint:NSMakePoint(xOffset, yOffset)];

}

- (void) drawFullPaletteFrame: (Palette *)palette orientation: (int) orientation
{
    NSSize size = [self bounds].size;
    int curPos = 0;

    NSEnumerator *e = [palette.colors objectEnumerator];
    
    Color *curColor = nil;
    while (curColor = [e nextObject]) {
        
        int stepSize = 0;
        if (orientation == kFullPaletteOrientationVertical) {
            stepSize = round(size.width * [curColor.width floatValue]);
        } else {
            stepSize = round(size.height * [curColor.width floatValue]);
        }
        
                
        NSRect rect;
        
        if (orientation == kFullPaletteOrientationVertical) {
            rect.origin.x = curPos;
            rect.origin.y = 0;
            rect.size = NSMakeSize(stepSize, size.height);
        } else {
            rect.origin.y = curPos;
            rect.origin.x = 0;
            rect.size = NSMakeSize(size.width, stepSize);
        }

        NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];

        [[curColor colorValue] set];

        [path fill];

        NSColor *textColor;
        
        if ([curColor calculateColorBrightness] > kColorBrightnessThreshold) {
            textColor = [NSColor blackColor];
        } else {
            textColor = [NSColor whiteColor];
        }
        
        int fontSize = 0;
        if (orientation == kFullPaletteOrientationVertical) {
            fontSize = (int)(rect.size.height * 0.04);
        } else {
            fontSize = (int)(rect.size.width * 0.02);
        }
        
        NSDictionary *mainTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSFont fontWithName:@"Helvetica Neue" size:fontSize], NSFontAttributeName,
                                            textColor, NSForegroundColorAttributeName,
                                            nil];
        
        NSString *hexColorString = [@"#" stringByAppendingString: curColor.hexValue];
        NSAttributedString *textAttr = [[[NSAttributedString alloc] initWithString: hexColorString attributes: mainTextAttributes] autorelease];
        
        int xOffset = 0;
        int yOffset = 0;
        if (orientation == kFullPaletteOrientationVertical) {
            xOffset = rect.size.height * 0.01;
            yOffset = (curPos + stepSize) * -1;
        } else {
            xOffset = rect.size.width - [textAttr size].width - round(rect.size.width * 0.005);
            yOffset = curPos;
        }

        // draw text
        if (orientation == kFullPaletteOrientationVertical) {
            [NSGraphicsContext saveGraphicsState];
            NSAffineTransform *rotateTransform = [NSAffineTransform transform];

            CGFloat degrees = 90;
            [rotateTransform rotateByDegrees:degrees];
            [rotateTransform concat];
            [textAttr drawAtPoint:NSMakePoint(xOffset, yOffset)];
            [NSGraphicsContext restoreGraphicsState];
        } else {
            [textAttr drawAtPoint:NSMakePoint(xOffset, yOffset)];
        }
        

        curPos += stepSize;
    }
    
}


- (void) drawFrameForColor: (Color *)color withPaletteTitle: (NSString *)title
{
    // draw the background
    NSSize size = [self bounds].size;
    
    NSRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size = NSMakeSize(size.width, size.height);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    
    [[color colorValue] set];
    [path fill];
    
    NSColor *textColor;
        
    if ([color calculateColorBrightness] > kColorBrightnessThreshold) {
        textColor = [NSColor blackColor];
    } else {
        textColor = [NSColor whiteColor];
    }
    
    // draw primary text
    NSString *hexColorString = [@"#" stringByAppendingString: color.hexValue];

    int alphaFontSize = (int)(rect.size.height * 0.25);
    int numericFontSize = (int)(rect.size.height * 0.255);
    
    NSDictionary *mainTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSFont fontWithName:@"Helvetica Neue" size:numericFontSize], NSFontAttributeName,
                                        textColor, NSForegroundColorAttributeName,
                                        nil];
    
    NSMutableAttributedString *mainAttributedText = [[[NSMutableAttributedString alloc] initWithString: hexColorString attributes: mainTextAttributes] autorelease];
    
    for (int i = 0; i < [hexColorString length]; i++) {
        if (([hexColorString characterAtIndex:i] >= 'A') || ([hexColorString characterAtIndex:i] >= 'F')) {
            [mainAttributedText addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:alphaFontSize] range:NSMakeRange(i, 1)];
        }
    }
    
    
    NSSize attrSize = [mainAttributedText size];
    int xOffset = (rect.size.width / 2) - (attrSize.width / 2);
    int yOffset = (rect.size.height / 2) - (attrSize.height / 2);
    
    [mainAttributedText drawAtPoint:NSMakePoint(xOffset, yOffset)];
    
    // draw secondary text
    int fontSize = (int)(rect.size.height * 0.04);
    NSDictionary *secondaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSFont fontWithName:@"Helvetica Neue" size:fontSize], NSFontAttributeName,
                                             textColor, NSForegroundColorAttributeName,
                                             nil];
    
    NSAttributedString *secondaryAttributedText = [[[NSAttributedString alloc] initWithString: title attributes: secondaryTextAttributes] autorelease];
    attrSize = [secondaryAttributedText size];
    
    
    xOffset = size.width - attrSize.width - (size.width * 0.01);
    yOffset = round(size.height * 0.01);
    [secondaryAttributedText drawAtPoint:NSMakePoint(xOffset, yOffset)];
    
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
    
    [self.paletteChangeIntervalSlider setAllowsTickMarkValuesOnly:YES];

    // palette type pulldown config
    [self.showPaletteTypePopUpButton removeAllItems];
    [self.showPaletteTypePopUpButton addItemWithTitle: @"Top Palettes"];
    [self.showPaletteTypePopUpButton addItemWithTitle: @"Newest Palettes"];
    [self.showPaletteTypePopUpButton addItemWithTitle: @"Random Palettes"];
    
    
    // COLOURLovers link config
    [self.colourLoversLink setDrawsBackground:NO];
    [self.colourLoversLink setAllowsEditingTextAttributes: YES];
    [self.colourLoversLink setSelectable: YES];
    
    NSURL* url = [NSURL URLWithString:@"http://www.colourlovers.com"];
    
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString: [NSAttributedString hyperlinkFromString:@"COLOURLovers" withURL:url]];
    
    // set the attributed string to the NSTextField
    [self.colourLoversLink setAttributedStringValue: string];
    
    [string release];

    // get and set defaults
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleName];
    [self.showPaletteTypePopUpButton selectItemAtIndex:[[defaults objectForKey:kShowPalettesTypeDefaultsKey] intValue]];
    [self.paletteChangeIntervalSlider setIntValue:[[defaults objectForKey:kPaletteChangeIntervalDefaultsKey] intValue]];
    
    
	return self.configSheet;
}


- (IBAction)okClick:(id)sender
{
    
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleName];
    
    // Update our defaults
    [defaults setObject:[NSNumber numberWithInt:(int)[self.showPaletteTypePopUpButton indexOfSelectedItem]] forKey:kShowPalettesTypeDefaultsKey];
    
    [defaults setObject:[NSNumber numberWithInt:[self.paletteChangeIntervalSlider intValue]] forKey:kPaletteChangeIntervalDefaultsKey];
    
    // Save the settings to disk
    [defaults synchronize];
    
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:self.configSheet];
    
}


- (IBAction)cancelClick:(id)sender
{
    [[NSApplication sharedApplication] endSheet:self.configSheet];
    
}

- (void) writePalettesToCache
{
    NSMutableDictionary *cache = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.palettes];
    [cache setObject:data forKey:@"Palettes"];
    
    [cache writeToFile:[kCacheFilePath stringByExpandingTildeInPath] atomically: TRUE];
}

- (void) readPalettesFromCache
{
    NSMutableDictionary *cache = [[[NSMutableDictionary alloc] initWithContentsOfFile:[kCacheFilePath stringByExpandingTildeInPath]] autorelease];
    NSData *data = [cache objectForKey:@"Palettes"];
    
    if (data != nil) {
        self.palettes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        // no palette cache found-- manually add a fallback palette.
        NSMutableArray *defaultColors = [NSMutableArray array];
        
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"2F798C" andWidth: [NSNumber numberWithFloat:0.2]] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"463E3B" andWidth: [NSNumber numberWithFloat:0.2]] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"B5AA2A" andWidth: [NSNumber numberWithFloat:0.2]] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"BA591D" andWidth: [NSNumber numberWithFloat:0.2]] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"E77D90" andWidth: [NSNumber numberWithFloat:0.2]] autorelease]];
        
        Palette *defaultPalette = [[[Palette alloc] initWithArray: defaultColors] autorelease];
        defaultPalette.title = @"";
        defaultPalette.userName = @"";
        [self.palettes addObject: defaultPalette];
        
    }
}


@end
