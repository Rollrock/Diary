//
//  EditView.m
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-28.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "EditView.h"
#import "Header.h"

@interface EditView()
{
    UITextView * textView;
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
    }
    
    textView = [[UITextView alloc]initWithFrame:self.frame];
    textView.text = mutStr;
    textView.font = [self getFont];
    [self addSubview:textView];
}


-(id)initWithFrame:(CGRect)frame wihtArray:(NSArray*)array
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        self.backgroundColor = [UIColor whiteColor];
        
        [self layoutTextView:array];
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
