//
//  RecognizeResultViewController.h
//  CardRecognition
//
//  Created by bournejason on 15/5/16.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <recognizeAPI/cardRecognizedData.h>
#import "UIPopoverListView.h"
@interface RecognizeResultViewController : UIViewController<cardSDKProtocol,UITableViewDataSource,UITableViewDelegate,UIPopoverListViewDataSource, UIPopoverListViewDelegate>

@property (assign,nonatomic) int source;
@property (strong,nonatomic) UINavigationController *navigation;

@end
