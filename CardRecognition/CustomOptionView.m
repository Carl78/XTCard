//
//  CustomOptionView.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/7.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CustomOptionView.h"
#import "OptionTableView.h"
typedef void(^DidSelectedIndexPathBlock)(NSIndexPath *indexPath,NSString *context,NSInteger tag);

@interface CustomOptionView ()
@property(nonatomic, strong) UIWindow *window;
@property (nonatomic, copy) DidSelectedIndexPathBlock didSelectedBlock;
@end

@implementation CustomOptionView

-(id)initWithParams:(NSArray *)params defaultSelectIndex:(int)selectedIndex{
    
    self = [super init];
    if (self) {
        self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
        
        NSUInteger count = params.count;
        if (count >= 5) {
            count = 5;
        }
        
        UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-10, 44*count+10)];
        backgroundView.backgroundColor = [UIColor clearColor];
        backgroundView.layer.masksToBounds = NO;
        backgroundView.layer.cornerRadius = 5.0f;
        backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
        backgroundView.layer.borderWidth = 0.5f;
        
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:backgroundView.bounds];
        backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
        backgroundView.layer.shadowOffset = CGSizeMake(5, 5);
        backgroundView.layer.shadowRadius = 5.0f;
        backgroundView.layer.shadowOpacity = 0.5f;
        backgroundView.layer.shadowPath = shadowPath.CGPath;
        
        backgroundView.center = self.window.center;
        
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, backgroundView.bounds.size.width-10, 44*count)];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.cornerRadius = 5.0f;
        
        [self.window addSubview:backgroundView];
        contentView.center = CGPointMake(backgroundView.bounds.size.width/2, backgroundView.bounds.size.height/2);
        
        [backgroundView addSubview:contentView];
        
        CGFloat alphe = self.window.alpha;
        self.window.alpha = 0;
        [self.window makeKeyAndVisible];
        
        /////////////////
        
        OptionTableView *showTableView  = [[OptionTableView alloc]initWithFrame:CGRectMake(0, 0, backgroundView.bounds.size.width-10, 44*count) style:UITableViewStylePlain params:params defaultSelectIndex:selectedIndex];
        [showTableView didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
            
            if (self.didSelectedBlock) {
                self.didSelectedBlock(indexPath, context,tag);
            }
            [self removeCurrentWindow:nil];
        }];
        
        contentView.clipsToBounds = YES;
        [contentView addSubview:showTableView];
        
        UIControl *control = [[UIControl alloc]initWithFrame:self.window.bounds];
        [control addTarget:self action:@selector(removeCurrentWindow:) forControlEvents:UIControlEventTouchUpInside];
        [self.window insertSubview:control belowSubview:backgroundView];
        
        
        
        [UIView animateWithDuration:0.2 animations:^{
            self.window.alpha = alphe;
        }];
    }
    return self;
}

-(void)removeCurrentWindow:(id)sender {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.window.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.window.hidden = YES;
        [self.window removeFromSuperview];
        self.window = nil;
    }];
    
}
-(void)didSelectIndexPath:(void(^)(NSIndexPath *indexPath,NSString *context,NSInteger tag))didSelectBlock{
    self.didSelectedBlock = [didSelectBlock copy];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
