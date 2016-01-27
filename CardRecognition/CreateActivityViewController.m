//
//  CreateActivityViewController.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CreateActivityViewController.h"
#import "ActivityHttpRequestService.h"
#import "RMMapper.h"
#import "ActivityTypeObject.h"
#import "OptionTableView.h"
#import "Contactactivity.h"
#import "TimeUtil.h"
#import "ExceptionInfo.h"
#import "SVProgressHUD.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kAlert_delete_tag 1
#define kAlert_callbackOfDelete_tag 2
#define KAlert_save_tag 3
#define KAlert_update_tag 4


@interface CreateActivityViewController ()<UIAlertViewDelegate,UITextViewDelegate>
@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) NSArray *activityTypeList;
@property(nonatomic) NSUInteger selectIndex;
@end

@implementation CreateActivityViewController


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ActivityHttpRequestService *request = [[ActivityHttpRequestService alloc]init];
        [request getActivityTypeListWithSuccess:^(NSString *strToken) {
           
            NSLog(@"%@",strToken);
            NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            NSMutableArray *tempArr = [NSMutableArray array];
            for (NSDictionary *dict in dataArr) {
                ActivityTypeObject *obj = [RMMapper objectWithClass:[ActivityTypeObject class] fromDictionary:dict];
                [tempArr addObject:obj];
            }
            
            self.activityTypeList = tempArr;
            self.selectIndex = 0;
            
            ActivityTypeObject *obj = self.activityTypeList.firstObject;
            
            NSString *text = self.currentActivityTypeLabel.text;
            
            if ([text isEqualToString:@""]) {
                self.currentActivityTypeLabel.text = obj.Name;
            }
            
            
            
        } error:^(NSString *strFail) {
            NSLog(@"Fail");
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sendActivityButton.layer.masksToBounds = YES;
    self.sendActivityButton.layer.cornerRadius = 2.0f;
    self.sendActivityButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.sendActivityButton.layer.borderWidth = 0.5f;
    
    self.cancelButton.layer.masksToBounds = YES;
    self.cancelButton.layer.cornerRadius = 2.0f;
    self.cancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cancelButton.layer.borderWidth = 0.5f;
    
    self.updataButton.layer.masksToBounds = YES;
    self.updataButton.layer.cornerRadius = 2.0f;
    self.updataButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.updataButton.layer.borderWidth = 0.5f;
    
    NSString *title = @"";
    
    // 新建
    if ([self.contactactivity.Id intValue] == 0) {
        self.updataButton.hidden = YES;
        self.updataButton.enabled = NO;
        title = @"新建活动";
    }else{
        // 修改
        
        title = @"修改活动";
        self.iconImageView.hidden = YES;
        self.sendActivityButton.hidden = YES;
        self.sendActivityButton.enabled = NO;
        self.cancelButton.hidden = YES;
        self.cancelButton.enabled = NO;
        
        self.updataButton.hidden = NO;
        self.updataButton.enabled = YES;
        
        self.optionButton.enabled = NO;
        
        [self.cancelButton setTitle:@"提交更新" forState:UIControlStateNormal];
        
        NSString *activityName = @"";
        NSString *contentText = @"";
        
        if (![self.contactactivity.ActivitypeName isKindOfClass:[NSNull class]]) {
            activityName = self.contactactivity.ActivitypeName;
        }
        if (![self.contactactivity.Content isKindOfClass:[NSNull class]]) {
            contentText = self.contactactivity.Content;
        }
        
        self.currentActivityTypeLabel.text = [NSString stringWithFormat:@"%@",activityName];
        self.contentTextView.text =  [NSString stringWithFormat:@"%@",contentText] ;
        
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:title];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    [self setupMenuBarButtonItems];
    
    
    
}
- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,30)];
    
    [button setImage:[UIImage imageNamed:@"card_info_delete"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
//    item.style = UIBarButtonSystemItemTrash;
    return item;
}

- (void)rightSideMenuButtonPressed:(id)sender {
    
    NSString *message = [NSString stringWithFormat:@"你确定要删除%@吗?",self.contactactivity.ActivitypeName];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除操作"
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"确定", nil];
    alert.tag = kAlert_delete_tag;
    [alert show];
}

- (void)setupMenuBarButtonItems {
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    negativeLeftSpacer.width = -15;
    self.navigationItem.leftBarButtonItems = @[negativeLeftSpacer, [self leftMenuBarButtonItem]];
    
    if ([self.contactactivity.Id intValue] != 0) {
        UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeRightSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = @[negativeRightSpacer,[self rightMenuBarButtonItem]];
    }
    
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"return_back_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"return_back_pressed"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, -55, 0, 0)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    item.style = UIBarButtonSystemItemAction;
    
    
    
    return item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chooseActivityType:(id)sender {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
    
    NSUInteger count = self.activityTypeList.count;
    
    CGFloat cellHeight = 44.0f;
    
    
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-10, 44*count+10)];
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.layer.masksToBounds = NO;
    backgroundView.layer.cornerRadius = 5.0f;
    backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
    backgroundView.layer.borderWidth = 0.5f;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:backgroundView.bounds];
    backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    backgroundView.layer.shadowOffset = CGSizeMake(5, 5);
    backgroundView.layer.shadowRadius = 5.0f;
    backgroundView.layer.shadowOpacity = 0.5f;
    backgroundView.layer.shadowPath = shadowPath.CGPath;
    
    backgroundView.center = self.window.center;
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, backgroundView.bounds.size.width-10, 44*count)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 5.0f;
    
    [self.window addSubview:backgroundView];
    contentView.center = CGPointMake(backgroundView.bounds.size.width/2, backgroundView.bounds.size.height/2);
    
    [backgroundView addSubview:contentView];
    
    CGFloat alphe = self.window.alpha;
    self.window.alpha = 0;
    [self.window makeKeyAndVisible];
    
    /////////////////
    NSMutableArray *titleNameArr = [NSMutableArray array];
    for (ActivityTypeObject *obj in self.activityTypeList) {
        [titleNameArr addObject:obj.Name];
    }
    
    OptionTableView *showTableView  = [[OptionTableView alloc]initWithFrame:CGRectMake(0, 0, backgroundView.bounds.size.width-10, 44*count) style:UITableViewStylePlain params:titleNameArr defaultSelectIndex:self.selectIndex];
    [showTableView didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
        self.selectIndex = indexPath.row;
        ActivityTypeObject *obj = self.activityTypeList[self.selectIndex];
        self.currentActivityTypeLabel.text = obj.Name;
        [self removeCurrentWindow:nil];
    }];
    
    contentView.clipsToBounds = YES;
    [contentView addSubview:showTableView];
    
    UIControl *control = [[UIControl alloc]initWithFrame:self.window.bounds];
    [control addTarget:self action:@selector(removeCurrentWindow:) forControlEvents:UIControlEventTouchUpInside];
    [self.window insertSubview:control belowSubview:backgroundView];
    
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.window.alpha = alphe;
    }];
}

-(void)removeCurrentWindow:(id)sender {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.window.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.window.hidden = YES;
        [self.window removeFromSuperview];
        self.window = nil;
    }];
    
}
- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addContact:(id)sender {
    
    ActivityTypeObject *obj = self.activityTypeList[self.selectIndex];
    
    self.contactactivity.Activitytype = obj.Id;
    self.contactactivity.Content = self.contentTextView.text;
    self.contactactivity.Activitytime = [TimeUtil getCurrentTime];
    
    ActivityHttpRequestService *request = [[ActivityHttpRequestService alloc]init];
    [SVProgressHUD show];
    [request addContactByContivity:self.contactactivity success:^(NSString *strToken) {
       
        NSLog(@"%@",strToken);
        [SVProgressHUD dismiss];
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        ExceptionInfo *info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:@"%@",info.Info]
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        alert.tag = KAlert_save_tag;
        
        [alert show];
        
    } error:^(NSString *strFail) {
        [SVProgressHUD dismiss];
    }];
}

- (IBAction)updataContact:(id)sender {
    self.contactactivity.Content = self.contentTextView.text;
    self.contactactivity.Activitytime = [TimeUtil getCurrentTime];
    ActivityHttpRequestService *request = [[ActivityHttpRequestService alloc]init];
    [SVProgressHUD show];
    [request addContactByContivity:self.contactactivity success:^(NSString *strToken) {
        
        NSLog(@"%@",strToken);
        
        [SVProgressHUD dismiss];
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        ExceptionInfo *info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:@"%@",info.Info]
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        alert.tag = KAlert_update_tag;
        
        [alert show];
        
    } error:^(NSString *strFail) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kAlert_delete_tag && buttonIndex == 1) {
        ActivityHttpRequestService *request = [[ActivityHttpRequestService alloc]init];
        [SVProgressHUD show];
        [request deleteContactByContactId:self.contactactivity.Id success:^(NSString *strToken) {
            [SVProgressHUD dismiss];
            NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            ExceptionInfo *info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[NSString stringWithFormat:@"%@",info.Info]
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            if ([info.Result intValue] > 0) {
                alert.tag = kAlert_callbackOfDelete_tag;
                alert.delegate = self;
            }
            [alert show];
        } error:^(NSString *strFail) {
            [SVProgressHUD dismiss];
        }];
    }else if (alertView.tag == kAlert_callbackOfDelete_tag){
        [self.navigationController popViewControllerAnimated:YES];
    }else if(alertView.tag == KAlert_save_tag){
        [self.navigationController popViewControllerAnimated:YES];
    }else if(alertView.tag == KAlert_update_tag){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    UIButton *btn = [[UIButton alloc]initWithFrame:[UIScreen mainScreen].bounds];
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(clearScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return YES;
}

-(void)clearScreen:(UIButton *)sender {
    
    [self.contentTextView resignFirstResponder];
    
    [sender removeFromSuperview];
    sender = nil;
}

@end
