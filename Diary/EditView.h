//
//  EditView.h
//  Diary
//
//  Created by zhuang chaoxiao on 15-5-28.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EditViewDelegate <NSObject>

-(void)editDone:(NSArray*)array;
-(void)addDone:(int)myId;
-(void)cancelEdit:(NSArray*)array;
@end


@interface EditView : UIView

-(id)initWithFrame:(CGRect)frame wihtArray:(NSArray*)array withTitle:(NSString *)strTitle withTime:(NSString*)time withId:(int)aId;


@property(assign) id<EditViewDelegate> editDelegate;

@end
