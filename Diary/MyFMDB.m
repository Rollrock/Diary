//
//  MyFMDB.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-31.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "MyFMDB.h"

#define DB_NAME  @"rockDB.sqlite"
#define TB_NAME @"rockTB"


static MyFMDB * myDB;


@implementation MyFMDB


+(NSString*)getDatabaseFilepath
{
    NSArray * filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docPath = [filePath objectAtIndex:0];
    
    NSLog(@"filePath:%@",filePath);
    
    NSString * dbFilepath = [docPath stringByAppendingString:DB_NAME];
    
    return dbFilepath;
}


-(void)createTB
{
    if( ! [sDB open] )
    {
        NSLog(@"打开数据库失败");
        return;
    }
    
    [sDB setShouldCacheStatements:YES];
    
    if( ![sDB tableExists:TB_NAME] )
    {
        [sDB executeUpdate:@"create table rockTB(myId integer primary key autoincrement not null, time varchar(128) , body varchar(1024))"];
    }
}

-(void)addDiary:(ArticleInfo*)info
{
    if( ![sDB open] )
    {
        return;
    }
    
    [sDB executeUpdate:@"insert into rockTB(time,body) values(?,?)",info.time,info.body];
}

-(NSArray*)queryDiary
{
    if( ![sDB open])
    {
        return nil;
    }
    
    FMResultSet * result = [sDB executeQuery:@"select * from rockTB"];
    
    NSMutableArray * arr = [NSMutableArray new];
    
    while ([result next])
    {
        ArticleInfo * info = [ArticleInfo new];
        
        info.time = [result stringForColumn:@"time"];
        info.body = [result stringForColumn:@"body"];
        info.aId = [result intForColumn:@"myId"];
        
        [arr addObject:info];
    }
    
    return arr;
}

-(ArticleInfo*)queryDiaryWithId:(int)aId
{
    if( ![sDB open])
    {
        return nil;
    }
    
    NSString * sql = [NSString stringWithFormat:@"select time,body from rockTB where myId=%d",aId];
    
    FMResultSet * result = [sDB executeQuery:sql];
    
    while ([result next])
    {
        ArticleInfo * info = [ArticleInfo new];
        
        info.time = [result stringForColumn:@"time"];
        info.body = [result stringForColumn:@"body"];
        info.aId = aId;
        return info;
    }
    
    return nil;
}



+(MyFMDB*)shareDB
{
    static dispatch_once_t once;
    
    dispatch_once(&once , ^(void){
        
        myDB = [MyFMDB new];
        
        myDB->sDB = [FMDatabase databaseWithPath:[self getDatabaseFilepath]];
        [myDB createTB];
        
    });
    
    return myDB;
}

@end


































