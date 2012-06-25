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
    NSError *error = nil;

    NSArray *colorNodes = [node nodesForXPath:@"colors/hex" error:&error];

    NSEnumerator *e = [colorNodes objectEnumerator];
    NSXMLNode *curNode;

    while (curNode = [e nextObject]) {
        [self.colors addObject: [[[Color alloc]initWithHexValue: [curNode objectValue]] autorelease]];
    }
    
    return self;
}

- (id) initWithArray:(NSMutableArray *)array
{
    [self.colors addObjectsFromArray: array];

    return self;
}

@end
