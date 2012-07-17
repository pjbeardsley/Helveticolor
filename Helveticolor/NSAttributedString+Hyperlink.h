//
//  NSAttributedString+Hyperlink.h
//  Helveticolor
//
//  Created by Peter Beardsley on 7/17/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Hyperlink)
    +(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end
