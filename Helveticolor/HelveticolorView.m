//
//  HelveticolorView.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/3/12.
//  Copyright (c) 2012 Peter Beardsley. All rights reserved.
//

#import "HelveticolorView.h"
#import "Color.h"
#define ANIMATION_TIME_INTERVAL 3.0
#define PALETTE_REFRESH_INTERVAL 30

@implementation HelveticolorView

static NSString * const MODULE_NAME = @"com.pjbeardsley.Helveticolor";

@synthesize curColorIndex;
@synthesize configSheet;
@synthesize colors;
@synthesize colorsLastUpdated;

- (void)refreshPaletteList
{
    [self.colors removeAllObjects];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:@"http://www.colourlovers.com/api/palettes/random"]];
    
    NSError *error;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] == 200){
        
        
        NSString *colorXml = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSError *error;
        
        NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithXMLString:colorXml options:0 error:&error];
        
        NSArray *colorNodes = [xmlDoc nodesForXPath:@"palettes/palette/colors/hex" error:&error];
        
        NSEnumerator *e = [colorNodes objectEnumerator];
        NSXMLNode *curNode;
        
        while (curNode = [e nextObject]) {
            [self.colors addObject: [[Color alloc]initWithHexValue: [curNode objectValue]]];
        }
        
        [xmlDoc release];
        [colorXml release];
    } else {
            [self.colors addObject: [[Color alloc]initWithHexValue: @"2F798C"]];
            [self.colors addObject: [[Color alloc]initWithHexValue: @"463E3B"]];
            [self.colors addObject: [[Color alloc]initWithHexValue: @"B5AA2A"]];
            [self.colors addObject: [[Color alloc]initWithHexValue: @"BA591D"]];
            [self.colors addObject: [[Color alloc]initWithHexValue: @"E77D90"]];
    }
    
    self.colorsLastUpdated = [NSDate date];
    
    NSLog(@"colors updated.");
    
    [request release];
    [responseCode release];
    
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
        if ([self.colorsLastUpdated timeIntervalSinceNow] <= -PALETTE_REFRESH_INTERVAL) {
            [self refreshPaletteList];
        }
    }
        
    Color *color = (Color *)[self.colors objectAtIndex: self.curColorIndex];
    
    NSString *displayString = [[NSString stringWithString: @"#"] stringByAppendingString: [color hexValue]];
    
    self.curColorIndex++;
    if (curColorIndex == [colors count]) {
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
    
    NSAttributedString *currentText = [[NSAttributedString alloc] initWithString: displayString attributes: attributes];
    
    NSSize attrSize = [currentText size];
    int x_offset = (rect.size.width / 2) - (attrSize.width / 2);
    int y_offset = (rect.size.height / 2) - (attrSize.height / 2);
    [currentText drawAtPoint:NSMakePoint(x_offset, y_offset)];
    
    [currentText release];
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

- (void)dealloc
{

    [self.colors removeAllObjects];
    [super dealloc];
}

@end
