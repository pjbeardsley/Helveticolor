//
//  HelveticolorView.h
//  Helveticolor
//
//  Created by Peter Beardsley on 4/3/12.
//  Copyright (c) 2012 Peter Beardsley. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface HelveticolorView : ScreenSaverView {
    int curColorIndex;
    IBOutlet id configSheet;
    IBOutlet id showPaletteTypePopUpButton;
    IBOutlet id colourLoversLink;
    IBOutlet id paletteChangeIntervalSlider;
}

@property (assign) int curColorIndex;
@property (assign) int curPaletteIndex;
@property (assign) bool firstTime;
@property (assign) int curOrientation;
@property (strong) id configSheet;
@property (strong) id colourLoversLink;
@property (strong) id paletteChangeIntervalSlider;
@property (strong) id showPaletteTypePopUpButton;
@property (strong) NSMutableArray *palettes;
@property (assign) int paletteChangeInterval;
@property (strong) NSDate *paletteLastChanged;
@property (strong) NSURLConnection *xmlConnection;
@property (strong) NSMutableData *xmlData;

- (void)refreshPaletteListForType:(int) showPalettesType;

@end
