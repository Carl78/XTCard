//
//  OptionTableView.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/6.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionTableView : UITableView

-(id)initWithFrame:(CGRect)frame
             style:(UITableViewStyle)style
            params:(NSArray *)params
defaultSelectIndex:(int)selectedIndex;

-(void)didSelectIndexPath:(void(^)(NSIndexPath *indexPath,NSString *context,NSInteger tag))didSelectBlock;
@end
