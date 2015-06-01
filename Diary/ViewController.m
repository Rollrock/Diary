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
#import "Header.h"


#define SCROLL_HEIGHT  200

#define LAB_WIDTH 15
#define LAB_HEIGHT SCROLL_HEIGHT

@interface ViewController ()<EditViewDelegate>
{
    NSMutableArray * articleArray;
    UIScrollView * scrView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 400, 50,50)];
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:@"显示" forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
     */
    
    {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(80, 400, 50,50)];
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:@"添加" forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(addArticle) forControlEvents:UIControlEventTouchUpInside];
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
        NSLog(@"title:%@ info.time:%@ info.body:%@ info.id:%d",info.title, info.time,info.body,info.aId);
    }
    
    [self drawViews:articleArray];
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

-(void)addTitleG:(UILabel * )lab withTag:(int)tag
{
    lab.userInteractionEnabled = YES;
    
    //
    UITapGestureRecognizer * g = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleClicked:)];
    [lab addGestureRecognizer:g];
}

-(void)titleClicked:(UITapGestureRecognizer*)g
{
    int tag = g.view.tag;
    
    [self showArticle:tag];
}

-(void)drawViews:(NSArray*)mArr
{
    scrView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0 , SCREEN_WIDTH-20 , SCROLL_HEIGHT)];
    scrView.center = self.view.center;
    scrView.showsHorizontalScrollIndicator = NO;
    scrView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:scrView];

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        
        for( int i = 0; i < [mArr count]; ++ i )
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake([mArr count] * (LAB_WIDTH*1.5) -i*(LAB_WIDTH*1.5), 0, LAB_WIDTH, LAB_HEIGHT)];
                lab.text = ((ArticleInfo*)[mArr objectAtIndex:i]).title;
                lab.font = [self getFont];
                lab.tag = ((ArticleInfo*)[mArr objectAtIndex:i]).aId;
                
                [self addTitleG:lab withTag:lab.tag];
                
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
                
                [UIView animateWithDuration:1 animations:^(void){
                    
                    lab.alpha = 1.0;
                    
                }];
            });
            
            sleep(1);
        }
        
    });
}


-(void)showArticle:(int)aId
{
    ShowView * view = [[ShowView alloc]initWithFrame:CGRectMake(0, 0, 320, 480) withId:aId];
    
    
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:animation forKey:@"animation"];
    
    
    [self.view addSubview:view];
    

}

-(void)addArticle
{
    EditView * view = [[EditView alloc]initWithFrame:self.view.frame wihtArray:nil withTitle:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
