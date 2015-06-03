//
//  ShowView.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-28.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "ShowView.h"
#import "EditView.h"
#import "Header.h"
#import "MyFMDB.h"
#import "SVProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define BTN_WIDHT 30
#define BTN_DIS  40


@interface ShowView()<EditViewDelegate>
{
    BOOL stopGCD;
    
    int articleId;
    
    NSString * titleStr;
    NSString * timeStr;
    
    int tapCount;
    NSTimer * tapTimer;
    
    UIView * buttomView;
    
    NSMutableArray * dataArray;
    
    UIScrollView * scrView;
}

@end


@implementation ShowView


#define BUTTOM_VIEW_HEIGHT  50
#define SCROLL_Y_POS  50
#define SCROLL_HEIGHT (SCREEN_HEIGHT - SCROLL_Y_POS*2-BUTTOM_VIEW_HEIGHT)


#define LAB_WIDTH ([ShareInfo getLabWidth])
#define LAB_HEIGHT  SCROLL_HEIGHT
#define LAB_HEIGHT_MIN (LAB_HEIGHT-LAB_WIDTH*2)


//添加水印
-(UIImage*)addWaterMask:(UIImage*)destImg withAddImg:(UIImage*)addImg
{
    UIGraphicsBeginImageContext(destImg.size);
    [destImg drawInRect:CGRectMake(0, 0, destImg.size.width, destImg.size.height)];
    [addImg drawInRect:CGRectMake(0, destImg.size.height-addImg.size.height, addImg.size.width, addImg.size.height)];
    UIImage * rImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rImg;
}

-(void)saveImageToAlbum:(UIImage*)img
{
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if( author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied )
    {
        [SVProgressHUD showErrorWithStatus:@"您没有打开相册权限，请在设置里面打开相册权限"];
        
        return;
    }
    
    [SVProgressHUD showWithStatus:@"保存中..."];
    
    UIImage * destImg = [self addWaterMask:[self captureScrollView:scrView] withAddImg:[UIImage imageNamed:@"water"]];
    
    UIImageWriteToSavedPhotosAlbum(destImg,self, nil, nil);
    
    NSLog(@"保存成功");
    
    [SVProgressHUD showSuccessWithStatus:@"保存成功!"];
}


- (UIImage *)captureScrollView:(UIScrollView *)scrollView
{
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize,NO, [[UIScreen mainScreen] scale]);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    if (image != nil)
    {
        return image;
    }
    return nil;
}


- (float) heightForString:(NSString *)value
{
    NSDictionary *attribute = @{NSFontAttributeName: [ShareInfo getBodyFont]};
    
    CGSize size = [value boundingRectWithSize:CGSizeMake(LAB_WIDTH, 0) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    
    int count = 0;
    for (int i=0; i<value.length; i++)
    {
        NSRange range = NSMakeRange(i,1);
        NSString *aStr = [value substringWithRange:range];
        
        if ([aStr isEqualToString:@" "])
        {
            count++;
        }
    }
    
    return size.height +  (count+1) * LAB_WIDTH;
}


-(NSArray*)fliterString:(NSString*)str
{
    int begIndex  = 0;
    int endIndex = 0;
    int i = 0;
    
    NSMutableArray * arr = [NSMutableArray new];
    
    NSMutableString * mutStr = [NSMutableString stringWithString:str];
    
    for( i = 0; i < [mutStr length]; ++ i )
    {
        NSRange rang = NSMakeRange(begIndex, i-begIndex);
        
        NSString * subS = [mutStr substringWithRange:rang];
        
        float height = [self heightForString:subS];
        
        if( height <= LAB_HEIGHT_MIN )
        {
            endIndex = i;
        }
        else if( height > LAB_HEIGHT_MIN )
        {
            rang = NSMakeRange(begIndex, endIndex-begIndex);
            i-= 1;
            begIndex = i;
            
            
            NSString * endS = [mutStr substringWithRange:rang];
            [arr addObject:endS];
        }
    }
    
    
    if(  endIndex == i -1 )
    {
        NSRange rang = NSMakeRange(begIndex, endIndex-begIndex+1);
        
        NSString * endS = [mutStr substringWithRange:rang];
        [arr addObject:endS];
    }
    
    
    //
    for( NSString * s in arr )
    {
        NSLog(@"s:%@",s);
    }

    
    return arr;
}


-(void)drawViews
{
    NSMutableArray * mArr= [NSMutableArray new];
    
    for( NSString * str in dataArray )
    {
        NSArray * tArr = [self fliterString:str];
        
        [mArr addObjectsFromArray:tArr];
    }
    //
    
    scrView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, SCROLL_Y_POS, SCREEN_WIDTH , SCROLL_HEIGHT)];
    scrView.showsHorizontalScrollIndicator = NO;
    //scrView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:scrView];
    [self addTapEvent:scrView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        
        for( int i = 0; i < [mArr count]; ++ i )
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake([mArr count] * (LAB_WIDTH*1.5) -i*(LAB_WIDTH*1.5), 0, LAB_WIDTH, LAB_HEIGHT)];
                lab.text = [mArr objectAtIndex:i];
                
                if( 0 == i )
                {
                    lab.font = [ShareInfo getTitleFont];
                }
                else if( i == [mArr count] - 1 )
                {
                    lab.font = [ShareInfo getTimeFont];
                }
                else
                {
                    lab.font = [ShareInfo getBodyFont];
                }
               
                
                lab.alpha = 0.0;
                //lab.backgroundColor = [UIColor grayColor];
                lab.numberOfLines = 0;
                lab.lineBreakMode = NSLineBreakByCharWrapping;//NSLineBreakByWordWrapping;
                
                CGFloat height = [self heightForString:lab.text]+LAB_WIDTH;
                lab.frame = CGRectMake(lab.frame.origin.x, lab.frame.origin.y, lab.frame.size.width, height);
                
                [scrView addSubview:lab];
                
                scrView.contentSize = CGSizeMake(([mArr count]+1) * (LAB_WIDTH*1.5), scrView.frame.size.height);
                
                if( scrView.contentOffset.x == 0  && 0 == i )
                {
                    scrView.contentOffset = CGPointMake(scrView.contentSize.width - scrView.frame.size.width, scrView.contentOffset.y);
                }
                
                [UIView animateWithDuration:2 animations:^(void){
                    
                    lab.alpha = 1.0;
                    
                }];
            });
            
            
            sleep(1);
            
            if( stopGCD )
            {
                stopGCD = NO;
                
                break;
            }
            
            
            if( i == [mArr count] -1 )
            {
                stopGCD = YES;
            }
        }
        
    });
}

-(void)causeTap
{
    tapCount = 0;
    
    NSLog(@"causeTap");
    
    
    [self animationButtomView];
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
    
    tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(causeTap) userInfo:nil repeats:NO];
   
}

-(void)dismissView
{
    tapCount = 1;
    
    [self tapEvent];
}


-(void)addTapEvent:(UIScrollView*)scView
{
    UITapGestureRecognizer * g = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent)];
    
    [scView addGestureRecognizer:g];
}


-(void)initView
{
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [self drawViews];
 
                     }
                     completion:^(BOOL finished) {
                         
                         
                     }];
}



-(void)animationButtomView
{
    if( buttomView.hidden )
    {
        [UIView animateWithDuration:1.0 animations:^(void){
            buttomView.hidden = NO;
            buttomView.alpha = 1;
            
        }completion:^(BOOL f){
            
        }];
    }
    else
    {
        [UIView animateWithDuration:1.0 animations:^(void){
            
            buttomView.alpha = 0;
            
        }completion:^(BOOL f){
            buttomView.hidden = YES;
        }];
    }

}

-(void)layoutButtomView
{
        buttomView = [[UIView alloc]initWithFrame:CGRectMake(0,SCROLL_Y_POS*2 + SCROLL_HEIGHT, SCREEN_WIDTH, BUTTOM_VIEW_HEIGHT)];
        buttomView.backgroundColor = [UIColor whiteColor];
        buttomView.userInteractionEnabled = YES;
        buttomView.hidden = YES;
        [self addSubview:buttomView];
        
        
        //
        CGFloat xPos = self.frame.size.width/2 - (BTN_DIS + BTN_WIDHT*1.5);
        for( int i = 0; i < 3; ++ i )
        {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(xPos + i * (BTN_WIDHT+BTN_DIS), 1, BTN_WIDHT, BTN_WIDHT)];
            //btn.backgroundColor = [UIColor orangeColor];
            btn.tag = i;
            [buttomView addSubview:btn];
            
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchDown];
            
            if( 0 == i )
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
            }
            else if( 1 == i )
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
            }
            else if (2 == i )
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"del"] forState:UIControlStateNormal];
            }
        }
    //
    [self animationButtomView];
}


-(void)btnClicked:(UIButton*)btn
{
    int tag = btn.tag;
    
    NSLog(@"btnClicked:%d",tag);
    
    if( tag == 0 )
    {
        stopGCD = !stopGCD;
        
        //
        timeStr = [dataArray lastObject];
        
        //去掉时间
        [dataArray removeLastObject];
        //去掉Title
        [dataArray removeObjectAtIndex:0];
        
        //
        EditView * view = [[EditView alloc]initWithFrame:self.frame wihtArray:dataArray withTitle:titleStr withTime:timeStr withId:articleId];
        view.editDelegate = self;
        
        CATransition * animation = [CATransition animation];
        animation.delegate = self;
        animation.duration = 2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"rippleEffect";
        animation.subtype = kCATransitionFromLeft;
        [self.layer addAnimation:animation forKey:@"animation"];
 
        //stopGCD = NO;
        
        [self addSubview:view];
        
    }
    else if( tag == 1 )
    {
        [self saveImageToAlbum:nil];
    }
    else if( tag == 2 )
    {
        [self deleteArticle];
        
        [self dismissView];
    }
}


-(void)deleteArticle
{
    [[MyFMDB shareDB] deleteDiaryWithId:articleId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_ARTICLE_LIST_NOT object:nil];
    
}

//////
-(void)cancelEdit:(NSArray*)array
{
    [self editDone:array];
}

-(void)editDone:(NSArray*)array
{
    NSLog(@"editDone");
    
    if( !array )
    {
        return;
    }
    
    //
    for( UIView * view in [self subviews] )
    {
        [view removeFromSuperview];
    }
    
    //
    [dataArray removeAllObjects];
    dataArray = [array mutableCopy];
    
    //
    [self initView];
    [self layoutButtomView];
    
}


-(void)getArticleBody:(int)aId
{
   ArticleInfo * info = [[MyFMDB shareDB] queryDiaryWithId:aId];
   titleStr = info.title;

   dataArray = [ NSMutableArray arrayWithArray:[info.body componentsSeparatedByString:@"\n"]];
    
    //添加title
    [dataArray insertObject:titleStr atIndex:0];
    
    //添加time
    [dataArray addObject:[NSString stringWithFormat:@"   %@",info.time]];

}

-(id)initWithFrame:(CGRect)frame withId:(int)aId
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        articleId = aId;
        
        [self getArticleBody:aId];

        //
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        
        //
        [self initView];
        [self layoutButtomView];
        
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
