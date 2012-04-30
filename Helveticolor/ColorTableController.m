//
//  ColorTableController.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/23/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "ColorTableController.h"

@implementation ColorTableController

static NSString * const MODULE_NAME = @"com.pjbeardsley.Helveticolor";

@synthesize colors;
@synthesize colorTable;

- (void)awakeFromNib {
    
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName: MODULE_NAME];
    
    self.colors = [NSMutableArray arrayWithArray:[defaults arrayForKey: @"colors"]];

    [self.colorTable reloadData];
    
}


@end
