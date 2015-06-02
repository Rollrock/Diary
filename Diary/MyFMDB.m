//
//  MyFMDB.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-31.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "MyFMDB.h"

#define DB_NAME  @"/rockDB.sqlite"
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
       BOOL ret = [sDB executeUpdate:@"create table rockTB(myId integer primary key autoincrement not null, title varchar(128),time varchar(128) , body varchar(1024))"];
        
        NSLog(@"createTb:%d",ret);
    }
}

-(void)updateDiary:(ArticleInfo*)info
{
    if( ![sDB open])
    {
        return;
    }
    
    NSString * str = [NSString stringWithFormat:@"update rockTB SET title = '%@' ,body = '%@' WHERE myId = %d",
                      info.title, info.body, info.aId];
    
    BOOL ret = [sDB executeUpdate:str];
    
    NSLog(@"updateDiary:%d",ret);
    
}

-(void)addDiary:(ArticleInfo*)info
{
    if( ![sDB open] )
    {
        return;
    }
    
    [sDB executeUpdate:@"insert into rockTB(title,time,body) values(?,?,?)",info.title,info.time,info.body];
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
        info.title = [result stringForColumn:@"title"];
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
    
    NSString * sql = [NSString stringWithFormat:@"select title,time,body from rockTB where myId=%d",aId];
    
    FMResultSet * result = [sDB executeQuery:sql];
    
    while ([result next])
    {
        ArticleInfo * info = [ArticleInfo new];
        
        info.time = [result stringForColumn:@"time"];
        info.body = [result stringForColumn:@"body"];
        info.title = [result stringForColumn:@"title"];
        info.aId = aId;
        
        return info;
    }
    
    return nil;
}

-(int)queryDiaryWithTitle:(NSString*)title withBody:(NSString*)body
{
    if( ![sDB open])
    {
        return -1;
    }
    
    NSString * sql = [NSString stringWithFormat:@"select myId from rockTB where title='%@' and body='%@'", title,body];
    FMResultSet * result = [sDB executeQuery:sql];
    
    while([result next])
    {
        int i = [result intForColumn:@"myId"];
        return i;
    }
    
    return -1;
}

-(void)deleteDiaryWithId:(int)aId
{
    [sDB executeUpdate:[NSString stringWithFormat:@"delete from rockTB where myId=%d",aId]];
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


































