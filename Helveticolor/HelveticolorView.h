//
//  HelveticolorView.h
//  Helveticolor
//
//  Created by Peter Beardsley on 4/3/12.
//  Copyright (c) 2012 Peter Beardsley. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "ColorTableController.h"

@interface HelveticolorView : ScreenSaverView {
    IBOutlet id configSheet;
    int curColorIndex;
    IBOutlet ColorTableController * colorTableController;
}

@property (retain) id configSheet;
@property (assign) int curColorIndex;
@property (retain) ColorTableController * colorTableController;

@end
