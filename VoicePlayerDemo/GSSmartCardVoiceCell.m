//
//  GSSmartCardVoiceCell.m
//  YiShopCustomer
//
//  Created by Gamin on 2019/4/19.
//  Copyright © 2019年 重庆市礼仪之邦电子商务有限公司. All rights reserved.
//

#import "GSSmartCardVoiceCell.h"
#import "TLRecorderIndicatorView.h"
#import "CDPAudioRecorder.h"
#import "View+MASAdditions.h"
#import "GSVoicePlayer.h"
#import "MBProgressHUD.h"
#import "UIView+Toast.h"

#define KWindow [UIApplication sharedApplication].keyWindow

@interface GSSmartCardVoiceCell () <CDPAudioRecorderDelegate> {
    CDPAudioRecorder *_recorder; // recorder对象
    UIImageView *_imageView; // 音量图片
    UIButton *_recordBt; // 录音bt
    UIButton *_playBt;   // 播放bt
    UIButton *_deleBt;   // 删除bt
    double currentTime;
}
// 录音展示view
@property (nonatomic, strong) TLRecorderIndicatorView *recorderIndicatorView;;
@property (nonatomic, assign) BOOL isClick;

@end

@implementation GSSmartCardVoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_longPressButton addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchDown];
    [_longPressButton addTarget:self action:@selector(endRecord:) forControlEvents:UIControlEventTouchUpInside];
    [_longPressButton addTarget:self action:@selector(cancelRecord:) forControlEvents:UIControlEventTouchDragExit];
}

// 判断字符串是否不全为空
- (BOOL)judgeStringIsNull:(NSString *)string {
    if (![[string class] isSubclassOfClass:[NSString class]]) {
        return NO;
    }
    if ([[string class] isSubclassOfClass:[NSNumber class]]) {
        return YES;
    }
    BOOL result = NO;
    if (string != nil && string.length > 0) {
        for (int i = 0; i < string.length; i ++) {
            NSString *subStr = [string substringWithRange:NSMakeRange(i, 1)];
            if (![subStr isEqualToString:@" "] && ![subStr isEqualToString:@""]) {
                result = YES;
            }
        }
    }
    return result;
}

- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)releaseAction {
    // 结束播放
    [_recorder stopPlaying];
    // 结束录音
    [_recorder stopRecording];
    _cancelWConstraint.constant = 0;
    _secondLab.text = @"";
    _longPressView.hidden = YES;
    _voiceView.hidden = YES;
    _voiceMarkIV.image = [UIImage imageNamed:@"erty2"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initWithObject:(id)object IndexPath:(NSIndexPath *)indexPath {
    [self releaseAction];
    if (object) {
        _dataModel = (GSSmartCardCustomModel *)object;
        _photoIV.image = [UIImage imageNamed:@"mrtx-yx"];
    
        [self updateViewAction];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GSPlayFinishedNotification:) name:@"GSPlayFinishedNotification" object:nil];
    }
}

// 结束播放通知
- (void)GSPlayFinishedNotification:(id)sender {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // 通知主线程刷新
        [weakSelf.voiceMarkIV stopAnimating];
        weakSelf.voiceMarkIV.image = [UIImage imageNamed:@"erty2"];
    });
}

// 播放动画
- (void)imageViewAnimation {
    NSArray *imgArr = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"erty0"],[UIImage imageNamed:@"erty1"],[UIImage imageNamed:@"erty2"], nil];
    _voiceMarkIV.animationImages = imgArr;
    // 动画总时间
    _voiceMarkIV.animationDuration = imgArr.count*0.5;
    // 动画重复次数
    _voiceMarkIV.animationRepeatCount = 1000;
    [_voiceMarkIV startAnimating];
}

// 更新视图
- (void)updateViewAction {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 子线程中处理耗时操作
        if (weakSelf.dataModel.dFileModel && [self judgeStringIsNull:weakSelf.dataModel.dFileModel.filePath]) {
            NSInteger duration = [weakSelf.dataModel.dFileModel.fileLength integerValue];
            if (!(duration > 0)) {
                duration = [GSVoicePlayer audioDurationFromURL:weakSelf.dataModel.dFileModel.filePath];
                weakSelf.dataModel.dFileModel.fileLength = [NSString stringWithFormat:@"%ld",(long)duration];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 通知主线程刷新
                if (duration > 0) {
                    weakSelf.secondLab.text = [NSString stringWithFormat:@"%ld″",(long)duration];
                }
            });
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.secondLab.text = @"";
        // 是否有返回音频
        BOOL haveVoice = NO;
        if (weakSelf.dataModel.dFileModel && [self judgeStringIsNull:weakSelf.dataModel.dFileModel.filePath]) {
            haveVoice = YES;
        }
        weakSelf.cancelWConstraint.constant = 0;
        if (haveVoice) {
            weakSelf.longPressView.hidden = YES;
            weakSelf.voiceView.hidden = NO;
            if (weakSelf.enterMark == 1) {
                weakSelf.cancelWConstraint.constant = 44;
            }
        } else {
            weakSelf.longPressView.hidden = NO;
            weakSelf.voiceView.hidden = YES;
        }
    });
}

// 点击语音播放
- (IBAction)tapVoiceAction:(id)sender {
    NSString *voicePath = _dataModel.dFileModel.filePath;
    if (_dataModel.dFileModel && [self judgeStringIsNull:voicePath]) {
        [self imageViewAnimation];
        GSVoicePlayer *player = [GSVoicePlayer sharedVoicePlayerMethod];
        [player playWithFilePath:voicePath];
    }
}

// 点击删除按钮
- (IBAction)tapCancelButtonAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"是否删除录音" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.dataModel.dFileModel && [self judgeStringIsNull:weakSelf.dataModel.dFileModel.ID]) {
            [self deleteFileWithId:weakSelf.dataModel.dFileModel.ID];
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
    [[self viewController] presentViewController:alert animated:YES completion:nil];
}

// 删除录音
- (void)deleteFileWithId:(NSString *)photoId {
    if (self.cancelBlock) {
        self.cancelBlock(1, self.dataModel);
    }
    /*
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:photoId,@"id", nil];
    
    [NETManger url:@"/lbs/gs/user/delGsUserFile" WithParm:dic withType:POST SucessBlock:^(NSDictionary *reslut) {
        _dataModel.dFileModel = [GSSmartFileModel new];
        [self updateViewAction];
        GSVoicePlayer *player = [GSVoicePlayer sharedVoicePlayerMethod];
        [player stopVoice];
    } FalierBlock:^(NSError *error) {
    
    }];
     */
}

// alertView提示
- (void)alertWithMessage:(NSString *)message {
    [[self viewController].view makeToast:message];
    // [KWindow makeToast:@"提交失败"];
}

#pragma mark - CDPAudioRecorderDelegate代理事件
// 更新音量分贝数峰值(0~1)
- (void)updateVolumeMeters:(CGFloat)value {
    NSInteger no = 0;
    if (value>0 && value<=0.14) {
        no = 1;
    } else if (value <= 0.28) {
        no = 2;
    } else if (value <= 0.42) {
        no = 3;
    } else if (value <= 0.56) {
        no = 4;
    } else if (value <= 0.7) {
        no = 5;
    } else if (value <= 0.84) {
        no = 6;
    } else{
        no = 7;
    }
    NSString *imageName = [NSString stringWithFormat:@"mic_%ld",(long)no];
    _imageView.image = [UIImage imageNamed:imageName];
}

// 录音结束(url为录音文件地址,isSuccess是否录音成功)
- (void)recordFinishWithUrl:(NSString *)url isSuccess:(BOOL)isSuccess {
    [self.recorderIndicatorView removeFromSuperview];
    // url为得到的caf录音文件地址,可直接进行播放,也可进行转码为amr、mp3上传服务器
    NSLog(@"录音完成,文件地址:%@",url);
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"CDPAudioFiles/CDPAudioRecord.caf"];
    NSData *voiceData = [NSData dataWithContentsOfFile:filePath];
    if (voiceData) {
        // 异步caf转MP3
        [MBProgressHUD showHUDAddedTo:KWindow animated:YES];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [GSVoicePlayer transformCAFToMP3:[NSURL URLWithString:filePath] Success:^(NSInteger mark) {
                if (mark) {
                    [self dealFileAction];
                } else {
                    [self alertWithMessage:@"转码失败"];
                }
            }];
        });
    } else {
        [self alertWithMessage:@"录音失败"];
    }
}

// 转换格式成功后 上传+提交
- (void)dealFileAction {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"CDPAudioFiles/CDPAudioRecord.mp3"];
    NSData *voiceData = [NSData dataWithContentsOfFile:filePath];
    if (voiceData) {
        NSLog(@"");
        GSSmartFileModel *fileModel2 = [GSSmartFileModel new];
        fileModel2.filePath = filePath;
        fileModel2.fileLength = [NSString stringWithFormat:@"%.f",currentTime];
        fileModel2.ID = @"234";
        self.dataModel.dFileModel = fileModel2;
        if (self.cancelBlock) {
            self.cancelBlock(2, self.dataModel);
        }
        [self hideHUDWithAlert:@"提交成功"];
        /*
        __weak typeof(self) weakSelf = self;
        [OSSImageUploader uploadNoWaitWithFileData:voiceData withSuffix:@".mp3" withProgress:nil complete:^(NSString *fileName, UploadImageState state) {
            if (state == UploadImageSuccess) {
                BOOL isSuccess = NO;
                NSString *imgBasePath = [LYOSSVerifyModel shareModel].imagePath;
                if ([self judgeStringIsNull:fileName]) {
                    NSString *fileUrl = [NSString stringWithFormat:@"%@/%@",imgBasePath,fileName];
                    NSString *times;
                    times = @"0";
                    if ([self judgeStringIsNull:fileUrl]) {
                        times = [[NSNumber numberWithDouble:ceil(self->currentTime)] stringValue];
                        NSDictionary *fileDic = [NSDictionary dictionaryWithObjectsAndKeys:fileUrl,@"filePath",times,@"fileLength",nil];
                        if (fileDic) {
                            isSuccess = YES;
                            [self commitRequestWithFileList:@[fileDic]];
                        }
                    }
                }
                if (isSuccess) {
                    //[self hideHUDWithAlert:@""];?
                } else {
                    [self hideHUDWithAlert:@"提交失败"];
                }
            } else {
                [self hideHUDWithAlert:@"上传文件失败"];
            }
        }];
         */
    } else {
        [self hideHUDWithAlert:@"转码失败"];
    }
}

- (void)hideHUDWithAlert:(NSString *)alert {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:KWindow animated:YES];
        if (![alert isEqualToString:@""]) {
            [self alertWithMessage:alert];
        }
    });
}

// 提交数据
- (void)commitRequestWithFileList:(NSArray *)fileDic {
    
}

#pragma mark - 各录音点击事件
// 按下开始录音
- (void)startRecord:(UIButton *)recordBtn {
    _isClick =NO;
    [CDPAudioRecorder getAudioRecordFilePathWithMark:NO];
    // 初始化录音recorder
    _recorder = [CDPAudioRecorder shareRecorder];
    _recorder.delegate = self;
    [_recorder startRecording];
    [self.recorderIndicatorView setStatus:TLRecorderStatusRecording];
    [[self viewController].view addSubview:self.recorderIndicatorView];
    [self.recorderIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo([self viewController].view);
        make.size.mas_equalTo(CGSizeMake(150, 150));
    }];
    
    // 音量图片
    _imageView = [[UIImageView alloc] init];
    _imageView.image = [UIImage imageNamed:@"mic_0"];
    [self.recorderIndicatorView addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(64);
    }];
}

// 点击松开结束录音
- (void)endRecord:(UIButton *)recordBtn {
    [self.recorderIndicatorView removeFromSuperview];
    currentTime = _recorder.recorder.currentTime;
    NSLog(@"本次录音时长%lf",currentTime);
    if (currentTime < 1) {
        // 时间太短
        _imageView.image = [UIImage imageNamed:@"mic_0"];
        if (!_isClick) {
            [self alertWithMessage:@"说话时间太短"];
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self->_recorder stopRecording];
            [self->_recorder deleteAudioFile];
        });
    } else {
        // 成功录音
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self->_recorder stopRecording];
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_imageView.image = [UIImage imageNamed:@"mic_0"];
            });
        });
        NSLog(@"已成功录音");
    }
    _isClick = NO;
}

// 手指从按钮上移除,取消录音
- (void)cancelRecord:(UIButton *)recordBtn {
    _isClick =NO;
    [self.recorderIndicatorView removeFromSuperview];
    _imageView.image = [UIImage imageNamed:@"mic_0"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self->_recorder stopRecording];
        [self->_recorder deleteAudioFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertWithMessage:@"已取消录音"];
        });
    });
}

#pragma mark - 播放点击事件

// 播放录音
- (void)play {
    // 播放内部默认地址刚才生成的本地录音文件,不需要转码
    // [_recorder playAudioFile];
}

- (void)dele {
    [_recorder deleteAudioFile];
}

- (TLRecorderIndicatorView *)recorderIndicatorView {
    if (_recorderIndicatorView == nil) {
        _recorderIndicatorView = [[TLRecorderIndicatorView alloc] init];
    }
    return _recorderIndicatorView;
}

@end

