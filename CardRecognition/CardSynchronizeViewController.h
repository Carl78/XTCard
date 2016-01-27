//
//  CardSynchronizeViewController.h
//  CardRecognition
//  名片同步视图控制器
//  Created by bournejason on 15/5/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardSynchronizeViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end