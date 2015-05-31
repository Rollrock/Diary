//
//  MyFMDB.h
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-31.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "Structs.h"

@interface MyFMDB : NSObject
{
    FMDatabase * sDB;
}

+(MyFMDB*)shareDB;
-(NSArray*)queryDiary;

-(ArticleInfo*)queryDiaryWithId:(int)aId;
-(void)addDiary:(ArticleInfo*)info;

@end
