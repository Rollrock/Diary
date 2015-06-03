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
        {
            NSString * strDiary = @"你见，或者不见我\n我就在那里\n不悲 不喜\n你念，或者不念我\n情就在那里\n不来 不去\n你爱，或者不爱我\n爱就在那里\n不增 不减\n你跟，或者不跟我\n我的手就在你手里\n不舍不弃\n来我的怀里\n或者\n让我住进你的心里\n默然 相爱\n寂静 欢喜\n";
            
            ArticleInfo * info = [ArticleInfo new];
            info.body = strDiary;
            info.title = @"你见或者不见我";
            info.time = @"零六月零三日";
            
            [[MyFMDB shareDB] addDiary:info];
        }
        
        /////////
        {
            NSString * strDiary = @"下雨了\n窗边的窗帘在不停地飘起，有种飘逸的美\n滴滴答答的声音一直在我的耳边响起，那是雨的声音\n夏季的雨，总有种伤感的感觉，那么悲凉\n下雨天了，怎么办\n听说下雨天，是想念的季节\n一个人偷偷地在想念，偷偷地怀念，偷偷地思念。想念着我们曾经度过的那些日子，怀念着我们说过的每句话，思念着心中的那个重要的人\n有些事情，是不能说的，一说就是错\n有些感觉，是不能讲的，一讲就不能回头了\n有些想念，是不能说出口的\n下雨了，我可不可以当做是，连天都在哭泣\n到底要有多勇敢，才敢念念不忘\n到底要有多坚强，才敢念念不忘\n那些曾经的，那么美好，那么伤感。都是你曾经给予我的，独一无二的宝贵的回忆。无论是开心，还是伤心，我都会好好保存。一直都老\n下雨天，你在想念谁呢？\n无论以后怎么样，请你相信我，我从来都没有后悔过和你相遇，即使遇见了你，那么伤，那么痛\n我只是想告诉你，下雨天，我在想念你\n你是我心中一直以来的痛。但是，我却一直在想念你\n愿你幸福。也愿那些想念着别人的人幸福\n下雨天。你在想念谁呢？";
            
            ArticleInfo * info = [ArticleInfo new];
            info.body = strDiary;
            info.title = @"下雨天你在想念谁";
            info.time = @"零六月零三日";
            
            [[MyFMDB shareDB] addDiary:info];
        }
        
        /////////
        {
            NSString * strDiary = @"又想你了，心情还是一如既往的感伤\n心在流泪，却要我微笑地去面对\n听着一首循环的歌曲，想起了你\n不知不觉写了好多重复的话\n重复着一次又一次对你心痛的想念\n还记得你说我们是朋友\n那是一种怎样的情感呢\n也许我会不知不觉的那些痛\n然后就这样结束，然后忘记你\n写着写着心就不知不觉的痛了\n偶尔抬头看你\n偶尔抬头看你\n曾经你是我的寄托，只是我也失去了你，失去了这份寄托\n有你的日子是开心的，没有我的日子，你也是开心的\n明明都能够默默承受了，但却在你难过的时候，所有的心思，全都土崩瓦解了\n";
            
            ArticleInfo * info = [ArticleInfo new];
            info.body = strDiary;
            info.title = @"现在的你还好吗";
            info.time = @"零六月零三日";
            
            [[MyFMDB shareDB] addDiary:info];
        }
        
        ///
        [self setFirstUse];
    }
    
   
}

@end
