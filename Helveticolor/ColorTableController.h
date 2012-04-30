//
//  ColorTableController.h
//  Helveticolor
//
//  Created by Peter Beardsley on 4/23/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorTableController : NSArrayController {
    NSMutableArray *colors;
    IBOutlet NSTableView * colorTable;
}

@property (retain) NSMutableArray * colors;
@property (retain) NSTableView * colorTable;


@end
