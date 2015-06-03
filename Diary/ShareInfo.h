//
//  ShareInfo.h
//  Diary
//
//  Created by zhuang chaoxiao on 15-6-2.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShareInfo : NSObject

+(UIFont*)getBodyFont;
+(UIFont*)getTitleFont;
+(int)getLabWidth;
+(UIFont*)getTimeFont;

+(BOOL)getFirstUse;
+(void)setFirstUse;

+(void)addDemoDiary;

@end
