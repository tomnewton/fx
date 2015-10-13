//
//  CurrencyPairVO.m
//  CAD
//
//  Created by Tom Newton on 26/08/2015.
//  Copyright (c) 2015 Tom Newton. All rights reserved.
//

#import "CurrencyPairVO.h"

@implementation CurrencyPairVO

-(id)initWithCode:(NSString*)code{
    if ( self != nil ){
        self.pairCode = code;
        self.rate = @"";
        return self;
    }
    return nil;
}

-(NSString*)getCodeForYahoo{
    return [self.pairCode stringByReplacingOccurrencesOfString:@"/" withString:@""];
}

-(void)setRate:(NSString *)rate{
    _rate = rate;
    
    if ( self.menuItem != nil ) {
        self.menuItem.title = [NSString stringWithFormat:@"%@: %@", self.pairCode, _rate];
    }
}

-(NSNumber*)getRateAsNumber{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    return [f numberFromString:self.rate];
}

@end
