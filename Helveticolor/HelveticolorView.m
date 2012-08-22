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

static NSString * const kModuleName    = @"com.pjbeardsley.Helveticolor";

// cache-related constants
static NSString * const kCacheFilePath = @"~/Library/Preferences/com.pjbeardsley.Helveticolor.plist";
static NSString * const kCacheKey      = @"Palettes";

// API retrieval constants
static NSString * const kUserAgent        = @"Helveticolor(+http://pjbeardsley.github.com/Helveticolor)";
static NSString * const kTopPalettesUrl   = @"http://www.colourlovers.com/api/palettes/top?showPaletteWidths=1";
static NSString * const kNewPalettesUrl   = @"http://www.colourlovers.com/api/palettes/new?showPaletteWidths=1";
static NSString * const kRandomPaletteUrl = @"http://www.colourlovers.com/api/palettes/random?showPaletteWidths=1";

// pref key constants
static NSString * const kShowPalettesTypeDefaultsKey      = @"ShowPalettesType";
static NSString * const kPaletteChangeIntervalDefaultsKey = @"PaletteChangeInterval";
static int const kMinPaletteChangeInterval                = 3;
static int const kMaxPaletteChangeInterval                = 9;

// miscellaneous constants
static double const kAnimationTimeInterval          =   3.0;
static double const kColorBrightnessThreshold       =   0.9;
static double const kColourLoversLogoRGBValuesUpper = 193.0;
static double const kColourLoversLogoRGBValuesLower = 239.0;

// scaling "magic number" constants
static double const kSplashScreenTitleFontSizeScale        =   0.25;
static double const kPoweredByFontSizeScale                =   0.0225;
static double const kPoweredByYOffSetScale                 =   0.15;
static double const kColourLoversLogoFontSizeScale         =   0.04;
static double const kColourLoversLogoFontKerningScaleUpper = -20.0;
static double const kColourLoversLogoFontKerningScaleLower = -28.0;
static double const kColourLoversLogoYOffsetScale          =   0.10;
static double const kFullPaletteFontSizeVerticalScale      =   0.04;
static double const kFullPaletteFontSizeHorizontalScale    =   0.02;
static double const kFullPaletteXOffsetVerticalScale       =   0.01;
static double const kFullPaletteXOffsetHorizontalScale     =   0.005;
static double const kFullPaletteMinWidthForVerticalLabel   =   0.025;
static double const kFullPaletteMinWidthForHorizontalLabel =   0.04;
static double const kSingleColorAlphaFontSizeScale         =   0.25;
static double const kSingleColorNumericFontSizeScale       =   0.255;
static double const kSingleColorSecondaryTextFontSizeScale =   0.04;
static double const kSingleColorSecondaryTextXOffsetScale  =   0.01;
static double const kSingleColorSecondaryTextYOffsetScale  =   0.01;

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
            
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3] autorelease];
    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];

    NSURLResponse *response = nil;
    NSError *error          = nil;
    NSData *data            = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!data) {
        [self readPalettesFromCache];
        return;
    }
    
    NSXMLDocument *xmlDoc = [[[NSXMLDocument alloc] initWithData:data options:0 error:&error] autorelease];
    
    if (!xmlDoc) {
        [self readPalettesFromCache];
        return;
    }
    
    NSArray *paletteNodes = [xmlDoc nodesForXPath:@"palettes/palette" error:&error];
    NSEnumerator *e       = [paletteNodes objectEnumerator];
    NSXMLNode *curNode    = nil;
    
    while (curNode = [e nextObject]) {
        [self.palettes addObject:[[[Palette alloc]initWithXMLNode: curNode] autorelease]];
    }
    
    [self writePalettesToCache];
}


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if (self = [super initWithFrame:frame isPreview:isPreview]) {
        // Register our default values
        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleName];
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:kShowPalettesTop], kShowPalettesTypeDefaultsKey,
            [NSNumber numberWithInt:3], kPaletteChangeIntervalDefaultsKey,
            nil]];
            
        self.palettes = [NSMutableArray array];

        [self refreshPaletteListForType:[[defaults objectForKey:kShowPalettesTypeDefaultsKey] intValue]];
        [self setAnimationTimeInterval:kAnimationTimeInterval];
    }
    
    self.curPaletteIndex    = 0;
    self.paletteLastChanged = [NSDate date];
    self.curColorIndex      = -1;
    self.firstTime          = YES;
    self.curOrientation     = kFullPaletteOrientationHorizontal;
    
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
    
    self.paletteChangeInterval = [[defaults objectForKey: kPaletteChangeIntervalDefaultsKey] intValue];
    
    self.paletteChangeInterval = (self.paletteChangeInterval < kMinPaletteChangeInterval)
        ? kMinPaletteChangeInterval : self.paletteChangeInterval;
        
    self.paletteChangeInterval = (self.paletteChangeInterval > kMaxPaletteChangeInterval)
        ? kMaxPaletteChangeInterval : self.paletteChangeInterval;

    if (self.paletteLastChanged &&
        ([self.paletteLastChanged timeIntervalSinceNow] <= (self.paletteChangeInterval * -60))) {
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
        
        self.curOrientation = (self.curOrientation == kFullPaletteOrientationVertical) ?
            kFullPaletteOrientationHorizontal : kFullPaletteOrientationVertical;

        [self drawFullPaletteFrame:palette orientation: self.curOrientation];
        
        return;
    }

    Color *color = (Color *)[palette.colors objectAtIndex: self.curColorIndex];    
        
    [self drawFrameForColor:color withPaletteTitle:[palette.title lowercaseString]];
}


- (void) drawSplashScreen
{
    Color *color = [[[Color alloc]initWithHexValue: @"000000" andWidth:[NSNumber numberWithFloat:1.0]] autorelease];
    [[color colorValue] set];
    
    // draw the background
    NSSize size = [self bounds].size;
    
    NSRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size     = NSMakeSize(size.width, size.height);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    [path fill];
    
    // draw main title
    NSColor *textColor = [NSColor whiteColor];
    int fontSize       = (int)(rect.size.height * kSplashScreenTitleFontSizeScale);
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSFont fontWithName:@"Helvetica Neue" size:fontSize], NSFontAttributeName,
        textColor, NSForegroundColorAttributeName,
        nil];
    
    NSAttributedString *attributedText = [[[NSAttributedString alloc] initWithString:
        @"Helveticolor" attributes: textAttributes] autorelease];
    
    NSSize attrSize = [attributedText size];
    int xOffset     = (rect.size.width / 2) - (attrSize.width / 2);
    int yOffset     = (rect.size.height / 2) - (attrSize.height / 2);

    [attributedText drawAtPoint:NSMakePoint(xOffset, yOffset)];
    
    // draw "powered by"
    fontSize       = (int)(rect.size.height * kPoweredByFontSizeScale);
    textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSFont fontWithName:@"Helvetica Neue" size:fontSize], NSFontAttributeName,
        textColor, NSForegroundColorAttributeName,
        nil];
                        
    attributedText = [[[NSAttributedString alloc] initWithString: @"powered by" attributes: textAttributes] autorelease];
    attrSize       = [attributedText size];
    xOffset        = (rect.size.width / 2) - (attrSize.width / 2);
    yOffset        = (rect.size.height * kPoweredByYOffSetScale);
    
    [attributedText drawAtPoint:NSMakePoint(xOffset, yOffset)];
    
    // draw COLOURLovers logo
    fontSize       = (int)(rect.size.height * kColourLoversLogoFontSizeScale);
    textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSFont fontWithName:@"Arial Bold" size:fontSize], NSFontAttributeName,
        [NSColor colorWithCalibratedRed:(kColourLoversLogoRGBValuesUpper / 255.0)
            green:(kColourLoversLogoRGBValuesUpper / 255.0)
            blue:(kColourLoversLogoRGBValuesUpper / 255.0)
            alpha:1.0], NSForegroundColorAttributeName,
        [NSNumber numberWithFloat:(fontSize / kColourLoversLogoFontKerningScaleUpper)], NSKernAttributeName,
        nil];
    
    NSMutableAttributedString *colourLoversLogo = [[[NSMutableAttributedString alloc] initWithString: @"COLOUR"
        attributes: textAttributes] autorelease];
    
    textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSFont fontWithName:@"Arial" size:fontSize], NSFontAttributeName,
        [NSColor colorWithCalibratedRed:(kColourLoversLogoRGBValuesLower / 255.0)
            green:(kColourLoversLogoRGBValuesLower / 255.0)
            blue:(kColourLoversLogoRGBValuesLower / 255.0)
            alpha:1.0], NSForegroundColorAttributeName,
        [NSNumber numberWithFloat:(fontSize / kColourLoversLogoFontKerningScaleLower)], NSKernAttributeName,
        nil];
                        
    NSMutableAttributedString *loversText = [[[NSMutableAttributedString alloc] initWithString: @"lovers"
        attributes: textAttributes] autorelease];
    
    [colourLoversLogo appendAttributedString:loversText];
                            
    attrSize = [colourLoversLogo size];
    xOffset  = (rect.size.width / 2) - (attrSize.width / 2);
    yOffset  = (rect.size.height * kColourLoversLogoYOffsetScale);
    
    [colourLoversLogo drawAtPoint:NSMakePoint(xOffset, yOffset)];
}


- (void) drawFullPaletteFrame: (Palette *)palette orientation: (int) orientation
{
    NSSize size     = [self bounds].size;
    int curPos      = 0;
    Color *curColor = nil;
    
    // iterate through our palette and draw a "step" for each color
    NSEnumerator *e = [palette.colors objectEnumerator];
    while (curColor = [e nextObject]) {
                
        // figure out step width/height based on orientation
        int stepSize = 0;
        if (orientation == kFullPaletteOrientationVertical) {
            stepSize = round(size.width * [curColor.width floatValue]);
        } else {
            stepSize = round(size.height * [curColor.width floatValue]);
        }
                
        // draw the background for the step
        [[curColor colorValue] set];

        NSRect rect;
        if (orientation == kFullPaletteOrientationVertical) {
            rect.origin.x = curPos;
            rect.origin.y = 0;
            rect.size     = NSMakeSize(stepSize, size.height);
        } else {
            rect.origin.y = curPos;
            rect.origin.x = 0;
            rect.size     = NSMakeSize(size.width, stepSize);
        }

        NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
        [path fill];

        // determine text color based on background color brightness
        NSColor *textColor = ([curColor calculateColorBrightness] > kColorBrightnessThreshold) ? [NSColor blackColor] :
            [NSColor whiteColor];
        
        // select font size based on orientation
        int fontSize = (orientation == kFullPaletteOrientationVertical) ?
            (int)(rect.size.height * kFullPaletteFontSizeVerticalScale) :
            (int)(rect.size.width * kFullPaletteFontSizeHorizontalScale);
        
        NSDictionary *mainTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont fontWithName:@"Helvetica Neue" size:fontSize], NSFontAttributeName,
            textColor, NSForegroundColorAttributeName,
            nil];
        
        NSString *hexColorString     = [@"#" stringByAppendingString: curColor.hexValue];
        NSAttributedString *textAttr = [[[NSAttributedString alloc] initWithString: hexColorString
            attributes: mainTextAttributes] autorelease];
        
        int xOffset = 0;
        int yOffset = 0;
        if (orientation == kFullPaletteOrientationVertical) {
            xOffset = rect.size.height * kFullPaletteXOffsetVerticalScale;
            yOffset = (curPos + stepSize) * -1;
        } else {
            xOffset = rect.size.width - [textAttr size].width -
                round(rect.size.width * kFullPaletteXOffsetHorizontalScale);
            yOffset = curPos;
        }

        // draw the text
        if (orientation == kFullPaletteOrientationVertical) {
            
            if ([curColor.width floatValue] >= kFullPaletteMinWidthForVerticalLabel) {
                [NSGraphicsContext saveGraphicsState];
                
                NSAffineTransform *rotateTransform = [NSAffineTransform transform];
                
                [rotateTransform rotateByDegrees:(CGFloat)90];
                [rotateTransform concat];
                [textAttr drawAtPoint:NSMakePoint(xOffset, yOffset)];
                
                [NSGraphicsContext restoreGraphicsState];
            }
            
        } else {
            if ([curColor.width floatValue] >= kFullPaletteMinWidthForHorizontalLabel) {
                [textAttr drawAtPoint:NSMakePoint(xOffset, yOffset)];
            }
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
    rect.size     = NSMakeSize(size.width, size.height);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    
    [[color colorValue] set];
    [path fill];
    
    NSColor *textColor = ([color calculateColorBrightness] > kColorBrightnessThreshold) ?
        [NSColor blackColor] :
        [NSColor whiteColor];
    
    // draw primary text
    NSString *hexColorString = [@"#" stringByAppendingString: color.hexValue];
    
    int alphaFontSize   = (int)(rect.size.height * kSingleColorAlphaFontSizeScale);
    int numericFontSize = (int)(rect.size.height * kSingleColorNumericFontSizeScale);
    
    NSDictionary *mainTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSFont fontWithName:@"Helvetica Neue" size:numericFontSize], NSFontAttributeName,
        textColor, NSForegroundColorAttributeName,
        nil];
    
    NSMutableAttributedString *mainAttributedText = [[[NSMutableAttributedString alloc] initWithString: hexColorString
        attributes: mainTextAttributes] autorelease];
    
    for (int i = 0; i < [hexColorString length]; i++) {
        if (([hexColorString characterAtIndex:i] >= 'A') || ([hexColorString characterAtIndex:i] >= 'F')) {
            [mainAttributedText addAttribute:NSFontAttributeName value:
                [NSFont fontWithName:@"Helvetica Neue" size:alphaFontSize] range:NSMakeRange(i, 1)];
        }
    }
    
    NSSize attrSize = [mainAttributedText size];
    
    int xOffset = (rect.size.width / 2) - (attrSize.width / 2);
    int yOffset = (rect.size.height / 2) - (attrSize.height / 2);
    
    [mainAttributedText drawAtPoint:NSMakePoint(xOffset, yOffset)];
    
    // draw secondary text
    int fontSize = (int)(rect.size.height * kSingleColorSecondaryTextFontSizeScale);
    NSDictionary *secondaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSFont fontWithName:@"Helvetica Neue" size:fontSize], NSFontAttributeName,
        textColor, NSForegroundColorAttributeName,
        nil];
    
    NSAttributedString *secondaryAttributedText = [[[NSAttributedString alloc] initWithString: title
        attributes: secondaryTextAttributes] autorelease];
        
    attrSize = [secondaryAttributedText size];
    xOffset  = size.width - attrSize.width - (size.width * kSingleColorSecondaryTextXOffsetScale);
    yOffset  = round(size.height * kSingleColorSecondaryTextYOffsetScale);
    
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
			NSLog(@"Failed to load configure sheet.");
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
    
    NSURL *url = [NSURL URLWithString:@"http://www.colourlovers.com"];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
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
    [defaults setObject:[NSNumber numberWithInt:(int)[self.showPaletteTypePopUpButton indexOfSelectedItem]]
        forKey:kShowPalettesTypeDefaultsKey];
    
    [defaults setObject:[NSNumber numberWithInt:[self.paletteChangeIntervalSlider intValue]]
        forKey:kPaletteChangeIntervalDefaultsKey];
    
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
    
    [cache setObject:data forKey:kCacheKey];
    [cache writeToFile:[kCacheFilePath stringByExpandingTildeInPath] atomically: TRUE];
}


- (void) readPalettesFromCache
{
    NSMutableDictionary *cache = [[[NSMutableDictionary alloc] initWithContentsOfFile:
        [kCacheFilePath stringByExpandingTildeInPath]] autorelease];
    NSData *data = [cache objectForKey:kCacheKey];
    
    if (data) {
        self.palettes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        // no palette cache found-- manually add a fallback palette.
        NSMutableArray *defaultColors = [NSMutableArray array];
        
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"2F798C"
            andWidth: [NSNumber numberWithFloat:0.035]] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"463E3B"
            andWidth: [NSNumber numberWithFloat:0.365]] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"B5AA2A"
            andWidth: [NSNumber numberWithFloat:0.2]] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"BA591D"
            andWidth: [NSNumber numberWithFloat:0.2]] autorelease]];
        [defaultColors addObject: [[[Color alloc]initWithHexValue: @"E77D90"
            andWidth: [NSNumber numberWithFloat:0.2]] autorelease]];
        
        Palette *defaultPalette = [[[Palette alloc] initWithArray: defaultColors] autorelease];
        defaultPalette.title = @"";
        defaultPalette.userName = @"";
        [self.palettes addObject: defaultPalette];
    }
}

@end
