//
//  WebCardDetailViewController.h
//  CardRecognition
//
//  Created by bournejason on 15/6/3.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebCardDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSArray *mainData;
@property (strong,nonatomic) NSArray *addData;

@end
