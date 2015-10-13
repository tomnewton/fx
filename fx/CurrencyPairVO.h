//
//  CurrencyPairVO.h
//  CAD
//
//  Created by Tom Newton on 26/08/2015.
//  Copyright (c) 2015 Tom Newton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface CurrencyPairVO : NSObject

@property (strong, nonatomic) NSString* pairCode;
@property (strong, nonatomic) NSMenuItem* menuItem;
@property (strong, nonatomic) NSString *rate;


-(id)initWithCode:(NSString*)code;
-(NSString*)getCodeForYahoo;
-(void)setRate:(NSString *)rate;
-(NSNumber*)getRateAsNumber;

@end
