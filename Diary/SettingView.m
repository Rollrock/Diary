//
//  SettingView.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-6-2.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "SettingView.h"

@interface SettingView()
{
    int tapCount;
}
@end

@implementation SettingView


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        self.userInteractionEnabled = YES;
        [self addTapEvent:self];
    }
    
    return self;
}


-(void)causeTap
{
    tapCount = 0;
}


-(void)tapEvent
{
    if( tapCount == 0 )
    {
        tapCount = 1;
    }
    else if (tapCount == 1 )
    {
        tapCount = 2;
        
        CATransition * animation = [CATransition animation];
        animation.delegate = self;
        animation.duration = 2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"rippleEffect";
        animation.subtype = kCATransitionFromLeft;
        [self.superview.layer addAnimation:animation forKey:@"animation"];
        
        
        [self removeFromSuperview];
    }
    else
    {
        tapCount = 0;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(causeTap) userInfo:nil repeats:NO];
    
}

-(void)dismissView
{
    tapCount = 2;
    
    [self tapEvent];
}


-(void)addTapEvent:(UIView*)scView
{
    UITapGestureRecognizer * g = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent)];
    
    [scView addGestureRecognizer:g];
}

@end
