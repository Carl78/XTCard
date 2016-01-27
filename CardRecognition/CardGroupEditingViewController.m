//
//  CardGroupEditingViewController.m
//  CardRecognition
//
//  Created by bournejason on 15/11/3.
//  Copyright © 2015年 bournejason. All rights reserved.
//

#import "CardGroupEditingViewController.h"
#import "CardChangeView.h"

@interface CardGroupEditingViewController ()<UIAlertViewDelegate>

@property(nonatomic, copy) OperateBlock operationBlock;
@property(nonatomic, copy) OperateBlock didDeleteBlock;
@property(nonatomic, strong) CardChangeView *targetView;
@property(nonatomic, copy) NSString *bakStr;
@end

@implementation CardGroupEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(id)initWithName:(NSString *)name andTargetValue:(NSString *)value{
    self = [super init];
    if (self) {
        self.view.frame = [UIScreen mainScreen].bounds;
        self.view.backgroundColor = [UIColor lightGrayColor];
        [self setupNavigationView];
        
        
        self.targetView = [[[NSBundle mainBundle]loadNibNamed:@"CardChangeView" owner:self options:nil]firstObject];
        self.targetView.frame = CGRectMake(0, 64, self.view.frame.size.width, 50);
        [self.targetView didDeleteOperation:^{
            if (self.didDeleteBlock) {
                self.didDeleteBlock(@"");
            }
        }];
        [self.view addSubview:self.targetView];
        
        self.targetView.titleLabel.text = @"组名";
        self.targetView.textField.text = name;
        [self.targetView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
        self.bakStr = name;
        
    }
    return self;
}

#pragma mark -

-(void)setupNavigationView {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"修改分组"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    
    [self setupMenuBarButtonItems];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,30)];
    [button setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}

- (void)setupMenuBarButtonItems {
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    negativeLeftSpacer.width = -15;
    self.navigationItem.leftBarButtonItems = @[negativeLeftSpacer, [self leftMenuBarButtonItem]];
    //self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeRightSpacer,[self rightMenuBarButtonItem]];
    
    //self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
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

- (void)rightSideMenuButtonPressed:(id)sender {
    NSString *text = self.targetView.textField.text;
    if(text.length==0||text==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"必填项不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.delegate = self;
        [alert show];
    }
    else{
        self.operationBlock(self.targetView.textField.text);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.targetView.textField becomeFirstResponder];
}


-(void)setCompleteOpertion:(OperateBlock)operation{
    self.operationBlock = [operation copy];
}
-(void)didDeleteOpertion:(OperateBlock)operation{
    self.didDeleteBlock = [operation copy];
}

- (void) textFieldDidChange:(UITextField *) TextField{
    
    NSString *name = self.targetView.titleLabel.text;
    
    if ([name isEqualToString:@"手机 *"]||[name isEqualToString:@"姓名 *"]||[name isEqualToString:@"公司 *"]||[name isEqualToString:@"手机"]||[name isEqualToString:@"姓名"]||[name isEqualToString:@"公司"]) {
        [self.targetView.deleteButton setEnabled:NO];
    }
    
}


#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.targetView.textField.text = self.bakStr;
}



@end
