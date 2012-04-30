//
//  Color.h
//  Helveticolor
//
//  Created by Peter Beardsley on 4/29/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Color : NSObject
{
    NSString *hexValue;
}

@property (copy) NSString *hexValue;

- (id) initWithHexValue: (NSString *)newHexValue;
- (NSColor *) colorValue;

@end
