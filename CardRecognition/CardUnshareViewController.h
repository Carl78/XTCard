//
//  CardUnshareViewController.h
//  CardRecognition
//
//  Created by bournejason on 15/11/2.
//  Copyright © 2015年 bournejason. All rights reserved.
//

#import "ViewController.h"

@interface CardUnshareViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property(nonatomic, strong) NSNumber *cardId;

@end
