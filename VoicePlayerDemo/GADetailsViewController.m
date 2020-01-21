//
//  GADetailsViewController.m
//  VoicePlayerDemo
//
//  Created by Gamin on 2019/7/12.
//  Copyright © 2019年 com.yyzb. All rights reserved.
//

#import "GADetailsViewController.h"
#import "GSSmartCardVoiceCell.h"
#import "GSSmartCardCustomModel.h"

@interface GADetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataMarr;

@end

@implementation GADetailsViewController

- (void)dealloc {
    _dataMarr = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_dataMarr) {
        _dataMarr = [NSMutableArray new];
    }
    // model1
    GSSmartCardCustomModel *voiceModel = [GSSmartCardCustomModel new];
    voiceModel.dMark = 4;
    GSSmartFileModel *fileModel = [GSSmartFileModel new];
    fileModel.filePath = @"https://lyzbjbx.oss-cn-hangzhou.aliyuncs.com/lyzblbs/wx/2019/04/26/41133f07-d886-b319-0861-fb6e03e5747e.m4a";
    fileModel.fileLength = @"3";
    fileModel.ID = @"123";
    voiceModel.dFileModel = fileModel;
    [_dataMarr addObject:voiceModel];
    // model2
    GSSmartCardCustomModel *voiceModel2 = [GSSmartCardCustomModel new];
    voiceModel2.dMark = 4;
    voiceModel2.dFileModel = nil;
    [_dataMarr addObject:voiceModel2];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataMarr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model;
    if (_dataMarr.count > indexPath.row) {
        model = [_dataMarr objectAtIndex:indexPath.row];
    }
    if ([model isKindOfClass:[GSSmartCardCustomModel class]]) {
        GSSmartCardVoiceCell *cell = (GSSmartCardVoiceCell *)[self baseInitTV:tableView Identifier:@"GSSmartCardVoiceCell"];
        [cell initWithObject:model IndexPath:indexPath];
        if (indexPath.row == 1) {
            cell.enterMark = 1;
        }
        [cell setCancelBlock:^(NSInteger mark, GSSmartCardCustomModel *dModel) {
            if (mark == 1) {
                dModel.dFileModel = nil;
                [self.tableView reloadData];
            } else if (mark == 2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
        return cell;
    }
    return [self nulCell:tableView];
}

- (UITableViewCell *)baseInitTV:(UITableView *)tv Identifier:(NSString *)cellIdentifier {
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    return cell;
}

- (UITableViewCell *)nulCell:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:@"UITableViewCell"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
