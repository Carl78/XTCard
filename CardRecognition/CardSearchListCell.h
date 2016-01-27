//
//  CardSearchListCell.h
//  CardRecognition
//
//  Created by bournejason on 15/9/17.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardSearchListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardImage;
@end
