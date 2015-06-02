//
//  ShareInfo.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-6-2.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "ShareInfo.h"

@implementation ShareInfo

#define FONTSIZE 23

+(int)getLabWidth
{
    return FONTSIZE;
}

+(UIFont*)getBodyFont
{
    UIFont * font = [UIFont fontWithName:@"STXingkai" size:FONTSIZE];
    return font;
}

+(UIFont*)getTitleFont
{
    UIFont * font = [UIFont fontWithName:@"STXingkai" size:FONTSIZE+2];
    return font;
}



@end
