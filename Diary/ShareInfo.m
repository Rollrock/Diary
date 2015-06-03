//
//  ShareInfo.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-6-2.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "ShareInfo.h"
#import "MyFMDB.h"

@implementation ShareInfo

#define FONTSIZE 23

+(int)getLabWidth
{
    return FONTSIZE+4;
}

+(UIFont*)getBodyFont
{
    UIFont * font = [UIFont fontWithName:@"STXingkai" size:FONTSIZE];
    return font;
}

+(UIFont*)getTitleFont
{
    UIFont * font = [UIFont fontWithName:@"STXingkai" size:FONTSIZE+4];
    return font;
}


+(UIFont*)getTimeFont
{
    UIFont * font = [UIFont fontWithName:@"STXingkai" size:FONTSIZE-3];
    return font;
}


////////////////////////////////////////////////////
#define FIRST_USE_KEY  @"first_user_key"

+(BOOL)getFirstUse
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    BOOL b = [def boolForKey:@"first_user_key"];
    
    return !b;
}

+(void)setFirstUse
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setBool:YES forKey:FIRST_USE_KEY];
    
    [def synchronize];
}

+(void)addDemoDiary
{
    if( [self getFirstUse] )
    {
        NSString * strDiary = @"你见，或者不见我\n我就在那里\n不悲 不喜\n你念，或者不念我\n情就在那里\n不来 不去\n你爱，或者不爱我\n爱就在那里\n不增 不减\n你跟，或者不跟我\n我的手就在你手里\n不舍不弃\n来我的怀里\n或者\n让我住进你的心里\n默然 相爱\n寂静 欢喜\n";
        
        ArticleInfo * info = [ArticleInfo new];
        info.body = strDiary;
        info.title = @"你见或者不见我";
        info.time = @"零六月零三日";
        
        [[MyFMDB shareDB] addDiary:info];
        
        
        ///
        [self setFirstUse];
    }
    
   
}

@end
