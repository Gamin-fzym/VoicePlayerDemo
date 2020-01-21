//
//  GSVoicePlayer.m
//  YiShopCustomer
//
//  Created by Gamin on 2019/4/25.
//  Copyright © 2019年 重庆市礼仪之邦电子商务有限公司. All rights reserved.
//

#import "GSVoicePlayer.h"
// 导入系统框架
#import "lame.h"
#import "gsAmrFileCodec.h"

static GSVoicePlayer *voicePlayerObject = nil;
static AVPlayer *avPlayer = nil;
static AVAudioPlayer *audioPlayer = nil;

@implementation GSVoicePlayer

+ (id)sharedVoicePlayerMethod {
    @synchronized (self){
        if (!voicePlayerObject) {
            voicePlayerObject = [[GSVoicePlayer alloc] init];
        }
        return voicePlayerObject;
    }
    return voicePlayerObject;
}

- (void)playWithFilePath:(NSString *)filePath {
    if (![filePath isKindOfClass:[NSString class]]) {
        filePath = @"";
    }
    if ([filePath containsString:@".amr"] || [filePath containsString:@"/var/mobile/"]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self playAVAudioPlayerWithFilePath:filePath];
        });
    } else {
        [self playAVPlayerWithFilePath:filePath];
    }
}

- (void)stopVoice {
    [self stopVoiceAction];
    [self finishedNFAction];
}

- (void)stopVoiceAction {
    avPlayer = nil;
    audioPlayer = nil;
}

// 结束播放通知
- (void)finishedNFAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GSPlayFinishedNotification" object:nil];
}

#pragma mark - AVPlayer
// 播放网络音频
- (void)playAVPlayerWithFilePath:(NSString *)filePath {
    if (avPlayer.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [self stopVoice];
    } else {
        [self stopVoiceAction];
        avPlayer = [[AVPlayer alloc] init];
        // 设置播放的项目
        NSURL *url = [NSURL URLWithString:filePath];
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
        [avPlayer replaceCurrentItemWithPlayerItem:item];
        [avPlayer play];
        // 添加播放结束监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:avPlayer.currentItem];
    }
}

// 播放完成
- (void)playbackFinished:(id)sender {
    [self finishedNFAction];
}

#pragma mark - AVAudioPlayer
// 播放本地音频
- (void)playAVAudioPlayerWithFilePath:(NSString *)filePath {
    if (audioPlayer.isPlaying) {
        [self stopVoice];
    } else {
        [self stopVoiceAction];
        NSError *playError;
        // audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:&playError];
        NSData *wavData;
        if ([filePath containsString:@"/var/mobile/"]) {
            // 播放本地音频
            wavData = [NSData dataWithContentsOfFile:filePath];
        } else {
            // 用来播放安卓的amr格式 方法必须放在异步中执行下载和转码
            NSData *amrData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
            wavData = DecodeAMRToWAVE(amrData);
        }
        audioPlayer = [[AVAudioPlayer alloc] initWithData:wavData error:&playError];
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self finishedNFAction];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    [self finishedNFAction];
}

#pragma mark - 其它功能
// 获取音频时长
+ (NSTimeInterval)audioDurationFromURL:(NSString *)url {
    AVURLAsset *audioAsset = nil;
    NSDictionary *dic = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)};
    if ([url hasPrefix:@"http"]) {
        audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:dic];
    } else {
        audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:url] options:dic];
    }
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

// caf转MP3
+ (NSURL *)transformCAFToMP3:(NSURL *)sourceUrl Success:(TransformCafToMP3Block)success {
    NSURL *mp3FilePath,*audioFileSavePath;
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    mp3FilePath = [NSURL URLWithString:[path stringByAppendingPathComponent:@"CDPAudioFiles/CDPAudioRecord.mp3"]];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([[sourceUrl absoluteString] cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                                   //skip file header
        FILE *mp3 = fopen([[mp3FilePath absoluteString] cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        NSLog(@"sour-- %@   last-- %@",sourceUrl,mp3FilePath);
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000.0); // 这里与录制音频时的“采样率”必须一致
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        if (success) {
            success(0);
        }
    }
    @finally {
        audioFileSavePath = mp3FilePath;
        NSLog(@"MP3生成成功: %@",audioFileSavePath);
        if (success) {
            success(1);
        }
    }
    return audioFileSavePath;
}

@end
