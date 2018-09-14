//
//  HandleNullValues.m
//  TruckScreen
//
//  Created by SRISHTI INNOVATIVE on 07/03/14.
//  Copyright (c) 2014 srishtis. All rights reserved.
//

#import "HandleNullValues.h"

@implementation HandleNullValues
+ (NSString *)stringToCheckNull:(NSString *)string
{
    string = [string isKindOfClass:[NSNull class]] || string == (id)[NSNull null] || [string length] == 0
    ? @"" : string;
    return string;
}
@end
