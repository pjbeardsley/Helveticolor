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

static NSString * const kTitleNSCodingKey    = @"Title";
static NSString * const kUsernameNSCodingKey = @"Username";
static NSString * const kColorsNSCodingKey   = @"Colors";

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
        [self.colors addObject:[[[Color alloc]initWithHexValue: [curNode objectValue]
            andWidth: [widths objectAtIndex:[curNode index]]] autorelease]];
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

- (id)initWithCoder:(NSCoder *)decoder
{

    if (self = [super init]) {
        self.title    = [decoder decodeObjectForKey:kTitleNSCodingKey];
        self.userName = [decoder decodeObjectForKey:kUsernameNSCodingKey];
        self.colors   = [decoder decodeObjectForKey:kColorsNSCodingKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.title forKey:kTitleNSCodingKey];
    [encoder encodeObject:self.userName forKey:kUsernameNSCodingKey];
    [encoder encodeObject:self.colors forKey:kColorsNSCodingKey];
}

@end
