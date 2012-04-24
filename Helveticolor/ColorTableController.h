//
//  ColorTableController.h
//  Helveticolor
//
//  Created by Peter Beardsley on 4/23/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorTableController : NSObject {
    NSMutableArray *colors;
    IBOutlet NSTableView * colorTable;
}

@property (assign) NSMutableArray * colors;
@property (assign) NSTableView * colorTable;

- (IBAction)addAtSelectedRow:(id)pId;
- (IBAction)deleteSelectedRow:(id)pId;

- (void)addRow:(NSString *)pColor;

- (int)numberOfRowsInTableView:(NSTableView *)pTableViewObj;

- (id) tableView:(NSTableView *)pTableViewObj objectValueForTableColumn:(NSTableColumn *)pTableColumn row:(int)pRowIndex;

- (void)tableView:(NSTableView *)pTableViewObj setObjectValue:(id)pObject forTableColumn:(NSTableColumn *)pTableColumn row:(int)pRowIndex;


@end
