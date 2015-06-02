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

-(void)deleteDiaryWithId:(int)aId;
-(ArticleInfo*)queryDiaryWithId:(int)aId;
-(void)addDiary:(ArticleInfo*)info;
-(void)updateDiary:(ArticleInfo*)info;
-(int)queryDiaryWithTitle:(NSString*)title withBody:(NSString*)body;

@end
