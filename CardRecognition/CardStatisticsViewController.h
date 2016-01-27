//
//  CardStatisticsViewController.h
//  CardRecognition
//  名片统计视图控制器
//  Created by bournejason on 15/5/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardStatisticsViewController : UIViewController

///////////  lineChart
@property (weak, nonatomic) IBOutlet UIButton *chooseShowTypeButton;
@property (weak, nonatomic) IBOutlet UILabel *showTypeLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIButton *myCardButton;
@property (weak, nonatomic) IBOutlet UIButton *sysCardButton;
@property (weak, nonatomic) IBOutlet UIWebView *contentView;
- (IBAction)showTypeList:(id)sender;
- (IBAction)switchMyCardAndSysCard:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *LineChartView;
@property (weak, nonatomic) IBOutlet UIView *pieChartView;


/////////// pieChart
@property (weak, nonatomic) IBOutlet UILabel *pieChartInfoLabel;
@property (weak, nonatomic) IBOutlet UIWebView *pieChartWebView;
@property (weak, nonatomic) IBOutlet UIButton *pieChartShowTypeButton;
- (IBAction)pieChartChooseOtherType:(id)sender;

@end
