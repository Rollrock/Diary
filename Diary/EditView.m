//
//  EditView.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-28.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "EditView.h"
#import "Header.h"

#define DONE_BTN_WIDTH  40.0f

@interface EditView()
{
    UITextView * textView;
    UIButton * doneBtn;
    UIButton * cancelBtn;
}
@end


@implementation EditView


-(UIFont*)getFont
{
    UIFont * font;
    
    if( [FONT_NAME isEqualToString:@""] )
    {
        font = [UIFont systemFontOfSize:FONT_SIZE];
    }
    else
    {
        font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE];
    }
    
    return font;
}



-(void)layoutTextView:(NSArray*)array
{
    
    NSMutableString * mutStr = [NSMutableString new];
    
    for( NSString * str in array )
    {
        [mutStr appendString:str];
        [mutStr appendString:@"\n"];
    }
    
    textView = [[UITextView alloc]initWithFrame:self.frame];
    textView.text = mutStr;
    textView.font = [self getFont];
    [self addSubview:textView];
}

-(void)layoutDoneBtn
{
    doneBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - DONE_BTN_WIDTH-10, SCREEN_HEIGHT-DONE_BTN_WIDTH-10, DONE_BTN_WIDTH, DONE_BTN_WIDTH)];
    doneBtn.backgroundColor = [UIColor grayColor];
    //doneBtn.alpha = 0;
    [doneBtn addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:doneBtn];
    
    //
    
    cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - DONE_BTN_WIDTH*2-20, SCREEN_HEIGHT-DONE_BTN_WIDTH-10, DONE_BTN_WIDTH, DONE_BTN_WIDTH)];
    cancelBtn.backgroundColor = [UIColor grayColor];
    //cancelBtn.alpha = 0;
    [cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];

}

-(void)cancelClick
{
    [self dismissView];
}

-(void)doneClicked
{
    NSLog(@"doneClicked");
    
    [self dismissView];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(scheduleDelegate) userInfo:nil repeats:NO];
}

-(void)scheduleDelegate
{
    if( [_editDelegate respondsToSelector:@selector(editDone:)] )
    {
        NSString * str = textView.text;
        
        NSArray * arr = [str componentsSeparatedByString:@"\n"];
        
        [_editDelegate editDone:arr];
    }
}

-(void)dismissView
{
    [self unregNotification];
    //
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.superview.layer addAnimation:animation forKey:@"animation"];
    
    //
    [self removeFromSuperview];
    
}

//
- (void)regNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)unregNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}


#pragma mark - notification handler

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect textViewFrame = textView.frame;
    textViewFrame.size.height = CGRectGetMinY(endKeyboardRect) - textViewFrame.origin.y;
    
    textView.frame = textViewFrame;
    //
    doneBtn.frame = CGRectMake(doneBtn.frame.origin.x, textView.frame.origin.y + textView.frame.size.height - DONE_BTN_WIDTH , DONE_BTN_WIDTH, DONE_BTN_WIDTH);
    doneBtn.alpha = 1;
    
    //
    cancelBtn.frame = CGRectMake(cancelBtn.frame.origin.x, textView.frame.origin.y + textView.frame.size.height - DONE_BTN_WIDTH , DONE_BTN_WIDTH, DONE_BTN_WIDTH);
    cancelBtn.alpha = 1;
    //
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
}



-(id)initWithFrame:(CGRect)frame wihtArray:(NSArray*)array
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        [self layoutTextView:array];
        
        [self layoutDoneBtn];
        
        [self regNotification];
    }
    
    return self;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
