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
#import "SettingView.h"


#define SCROLL_HEIGHT  (SCREEN_HEIGHT/2.0+0)

#define LAB_WIDTH ([ShareInfo getLabWidth])
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
    
    
    {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 400, 50,50)];
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:@"设置" forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
        //[self.view addSubview:btn];
    }
    
    
    {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 35 -10, SCREEN_HEIGHT - 35 - 10, 30,30)];
        [btn setTitle:@"添加" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        
        btn.titleLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:20];
        
        [btn addTarget:self action:@selector(addArticle) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:btn];
    }
    
    //
    [MyFMDB shareDB];
    [ShareInfo addDemoDiary];
    //
    [self addReloadListNot];
    //
    [self layoutArticleList];
}

-(void)layoutArticleList
{
    articleArray = [NSMutableArray arrayWithArray:[[MyFMDB shareDB] queryDiary]];
    
    //
    for( ArticleInfo * info in articleArray )
    {
        NSLog(@"title:%@ info.time:%@ info.body:%@ info.id:%d",info.title, info.time,info.body,info.aId);
    }
    
    [self drawViews:articleArray];
}



- (float) heightForString:(NSString *)value
{
    NSDictionary *attribute = @{NSFontAttributeName: [ShareInfo getBodyFont]};
    
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
    if( !scrView )
    {
        UIImageView * bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCROLL_HEIGHT+20)];
        bgView.image = [UIImage imageNamed:@"list_bg"];
        bgView.center = self.view.center;
        //[self.view addSubview:bgView];
        

        scrView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0 , SCREEN_WIDTH-40 , SCROLL_HEIGHT)];
        scrView.center = self.view.center;
        scrView.showsHorizontalScrollIndicator = NO;
        scrView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:scrView];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        
        for( int i = 0; i < [mArr count]; ++ i )
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake([mArr count] * (LAB_WIDTH*1.5) -i*(LAB_WIDTH*1.5), 0, LAB_WIDTH, LAB_HEIGHT)];
                lab.text = ((ArticleInfo*)[mArr objectAtIndex:i]).title;
                lab.font = [ShareInfo getBodyFont];
                lab.tag = ((ArticleInfo*)[mArr objectAtIndex:i]).aId;
                
                [self addTitleG:lab withTag:lab.tag];
                
                lab.alpha = 0.0;
                
                lab.numberOfLines = 0;
                lab.lineBreakMode = NSLineBreakByWordWrapping;
                
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
    ShowView * view = [[ShowView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) withId:aId];
    
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
    EditView * view = [[EditView alloc]initWithFrame:self.view.frame wihtArray:nil withTitle:nil withTime:nil withId:0];
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

-(void)setting
{
    SettingView * view = [[SettingView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:animation forKey:@"animation"];
    
    
    [self.view addSubview:view];
}

-(void)addDone:(int)myId
{
    [self showArticle:myId];
}

//重新加载list
-(void)reloadList
{
    [articleArray removeAllObjects];
    articleArray = nil;
    
    //
    for( UIView * view in [scrView subviews] )
    {
        [view removeFromSuperview];
    }
    
    //
    [self layoutArticleList];

}

-(void)addReloadListNot
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList) name:RELOAD_ARTICLE_LIST_NOT object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
