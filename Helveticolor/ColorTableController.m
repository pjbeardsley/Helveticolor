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

@end
