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

#define BTN_WIDHT 30
#define BTN_DIS  40


@interface ShowView()<EditViewDelegate>
{
    NSString * titleStr;
    
    BOOL tapCount;
    NSTimer * tapTimer;
    
    UIView * buttomView;
    
    NSMutableArray * dataArray;
    
    UIScrollView * scrView;
}

@end


@implementation ShowView



#define SCROLL_Y_POS  50
#define SCROLL_HEIGHT (SCREEN_HEIGHT - SCROLL_Y_POS*2)



#define LAB_WIDTH (FONT_SIZE+2)
#define LAB_HEIGHT  SCROLL_HEIGHT
#define LAB_HEIGHT_MIN (LAB_HEIGHT-LAB_WIDTH*2)


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
    UIImage * destImg = [self addWaterMask:[self captureScrollView:scrView] withAddImg:[UIImage imageNamed:@"1"]];
    
    UIImageWriteToSavedPhotosAlbum(destImg,self, nil, nil);
    
    NSLog(@"保存成功");
}


- (UIImage *)captureScrollView:(UIScrollView *)scrollView
{
    UIImage* image = nil;
    UIGraphicsBeginImageContext(scrollView.contentSize);
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


- (float) heightForString:(NSString *)value
{
    NSDictionary *attribute = @{NSFontAttributeName: [self getFont]};
    
    CGSize size = [value boundingRectWithSize:CGSizeMake(LAB_WIDTH, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return size.height;
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
    scrView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:scrView];
    [self addTapEvent:scrView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        
        for( int i = 0; i < [mArr count]; ++ i )
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake([mArr count] * (LAB_WIDTH*1.5) -i*(LAB_WIDTH*1.5), 0, LAB_WIDTH, LAB_HEIGHT)];
                lab.text = [mArr objectAtIndex:i];
                lab.font = [self getFont];
                
                lab.alpha = 0.0;
                
                lab.numberOfLines = 0;
                lab.lineBreakMode = NSLineBreakByCharWrapping;
                
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
                    
                    /// scrView.contentOffset = CGPointMake(scrView.contentSize.width - scrView.frame.size.width/2 - i*LAB_WIDTH*1.5, scrView.contentOffset.y);
                    
                }];
            });
            
            
            sleep(1);
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
    }
    else
    {
        tapCount = 0;
    }
    
    if( tapCount == 2 )
    {
        CATransition * animation = [CATransition animation];
        animation.delegate = self;
        animation.duration = 2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"rippleEffect";
        animation.subtype = kCATransitionFromLeft;
        [self.superview.layer addAnimation:animation forKey:@"animation"];
        
        
        [self removeFromSuperview];
    }
    
    tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(causeTap) userInfo:nil repeats:NO];
   
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
        buttomView = [[UIView alloc]initWithFrame:CGRectMake(0,SCROLL_Y_POS + SCROLL_HEIGHT, 320, 50)];
        buttomView.backgroundColor = [UIColor lightGrayColor];
        buttomView.userInteractionEnabled = YES;
        buttomView.hidden = YES;
        [self addSubview:buttomView];
        
        
        //
        CGFloat xPos = self.frame.size.width/2 - (BTN_DIS + BTN_WIDHT*1.5);
        for( int i = 0; i < 3; ++ i )
        {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(xPos + i * (BTN_WIDHT+BTN_DIS), 1, BTN_WIDHT, BTN_WIDHT)];
            btn.backgroundColor = [UIColor orangeColor];
            btn.tag = i;
            [buttomView addSubview:btn];
            
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
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
        EditView * view = [[EditView alloc]initWithFrame:self.frame wihtArray:dataArray withTitle:titleStr];
        view.editDelegate = self;
        
        CATransition * animation = [CATransition animation];
        animation.delegate = self;
        animation.duration = 2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"rippleEffect";
        animation.subtype = kCATransitionFromLeft;
        [self.layer addAnimation:animation forKey:@"animation"];
 
        [self addSubview:view];
        
    }
    else if( tag == 1 )
    {
        [self saveImageToAlbum:nil];
    }
    else if( tag == 2 )
    {
        
    }
}


-(void)deleteArticle
{
    
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
    
    //
    [dataArray insertObject:titleStr atIndex:0];
    [dataArray insertObject:@"" atIndex:0];

}

-(id)initWithFrame:(CGRect)frame withId:(int)aId
{
    self = [super initWithFrame:frame];
    if( self )
    {
        /*
        {
            dataArray = [NSMutableArray arrayWithObjects:@"轻轻的我走了",@"正如我轻轻的来；",@"我轻轻的招手，",@"作别西天的云彩。",@" ",@"那河畔的金柳，",@"是夕阳中的新娘；",@"波光里的艳影，",@"在我的心头荡漾。",@"软泥上的青荇，",@"油油的在水底招摇；",@"在康河的柔波里，",@"我甘心做一条水草。",@"那树荫下的一潭，",@"不是清泉，是天上虹；",@"揉碎在浮藻间，",@"沉淀着彩虹似的梦。",@"寻梦？撑一支长篙，",@"向青草更青处漫溯；",@"满载一船星辉，",@"在星辉斑斓里放歌。",@"但我不能放歌，",@"悄悄是别离的笙箫；",@"夏虫也为我沉默，",@"沉默是今晚的康桥！",nil];

        }
         */
        
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
