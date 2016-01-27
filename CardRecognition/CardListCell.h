//
//  CardListCell.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardImage;


@end
