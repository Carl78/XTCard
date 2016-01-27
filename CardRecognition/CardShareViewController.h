//
//  CardShareViewController.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/6.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardShareViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property(nonatomic, strong) NSNumber *cardId;
@end
