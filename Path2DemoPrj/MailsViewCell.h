//
//  MailsViewCell.h
//  虎踞龙蟠
//
//  Created by 张晓波 on 6/6/12.
//  Copyright (c) 2012 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "BBSAPI.h"

@interface MailsViewCell : UITableViewCell
{
    IBOutlet UILabel * authorLabel;
    IBOutlet UILabel * titleLabel;
    IBOutlet UILabel * timeLabel;
    UIImageView * notificationImageView;
    Mail * mail;
}
@property(nonatomic, strong)Mail * mail;
@end
