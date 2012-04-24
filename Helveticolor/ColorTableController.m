//
//  ColorTableController.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/23/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "ColorTableController.h"

@implementation ColorTableController

- (void)awakeFromNib {
    
    self.colors = [[NSMutableArray alloc]init];
    [colors addObject: @"2F798C"];
    [colors addObject: @"463E3B"];
    [colors addObject: @"B5AA2A"];
    [colors addObject: @"BA591D"];
    [colors addObject: @"E77D90"];
    
    [colorTable reloadData];
    
}

- (IBAction)addAtSelectedRow:(id)pId {
    if ([colorTable selectedRow] > -1) {
        [self.colors insertObject:@"" atIndex:[colorTable selectedRow]];
        [colorTable reloadData];
    }
    
}

- (IBAction)deleteSelectedRow:(id)pId {
    if ([colorTable selectedRow] > -1) {
        [self.colors removeObjectAtIndex:[colorTable selectedRow]];
        [colorTable reloadData];
    }
}

- (void)addRow:(NSString *)pColor {
    [self.colors addObject:pColor];
    [colorTable reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)colorTable {
    return [self.colors count];
} 

- (id) tableView:(NSTableView *)pTableViewObj objectValueForTableColumn:(NSTableColumn *)pTableColumn row:(int)pRowIndex {
    NSString * zColor = (NSString *)[self.colors objectAtIndex:pRowIndex];
    
    if (! zColor) {
        NSLog(@"tableView: objectAtIndex:%d = NULL",pRowIndex);
        return NULL;
    }
    
    NSLog(@"pTableColumn identifier = %@",[pTableColumn identifier]);
    
    if ([[pTableColumn identifier] isEqualToString:@"Col_ID1"]) {
        return zColor;
    }
    
    NSLog(@"***ERROR** dropped through pTableColumn identifiers");
    return NULL;
}

- (void)tableView:(NSTableView *)pTableViewObj setObjectValue:(id)pObject forTableColumn:(NSTableColumn *)pTableColumn row:(int)pRowIndex {
    
    NSString * zColor;
    
    if ([[pTableColumn identifier] isEqualToString:@"Col_ID1"]) {
        zColor = (NSString *)pObject;
    }
    
} 

@end
