//
//  ViewController.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-28.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "ViewController.h"
#import "ShowViewController.h"
#import "ShowView.h"
#import "MyFMDB.h"
#import "EditView.h"


@interface ViewController ()<EditViewDelegate>
{
    NSMutableArray * articleArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 50,50)];
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:@"显示" forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 180, 50,50)];
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:@"添加" forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btn2) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    //
    [MyFMDB shareDB];
    
    //
    [self layoutArticleList];
}

-(void)layoutArticleList
{
    articleArray = [NSMutableArray new];
    
    articleArray = [[[MyFMDB shareDB] queryDiary] copy];
    
    //
    for( ArticleInfo * info in articleArray )
    {
        NSLog(@"info.time:%@ info.body:%@ info.id:%d",info.time,info.body,info.aId);
    }
}

-(void)btn2
{
    EditView * view = [[EditView alloc]initWithFrame:self.view.frame wihtArray:nil];
    view.editDelegate = self;
    
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:animation forKey:@"animation"];
    
    [self.view addSubview:view];

}

-(void)btn
{
    ShowView * view = [[ShowView alloc]initWithFrame:CGRectMake(0, 0, 320, 480) withId:2];
    
    
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:animation forKey:@"animation"];

    
    [self.view addSubview:view];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
