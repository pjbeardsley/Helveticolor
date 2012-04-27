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
    int curColorIndex;
    IBOutlet id configSheet;
    IBOutlet ColorTableController * colorTableController;
}

@property (assign) int curColorIndex;
@property (retain) id configSheet;
@property (retain) ColorTableController * colorTableController;

@end
