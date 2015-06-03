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

#define DONE_BTN_WIDTH  30.0f

#define TITLE_LAB_HEIGHT  30.0f
#define TITLE_LAB_Y_POS  20.0f

@interface EditView()
{
    UITextField * titleField;
    UITextView * textView;
    
    UIButton * doneBtn;
    UIButton * cancelBtn;
    BOOL bAdd;
    
    int articleId;
    NSString * timeStr;
    NSString * titleStr;
    
    NSMutableArray * dataArray;
}
@end


@implementation EditView


-(void)layoutTitleLab:(NSString*)title
{
    titleField = [[UITextField alloc]initWithFrame:CGRectMake(0, TITLE_LAB_Y_POS, SCREEN_WIDTH, TITLE_LAB_HEIGHT)];
    titleField.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    titleField.font = [UIFont systemFontOfSize:20];
    titleField.text = title;
    
    [self addSubview:titleField];
}

-(void)layoutTextView:(NSArray*)array
{
    NSMutableString * mutStr = [NSMutableString new];
    
    if( array != nil )
    {
        NSMutableArray * mutArray = [NSMutableArray arrayWithArray:array];
        
        for( NSString * str in mutArray )
        {
            [mutStr appendString:str];
            [mutStr appendString:@"\n"];
        }
    }
    
    
    textView = [[UITextView alloc]initWithFrame:CGRectMake(0, TITLE_LAB_HEIGHT+TITLE_LAB_Y_POS, SCREEN_WIDTH, SCREEN_HEIGHT-TITLE_LAB_HEIGHT)];
    textView.text = mutStr;
    //textView.backgroundColor = [UIColor lightGrayColor];
    //textView.font = [ShareInfo getBodyFont];
    textView.font = [UIFont systemFontOfSize:18];
    [self addSubview:textView];
}

-(void)layoutDoneBtn
{
    doneBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - DONE_BTN_WIDTH-10, SCREEN_HEIGHT-DONE_BTN_WIDTH-10, DONE_BTN_WIDTH, DONE_BTN_WIDTH)];
    
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    
    [doneBtn addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchDown];
    [self addSubview:doneBtn];
    
    //
    
    cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - DONE_BTN_WIDTH*2-20, SCREEN_HEIGHT-DONE_BTN_WIDTH-10, DONE_BTN_WIDTH, DONE_BTN_WIDTH)];
    
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];

    [cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchDown];
    [self addSubview:cancelBtn];

}

-(void)cancelClick
{
    
    if( [_editDelegate respondsToSelector:@selector(cancelEdit:)])
    {
        [dataArray insertObject:titleStr atIndex:0];
        [dataArray addObject:timeStr];
        
        [_editDelegate cancelEdit:dataArray];
    }
    
    [self dismissView];
}

-(void)doneClicked
{
    NSLog(@"doneClicked");
    
    [self storeArticle];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_ARTICLE_LIST_NOT object:nil];
    
    [self dismissView];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(scheduleDelegate) userInfo:nil repeats:NO];
}

-(void)storeArticle
{
    ArticleInfo * info = [ArticleInfo new];
    info.title = titleField.text;
    info.time = [self getCurrentDate];
    info.body = textView.text;
    info.aId = articleId;
    
    if( bAdd )
    {
        [[MyFMDB shareDB] addDiary:info];
    }
    else
    {
        [[MyFMDB shareDB] updateDiary:info];
    }
}


-(void)scheduleDelegate
{
    if( [_editDelegate respondsToSelector:@selector(editDone:)] )
    {
        NSString * str = textView.text;
        
        NSMutableArray * _dataArray = [NSMutableArray arrayWithArray:[str componentsSeparatedByString:@"\n"]];
        
        [_dataArray insertObject:titleField.text atIndex:0];
        [_dataArray addObject:timeStr];
        
        [_editDelegate editDone:_dataArray];
    }
    
    else if( [_editDelegate respondsToSelector:@selector(addDone:)] )
    {
        int myId = [[MyFMDB shareDB] queryDiaryWithTitle:titleField.text withBody:textView.text];
        
        [_editDelegate addDone:myId];
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

-(NSString*)getCharFromNum:(int)num
{
    NSArray * array = @[@"零",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九"];
    
    if( num < 0 || num > 9 )
    {
        return @"";
    }
    
    return [array objectAtIndex:num];
}



-(NSString*)getCurrentDate
{
    NSDate *now = [NSDate date];
    NSLog(@"now date is: %@", now);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    //int year = [dateComponent year];
    int month = [dateComponent month];
    int day = [dateComponent day];
 
    int mH = month/10;
    int mL = month%10;
    
    int dH = day/10;
    int dL = day%10;
    
    return [NSString stringWithFormat:@"%@%@月%@%@日",[self getCharFromNum:mH],[self getCharFromNum:mL],[self getCharFromNum:dH],[self getCharFromNum:dL]];
}


-(id)initWithFrame:(CGRect)frame wihtArray:(NSArray*)array withTitle:(NSString *)strTitle withTime:(NSString*)time withId:(int)aId
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
        
        dataArray = [NSMutableArray arrayWithArray:array];
        
        articleId = aId;
        timeStr = time;
        titleStr = strTitle;
        
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
