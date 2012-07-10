//
//  Palette.m
//  Helveticolor
//
//  Created by Peter Beardsley on 6/22/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "Palette.h"
#import "Color.h"

@implementation Palette

@synthesize title;
@synthesize userName;
@synthesize colors;


- (id) initWithXMLNode: (NSXMLNode *)node
{
    if (self = [super init]) {
        self.colors = [NSMutableArray arrayWithCapacity:5];
    }

    NSError *error = nil;
    
    NSArray *titleNode = [node nodesForXPath:@"title" error:&error];
    
    if([titleNode count] == 1) {
        self.title = [[titleNode objectAtIndex:0] objectValue];
    }
    
    NSArray *userNameNode = [node nodesForXPath:@"userName" error:&error];
    
    if([userNameNode count] == 1) {
        self.userName = [[userNameNode objectAtIndex:0] objectValue];
    }
    
    NSArray *widthsNode = [node nodesForXPath:@"colorWidths" error:&error];
    
    NSArray *widths = nil;
    if ([widthsNode count] == 1) {
        widths = [[[widthsNode objectAtIndex:0] objectValue] componentsSeparatedByString:@","];
    }
    
    NSArray *colorNodes = [node nodesForXPath:@"colors/hex" error:&error];

    NSEnumerator *e = [colorNodes objectEnumerator];
    NSXMLNode *curNode;

    while (curNode = [e nextObject]) {
        [self.colors addObject:[[[Color alloc]initWithHexValue: [curNode objectValue]] autorelease]];
    }
    

    
    return self;
}

- (id) initWithArray:(NSMutableArray *)array
{
    if (self = [super init]) {
        self.colors = [NSMutableArray arrayWithCapacity:5];
    }
    
    [self.colors addObjectsFromArray: array];

    return self;
}

@end
