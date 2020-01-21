//  自定义model
//  GSSmartCardCustomModel.h
//  YiShopCustomer
//
//  Created by Gamin on 2019/3/19.
//  Copyright © 2019年 重庆市礼仪之邦电子商务有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class GSSmartFileModel;
@interface GSSmartCardCustomModel : NSObject
/**
 mark:
 =0 文本
 =1 图片
 =2 视频
 =4 音频
 */
@property (nonatomic, assign) NSInteger dMark;
@property (nonatomic, strong) NSString *dTxt;
@property (nonatomic, strong) NSString *dID;
@property (nonatomic, strong) GSSmartFileModel * __nullable dFileModel;

@end

@interface GSSmartFileModel : NSObject

@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *delStatus;
@property (nonatomic, strong) NSString *filePath;   // 文件路径
@property (nonatomic, strong) NSString *fileType;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *tagType;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *fileLength; // 秒数

@end

NS_ASSUME_NONNULL_END
