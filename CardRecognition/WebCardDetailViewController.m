//
//  WebCardDetailViewController.m
//  CardRecognition
//
//  Created by bournejason on 15/6/3.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "WebCardDetailViewController.h"
#import "RecognitionResultTableViewCell.h"
#import "GroupItemTableView.h"
#define kInputBackColor 0x707070
@interface WebCardDetailViewController (){
    
    UITableView *mainTableView;
    UITableView *addTableView;
    
    NSArray *mainDataTitle;
    NSArray *addDataTitle;
}
@end
@implementation WebCardDetailViewController

- (void)viewDidLoad {
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    
    [super viewDidLoad];
    
    //
    mainDataTitle = [NSArray arrayWithObjects:@"姓名",@"公司",@"职称",@"手机",@"固话",@"传真",@"邮件",@"地址",@"备注", nil ];
    addDataTitle = [NSArray arrayWithObjects:@"分组",@"行业",@"地区", nil];
    // Do any additional setup after loading the view.
    //初始化主View
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mainView.backgroundColor = [UIColor blackColor];
    self.view = mainView;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    //初始化tableview
    mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, width, 200)];
    mainTableView.tag = 1;
    addTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 200+64, width, height-200-64)];
    addTableView.tag = 2;
}

#pragma mark -数据表操作
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if (tableView.tag==1) {
        return self.mainData.count;
    }else{
        return self.addData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cell";
    
    
   
    if (tableView.tag == 1) {
        RecognitionResultTableViewCell *cell = [[RecognitionResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.titleLabel.text = [self.mainData objectAtIndex:indexPath.row];
        cell.contentLabel.text = [self.mainData objectAtIndex:indexPath.row];
        
        return cell;
    }else{
        GroupItemTableView *cell = [[GroupItemTableView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:((float)((kInputBackColor & 0xFF0000) >> 16))/255.0 green:((float)((kInputBackColor & 0xFF00) >> 8))/255.0 blue:((float)(kInputBackColor & 0xFF))/255.0 alpha:1.0];
        cell.titleLabel.text = [self.addData objectAtIndex:indexPath.row];
        cell.contentLabel.text = [self.addData objectAtIndex:indexPath.row];
        return cell;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 38;
}

@end
