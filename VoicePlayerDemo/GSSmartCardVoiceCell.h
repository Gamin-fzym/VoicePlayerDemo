//
//  GSSmartCardVoiceCell.h
//  YiShopCustomer
//
//  Created by Gamin on 2019/4/19.
//  Copyright © 2019年 重庆市礼仪之邦电子商务有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSSmartCardCustomModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSSmartCardVoiceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoIV;      // 头像
@property (weak, nonatomic) IBOutlet UIView *longPressView;     // 长按视图
@property (weak, nonatomic) IBOutlet UIButton *longPressButton; // 长按录制按钮
@property (weak, nonatomic) IBOutlet UIView *voiceView;         // 语音视图
@property (weak, nonatomic) IBOutlet UIImageView *voiceMarkIV;  // 播放动画
@property (weak, nonatomic) IBOutlet UILabel *secondLab;        // 语音秒数
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelWConstraint; // 删除宽度
@property (assign, nonatomic) NSInteger enterMark;   // 0:他的名片 1:我的名片
@property (weak, nonatomic) GSSmartCardCustomModel *dataModel;
typedef void (^TapCancelVoiceBlock)(NSInteger mark, GSSmartCardCustomModel *dModel); // 1:点击删除语音按钮 2:录制语音上传成功
@property (strong, nonatomic) TapCancelVoiceBlock cancelBlock;

- (void)initWithObject:(id)object IndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
