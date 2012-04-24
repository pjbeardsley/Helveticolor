//
//  HelveticolorView.h
//  Helveticolor
//
//  Created by Peter Beardsley on 4/3/12.
//  Copyright (c) 2012 Peter Beardsley. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface HelveticolorView : ScreenSaverView {
    NSMutableArray *colors;
    int num_colors;
    int cur_color_index;
    IBOutlet id configSheet;
}

@end
