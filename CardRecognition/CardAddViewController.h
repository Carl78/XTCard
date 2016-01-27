//
//  CardAddViewController.h
//  CardRecognition
//  新增名片视图控制器
//  Created by bournejason on 15/5/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPopoverListView.h"
@interface CardAddViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPopoverListViewDataSource, UIPopoverListViewDelegate>

@property (strong,nonatomic) UINavigationController *navigation;
@end
