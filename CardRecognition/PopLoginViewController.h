//
//  PopLoginViewController.h
//  CardRecognition
//
//  Created by bournejason on 15/6/11.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UserLoginSuccessBlock)();

@interface PopLoginViewController : UIViewController

-(void)didLoginSuccess:(UserLoginSuccessBlock)successBlock;
@end
