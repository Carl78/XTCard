//
//  CustomOptionView.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/7.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomOptionView : NSObject

-(id)initWithParams:(NSArray *)params defaultSelectIndex:(int)selectedIndex;
-(void)didSelectIndexPath:(void(^)(NSIndexPath *indexPath,NSString *context,NSInteger tag))didSelectBlock;
@end
