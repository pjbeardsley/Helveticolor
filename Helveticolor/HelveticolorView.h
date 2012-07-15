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
}

@property (assign) int curColorIndex;
@property (assign) int curPaletteIndex;
@property (assign) bool firstTime;
@property (assign) int curOrientation;
@property (retain) id configSheet;
@property (retain) id showPaletteTypePopUpButton;
@property (retain) NSMutableArray *colors;
@property (retain) NSMutableArray *palettes;
@property (retain) NSDate *paletteLastChanged;

- (void)refreshPaletteListForType:(int) showPalettesType;

@end
