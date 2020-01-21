//  音频播放器
//  GSVoicePlayer.h
//  YiShopCustomer
//
//  Created by Gamin on 2019/4/25.
//  Copyright © 2019年 重庆市礼仪之邦电子商务有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSVoicePlayer : NSObject <AVAudioPlayerDelegate>

+ (id)sharedVoicePlayerMethod;

/// 播放音频
- (void)playWithFilePath:(NSString *)filePath;

/// 停止
- (void)stopVoice;

/// 获取音频时长
+ (NSTimeInterval)audioDurationFromURL:(NSString *)url;

// caf转MP3 0:转换失败 1:转换成功
typedef void (^TransformCafToMP3Block)(NSInteger mark);
+ (NSURL *)transformCAFToMP3:(NSURL *)sourceUrl Success:(TransformCafToMP3Block)success;

@end

NS_ASSUME_NONNULL_END
