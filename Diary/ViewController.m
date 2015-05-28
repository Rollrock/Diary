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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100,100)];
    btn.backgroundColor = [UIColor grayColor];
    
    [btn addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    
}

-(void)btn
{
    ShowView * view = [[ShowView alloc]initWithFrame:CGRectMake(0, 0, 320, 300)];
    
    
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
