//
//  Palette.h
//  Helveticolor
//
//  Created by Peter Beardsley on 6/22/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Palette : NSObject
{
    NSString *title;
    NSString *userName;
    NSMutableArray *colors;
}

@property (copy) NSString *title;
@property (copy) NSString *userName;
@property (retain) NSMutableArray *colors;

- (id) initWithXMLNode: (NSXMLNode *)node;
- (id) initWithArray: (NSMutableArray *)array;

@end
