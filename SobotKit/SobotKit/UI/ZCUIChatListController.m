//
//  ZCUIChatListController.m
//  SobotKit
//
//  Created by zhangxy on 2017/9/5.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCUIChatListController.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"

#import "ZCUIChatListCell.h"
#define cellIdentifier @"ZCUIChatListCell"
#import "ZCSobot.h"

#import "ZCIMChat.h"
#import "ZCLocalStore.h"
#import "ZCUIConfigManager.h"


@interface ZCUIChatListController ()<UITableViewDelegate,UITableViewDataSource,ZCMessageDelegate>{
    
    // 是否显示系统状态栏，退出时显示
    BOOL                        navBarHide;
}

@property(nonatomic,strong)UITableView      *listTable;
@property(nonatomic,strong)NSMutableArray   *listArray;

@end

@implementation ZCUIChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [ZCUIConfigManager getInstance].kitInfo = _kitInfo;
    
    navBarHide=self.navigationController.navigationBarHidden;
    
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = false,
    
    [self createTableView];
    
    [self createTitleView];
    [self.titleLabel setText:ZCSTLocalString(@"消息中心")];
    self.moreButton.hidden = YES;
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [self loadMoreData];
    [ZCIMChat getZCIMChat].delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_BACK){
        [ZCIMChat getZCIMChat].delegate = nil;
        
        self.navigationController.navigationBarHidden = navBarHide;
        
        if(self.navigationController != nil ){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}




-(void)createTableView{
    _listArray = [[NSMutableArray alloc] init];
    
    _listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight , ScreenWidth, ScreenHeight-NavBarHeight)];
    
    [_listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    _listTable.delegate=self;
    _listTable.dataSource=self;
    [_listTable setSeparatorColor:[UIColor clearColor]];
    [_listTable setBackgroundColor:[UIColor clearColor]];
    _listTable.clipsToBounds=NO;
    [_listTable registerClass:[ZCUIChatListCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:_listTable];
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_listTable setTableFooterView:view];
    
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    
    
    [_listTable setSeparatorColor:UIColorFromRGB(LineTextMenuColor)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    [self setTableSeparatorInset];
    
    [ZCIMChat getZCIMChat].delegate = self;
}


/**
 加载更多
 */
-(void)loadMoreData{
    _listArray = [[ZCPlatformTools sharedInstance] getPlatformList:_userId];
    
    [_listTable reloadData];
}



#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
     if(_listArray==nil || _listArray.count==0){
        return 80;
    }else{
        return 0;
    }
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(_listArray==nil || _listArray.count==0){
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(12, 40, ScreenWidth-24, 40)];
        [label setFont:ListDetailFont];
        [label setText:@"没有任何消息!"];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:UIColorFromRGB(TextTimeColor)];
        [label setBackgroundColor:[UIColor clearColor]];
        [view addSubview:label];
        return view;
    }
    return nil;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil){
        return 0;
    }
    return _listArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCUIChatListCell *cell = (ZCUIChatListCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell =  (ZCUIChatListCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        
        
    }
    if(indexPath.row==_listArray.count-1){
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
    }
    
//        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
//        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(BgTextColor)];
    if(_listArray.count < indexPath.row){
        return cell;
    }
    
    ZCPlatformInfo *model=[_listArray objectAtIndex:indexPath.row];
    [cell dataToView:model];
    
    
    return cell;
}



// 是否显示删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

// 删除清理数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    editingStyle = UITableViewCellEditingStyleDelete;
}


// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_listArray==nil || _listArray.count<indexPath.row){
        return;
    }
    ZCPlatformInfo *info = [_listArray objectAtIndex:indexPath.row];
    if([ZCLibClient getZCLibClient].libInitInfo==nil || ![info.appkey isEqual:[ZCLibClient getZCLibClient].libInitInfo.appKey]){
        [ZCLibClient getZCLibClient].libInitInfo = [[ZCLibInitInfo alloc] initByJsonDict:[ZCLocalStore dictionaryWithJsonString:info.configJson]];
    }
    [ZCIMChat getZCIMChat].delegate = nil;
    
    [ZCSobot startZCChatView:_kitInfo with:self target:nil pageBlock:^(ZCUIChatController *object, ZCPageBlockType type) {
        
    } messageLinkClick:nil];
    
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        [self setTableSeparatorInset];
    }
}

-(void)viewDidLayoutSubviews{
    [self setTableSeparatorInset];
}

#pragma mark UITableView delegate end

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
}


#pragma mark 消息监听
-(void)onReceivedMessage:(ZCLibMessage *)message unReaded:(int)num object:(id)obj showType:(ZCReceivedMessageType)type{
    [self loadMoreData];
}

-(void)onConnectStatusChanged:(ZCConnectStatusCode)status{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
