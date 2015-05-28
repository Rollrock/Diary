//
//  EditView.h
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-28.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditView : UIView
@property(copy) NSArray * dataArray;

-(id)initWithFrame:(CGRect)frame wihtArray:(NSArray*)array;

@end
