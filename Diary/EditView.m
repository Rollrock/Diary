//
//  EditView.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-28.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "EditView.h"
#import "Header.h"
#import "MyFMDB.h"
#import "Structs.h"

#define DONE_BTN_WIDTH  40.0f

#define TITLE_LAB_HEIGHT  40

@interface EditView()
{
    UITextField * titleField;
    UITextView * textView;
    
    UIButton * doneBtn;
    UIButton * cancelBtn;
    BOOL bAdd;
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

-(void)layoutTitleLab:(NSString*)title
{
    titleField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TITLE_LAB_HEIGHT)];
    titleField.backgroundColor = [UIColor orangeColor];
    titleField.text = title;
    
    [self addSubview:titleField];
}

-(void)layoutTextView:(NSArray*)array
{
    NSMutableString * mutStr = [NSMutableString new];
    
    NSMutableArray * mutArray = [NSMutableArray arrayWithArray:array];
    [mutArray removeObjectAtIndex:0];
    [mutArray removeObjectAtIndex:0];
    
    for( NSString * str in mutArray )
    {
        [mutStr appendString:str];
        [mutStr appendString:@"\n"];
    }
    
    textView = [[UITextView alloc]initWithFrame:CGRectMake(0, TITLE_LAB_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-TITLE_LAB_HEIGHT)];
    textView.text = mutStr;
    textView.font = [self getFont];
    [self addSubview:textView];
}

-(void)layoutDoneBtn
{
    doneBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - DONE_BTN_WIDTH-10, SCREEN_HEIGHT-DONE_BTN_WIDTH-10, DONE_BTN_WIDTH, DONE_BTN_WIDTH)];
    doneBtn.backgroundColor = [UIColor grayColor];
    [doneBtn setTitle:@"OK" forState:UIControlStateNormal];
    //doneBtn.alpha = 0;
    [doneBtn addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:doneBtn];
    
    //
    
    cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - DONE_BTN_WIDTH*2-20, SCREEN_HEIGHT-DONE_BTN_WIDTH-10, DONE_BTN_WIDTH, DONE_BTN_WIDTH)];
    cancelBtn.backgroundColor = [UIColor grayColor];
    [cancelBtn setTitle:@"BACK" forState:UIControlStateNormal];
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
    
    [self storeArticle];
    
    [self dismissView];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(scheduleDelegate) userInfo:nil repeats:NO];
}

-(void)storeArticle
{
    ArticleInfo * info = [ArticleInfo new];
    info.title = titleField.text;
    info.time = [self getCurrentDate];
    info.body = textView.text;
    
    [[MyFMDB shareDB] addDiary:info];
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


-(NSString*)getCurrentDate
{
    NSDate *now = [NSDate date];
    NSLog(@"now date is: %@", now);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    int year = [dateComponent year];
    int month = [dateComponent month];
    int day = [dateComponent day];
 
    
    return [NSString stringWithFormat:@"%d_%d_%d",year,month,day];
}


-(id)initWithFrame:(CGRect)frame wihtArray:(NSArray*)array withTitle:(NSString *)strTitle
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        if( ! array )
        {
            bAdd = YES;
        }
        
        [self layoutTitleLab:strTitle];
        
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
