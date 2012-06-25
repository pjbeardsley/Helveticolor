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
}

@property (assign) int curColorIndex;
@property (assign) int curPaletteIndex;
@property (retain) id configSheet;
@property (retain) NSMutableArray *colors;
@property (retain) NSMutableArray *palettes;
@property (retain) NSDate *paletteListLastChanged;
@property (retain) NSDate *paletteListLastUpdated;

@end
