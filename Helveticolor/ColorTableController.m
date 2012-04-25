//
//  ColorTableController.m
//  Helveticolor
//
//  Created by Peter Beardsley on 4/23/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "ColorTableController.h"

@implementation ColorTableController

@synthesize colors;
@synthesize colorTable;

- (void)awakeFromNib {
    
    NSLog(@"!!Pcb got here");
    
    self.colors = [[NSMutableArray alloc] init];
    
    [self.colors addObject: [[NSMutableString alloc] initWithString: @"2F798C"]];
    [self.colors addObject: [[NSMutableString alloc] initWithString: @"463E3B"]];
    [self.colors addObject: [[NSMutableString alloc] initWithString: @"B5AA2A"]];
    [self.colors addObject: [[NSMutableString alloc] initWithString: @"BA591D"]];
    [self.colors addObject: [[NSMutableString alloc] initWithString: @"E77D90"]];
    
    [self.colorTable reloadData];
    
}

- (IBAction) addAtSelectedRow: (id)pId
{
    if ([self.colorTable selectedRow] > -1) {
        [self.colors insertObject:@"" atIndex:[colorTable selectedRow]];
        [self.colorTable reloadData];
    }
    
}

- (IBAction) deleteSelectedRow: (id)pId
{
    if ([self.colorTable selectedRow] > -1) {
        [self.colors removeObjectAtIndex:[colorTable selectedRow]];
        [self.colorTable reloadData];
    }
}

- (void) addRow:(NSMutableString *)color
{
    [self.colors addObject:color];
    [self.colorTable reloadData];
}

- (int) numberOfRowsInTableView: (NSTableView *)colorTable
{
    return [self.colors count];
} 

- (id) tableView: (NSTableView *)pTableViewObj objectValueForTableColumn: (NSTableColumn *)pTableColumn row: (int)pRowIndex
{
    NSString * color = (NSMutableString *)[self.colors objectAtIndex:pRowIndex];

    
    if (!color) {
        NSLog(@"tableView: objectAtIndex:%d = NULL",pRowIndex);
        return NULL;
    }
    
    return color;
    
}

- (void) tableView: (NSTableView *)pTableViewObj setObjectValue: (id)pObject forTableColumn: (NSTableColumn *)pTableColumn row: (int)pRowIndex
{
    NSLog(@"!!pcb called setObjectValue");
    
    NSMutableString * color = (NSMutableString *)pObject;
        
    [self.colors replaceObjectAtIndex: pRowIndex withObject: color];
        
} 

- (void) dealloc
{
    [self.colors release];
    [super dealloc];
}


@end
