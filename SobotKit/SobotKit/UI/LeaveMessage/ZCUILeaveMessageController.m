//
//  ZCUILeaveMessageController.m
//  SobotKit
//
//  Created by lizhihui on 16/1/21.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "ZCUILeaveMessageController.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIPlaceHolderTextView.h"
#import "ZCLibServer.h"
#import "ZCUIConfigManager.h"
#import "ZCPlatformTools.h"
#import "ZCMLEmojiLabel.h"
#import "ZCUIWebController.h"
#import "ZCStoreConfiguration.h"

#import "ZCXJAlbumController.h"
#import "ZCSobotCore.h"
#import "ZCActionSheet.h"

#import "ZCUILoading.h"


typedef NS_ENUM(NSInteger,ExitType) {
    ISCOLSE         = 1,// 直接退出SDK
    ISNOCOLSE       = 2,// 不直接退出SDK
    ISBACKANDUPDATE = 3,// 仅人工模式 点击技能组上的留言按钮后,（返回上一页面 提交退出SDK）
    ISROBOT         = 4,// 机器人优先，点击技能组的留言按钮后，（返回技能组 提交和机器人会话）
    ISUSER          = 5,// 人工优先，点击技能组的留言按钮后，（返回技能组 提交机器人会话）
};

@interface ZCUILeaveMessageController ()<UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,ZCMLEmojiLabelDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,ZCActionSheetDelegate,ZCXJAlbumDelegate>
{
    UIImageView   *_imageView;
    ZCMLEmojiLabel   *_describeLabel;
    UITextField   *_emailTf;
    ZCUIPlaceHolderTextView    *_megTextView;
    UIScrollView  *_scrollView;
    UIView *_photoView;
    
    CGRect scFrame  ;
    
    void(^CloseBlock)();// 直接退出
    
    BOOL isLandScape ; // 是否是横屏
    
    UIView *_bgview;
    
    
    UITextField * _phoneTf;
    
    UIView * _nickBgview;
    
    UIView *_phoneBgView;
    
    // 链接点击
    void (^LinkedClickBlock) (NSString *url);
    
    // 呼叫的电话号码
    NSString                    *callURL;
    
    NSMutableArray  *imageArr;
    NSMutableArray  *imageURLArr;
    UIButton        *curCheckButton;
    
}

// 是否点击提交（在调用提交留言接口没有结束之前不可在点击提交）

@property (nonatomic,strong)UITextField * nickNameTf;

@property (nonatomic, assign) BOOL isSend;
/** 系统相册相机图片 */
@property (nonatomic,strong) UIImagePickerController *zc_imagepicker;
@end

@implementation ZCUILeaveMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0Xf2f4f5);

    // 获取用户初始化配置参数
    [self customLayoutSubviewsWith:[ZCUIConfigManager getInstance].kitInfo];
    // 注意图层关系
    [self createTitleView];
    
    self.titleLabel.text = ZCSTLocalString(@"留言");
    
//    self.moreButton.hidden = NO;
    // 提交
    [self.moreButton setImage:nil forState:UIControlStateNormal];
    [self.moreButton setImage:nil forState:UIControlStateHighlighted];
    [self.moreButton setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton.alpha = 0.4;
    self.moreButton.userInteractionEnabled = NO;
    
    //back
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _isSend = NO;

    if(iOS7){
        if(self.navigationController!=nil){
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            self.navigationController.interactivePopGestureRecognizer.delegate = self;
            self.navigationController.delegate = self;
        }
    }
    
    if (_isShowToat) {
        [[ZCUIToastTools shareToast] showToast:_tipMsg duration:3.0f view:self.view position:ZCToastPositionBottom];
    }
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

/**
 *  监听滑动返回的事件
 *
 *  @param navigationController  导航控制器
 *  @param viewController  将要显示的VC
 *  @param animated  是否添加动画
 */
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 解决ios7调用系统的相册时出现的导航栏透明的情况
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        return;
    }
    
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    __weak ZCUILeaveMessageController *safeVC = self;
    [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(![context isCancelled]){
            // 设置页面不能使用边缘手势关闭
            if(iOS7 && navigationController!=nil){
                navigationController.interactivePopGestureRecognizer.enabled = NO;
            }
            
//            __strong __typeof(self) strongSelf = safeVC;
            [safeVC backAction];
        }
    }];
    
}
#pragma mark -- 系统键盘的监听事件
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 影藏NavigationBar
    [self.navigationController setNavigationBarHidden:YES];
  
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [_emailTf resignFirstResponder];
    [_megTextView resignFirstResponder];
    if (iOS7) {
        if (self.navigationController !=nil) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
            self.navigationController.delegate = nil;
        }
    }
    
    // 移除键盘的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}



// 隐藏键盘
-(void)downKeyBoard:(id)sender{
    [_emailTf resignFirstResponder];
    [_megTextView resignFirstResponder];
    [_phoneTf resignFirstResponder];
    [_nickNameTf resignFirstResponder];
}

-(void)keyboardHide:(NSNotification*)notification{
    
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
}



#pragma mark -- 提交事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_MORE){
        [self checkCommitStatus];
        
        if(_emailTf!=nil && zcLibTrimString(_emailTf.text).length>0){
            if(![self match:_emailTf.text]){
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"邮箱格式不正确") duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
        }
        
        [self UpLoad];
        
        [self downKeyBoard:nil];
    }
    
    if(sender.tag == BUTTON_BACK){
        [self backAction];
    }
    
   
}



// 提交请求
- (void)UpLoad{
    if(_isSend){
        return;
    }
    
    _isSend = YES;
    __weak ZCUILeaveMessageController *leaveVC = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:zcLibConvertToString(_megTextView.text) forKey:@"ticketContent"];
    
//    ZCLibConfig *libConfig = [ZCIMChat getZCIMChat].libConfig;
//    if(libConfig.ticketStartWay == 1 || libConfig.emailFlag){
        [dic setValue:zcLibConvertToString(_emailTf.text) forKey:@"customerEmail"];
        
//    }
//    if (libConfig.ticketStartWay == 2 || libConfig.telFlag) {
      [dic setValue:zcLibConvertToString(_phoneTf.text) forKey:@"customerPhone"];
//    }
    if ([ZCUIConfigManager getInstance].kitInfo.isShowNickName) {
       [dic setValue:_nickNameTf.text forKey:@"customerNick"];
    }
    if(imageURLArr.count>0){
        NSString *fileStr = @"";
        for (NSString *imagePath in imageURLArr) {
            fileStr = [fileStr stringByAppendingFormat:@"%@;",imagePath];
        }
        fileStr = [fileStr substringToIndex:fileStr.length-1];
        [dic setObject:zcLibConvertToString(fileStr) forKey:@"fileStr"];
    }
    
    
    [[[ZCUIConfigManager getInstance] getZCAPIServer] sendLeaveMessage:dic config:[self getCurConfig] success:^(ZCNetWorkCode code,int status ,NSString *msg) {
        
        // 手机号格式错误
        if (status ==0) {
            if(self.navigationController){
                [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:self.view position:ZCToastPositionCenter];
            }else{
                
                [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:self.presentingViewController.view position:ZCToastPositionCenter];
            }
            leaveVC.isSend = NO;
        }else{
            // 提交成功之后，是否直接退出
           
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"留言成功，我们将尽快联系您") duration:1.0f view:self.view position:ZCToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 退出
                [self goBack:leaveVC.exitType];
            });

        }
        
//        isSend = NO;
    } failed:^(NSString *errorMessage, ZCNetWorkCode erroCode) {
        leaveVC.isSend = NO;
        [[ZCUIToastTools shareToast]showToast:errorMessage duration:1.0f view:leaveVC.view position:ZCToastPositionCenter];
    }];
    
  
}

#pragma mark -- 布局子视图
- (void)customLayoutSubviewsWith:(ZCKitInfo *)zcKitInfo{
    // UIscrollView
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = NO;
    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = NavBarHeight;
    CGFloat scrollViewW = ScreenWidth;
    CGFloat scrollViewH = self.view.frame.size.height - NavBarHeight;
    _scrollView.frame = CGRectMake(scrollViewX, scrollViewY, scrollViewW, scrollViewH);
    scFrame = _scrollView.frame;
    _scrollView.alwaysBounceVertical = YES;
    
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    
    //image
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth/2-210/2, 5, 210, 75)];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.image = [ZCUITools zcuiGetBundleImage:@"ZCicon_letter_msg"];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [_scrollView addSubview:_imageView];
   
    
    CGFloat textBgX = 15;
    CGFloat textBgY = CGRectGetMaxY(_imageView.frame)  + 12 ;
    CGFloat textBgW = ScreenWidth-30;
    CGFloat textBgH = 0;
    
    // _describe
    _describeLabel = [ZCMLEmojiLabel new];
    CGFloat describLabelX = textBgX;
//    CGFloat describLabelH = 0;
    _describeLabel.textColor = UIColorFromRGB(0X939799);
    _describeLabel.font = [UIFont systemFontOfSize:15];
    _describeLabel.textAlignment = NSTextAlignmentCenter;
    _describeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _describeLabel.numberOfLines = 0;
    [_describeLabel setBackgroundColor:[UIColor clearColor]];

    _describeLabel.isNeedAtAndPoundSign = NO;
    _describeLabel.disableEmoji = NO;
    
    _describeLabel.lineSpacing = 3.0f;
    [_describeLabel setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
    
    _describeLabel.delegate = self;
    [_scrollView addSubview:_describeLabel];
    
    NSString *text =[self getCurConfig].msgTxt;
    text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
    text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    while ([text hasPrefix:@"\n"]) {
        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
    }
    
    NSMutableDictionary *dict = [_describeLabel getTextADict:text];
    if(dict){
        text = dict[@"text"];
    }
    
    
    if(dict){
        NSArray *arr = dict[@"arr"];
        //    [_emojiLabel setText:tempText];
        for (NSDictionary *item in arr) {
            NSString *text = item[@"htmlText"];
            int loc = [item[@"realFromIndex"] intValue];
            
            // 一定要在设置text文本之后设置
            [_describeLabel addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
        }
    }
    [_describeLabel setText:text];
    CGSize size = [_describeLabel preferredSizeWithMaxWidth:textBgW];
    _describeLabel.frame = CGRectMake(describLabelX, textBgY, textBgW, size.height);
    
    
    
    UIView *msgView = [[UIView alloc] init];
    msgView.backgroundColor = [UIColor whiteColor];
    msgView.layer.borderWidth = 0.5f;
    if (iOS7) {
        msgView.layer.borderWidth = 0.75f;
    }
    msgView.layer.borderColor = UIColorFromRGB(0Xd2d5d6).CGColor;
    [_scrollView addSubview:msgView];
    
    textBgY = CGRectGetMaxY(_describeLabel.frame) + 15;
    // 留言栏的背景view
    CGFloat mvH = 140;
    
    // _megTextView
    _megTextView = [[ZCUIPlaceHolderTextView alloc]init];
    _megTextView.backgroundColor = [UIColor clearColor];
    _megTextView.font = [UIFont systemFontOfSize:15];
    _megTextView.textAlignment = NSTextAlignmentLeft;
    //    _megTextView.textColor = UIColorFromRGB(0X808686);
    
    _megTextView.frame = CGRectMake(15, 0, textBgW, mvH);
//    _megTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _megTextView.delegate = self;
    _megTextView.placeholederFont = [UIFont systemFontOfSize:16];
    _megTextView.placeholder =[self getCurConfig].msgTmp;
    _megTextView.placeholderColor  = UIColorFromRGB(0Xbfc6c7);
    if (_megTextView.placeHolderLabel.frame.size.height > mvH) {
        _megTextView.frame = CGRectMake(15, 0, textBgW, _megTextView.placeHolderLabel.frame.size.height);
    }
    // 调整行间距
    _megTextView.LineSpacing = 10;
    // 将换行更换成完成
    _megTextView.returnKeyType = UIReturnKeyDone;
    [msgView addSubview:_megTextView];
    
    //    留言相关 1显示 0不显示
    //    telShowFlag 电话是否显示
    //    telFlag 电话是否必填
    //    enclosureShowFlag 附件是否显示
    //    enclosureFlag 附件是否必填
    //    emailFlag 邮箱是否必填
    //    emailShowFlag 邮箱是否显示
    //    ticketStartWay 工单发起方式 1邮箱，2手机
    ZCLibConfig *libConfig = [self getCurConfig];
    if(libConfig.enclosureShowFlag){
        // 添加照片
        CGFloat photoW = (textBgW - 40)/5;
        _photoView = [[UIView alloc] initWithFrame:CGRectMake(15, mvH + 30 , textBgW, photoW)];
        [_photoView setBackgroundColor:[UIColor clearColor]];
        [msgView addSubview:_photoView];
        
        imageArr = [[NSMutableArray alloc] init];
        imageURLArr = [[NSMutableArray alloc] init];
        [self createImgButton:1];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, mvH + photoW + 45, textBgW, 21)];
        if(!libConfig.enclosureFlag){
            [label setText:ZCSTLocalString(@"上传问题图片能大大提高解决问题效率(选填)")];
        }else{
            [label setText:ZCSTLocalString(@"上传问题图片能大大提高解决问题效率(必填)")];
        }
        [label setTextColor:UIColorFromRGB(TextLeavePhotoColor)];
        [label setFont:ListTitleFont];
        [label setBackgroundColor:[UIColor clearColor]];
        [msgView addSubview:label];
        
    
        UIView *photoLine = [[UIView alloc]initWithFrame:CGRectMake(15, mvH + 15, textBgW, 0.75)];
        photoLine.backgroundColor = UIColorFromRGB(0Xd2d5d6);
        [msgView addSubview:photoLine];
        
        mvH = mvH + photoW + 60 + 21;
    }

    
    [msgView setFrame:CGRectMake(0, textBgY, ScreenWidth, mvH)];
    textBgY =CGRectGetMaxY(msgView.frame);
    
    
    
    CGFloat textY = 0;
    
        // 邮箱的背景view
    UIView *textByView = [[UIView alloc] init];
    textByView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:textByView];
    
    
    //昵称
    if (zcKitInfo.isShowNickName) {
        _nickNameTf = [[UITextField alloc] initWithFrame:CGRectMake(15, textY, textBgW, 44)];
        _nickNameTf.delegate = self;
        _nickNameTf.backgroundColor = [UIColor clearColor];
        _nickNameTf.placeholder = ZCSTLocalString(@"请输入昵称（选填）");
        if (zcKitInfo.isAddNickName) {
            _nickNameTf.placeholder = ZCSTLocalString(@"请输入昵称（必填）");
        }
        
        
        if (![@"" isEqual: zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.nickName)]) {
            _nickNameTf.text = [ZCLibClient getZCLibClient].libInitInfo.nickName;
        }
        _nickNameTf.textAlignment = NSTextAlignmentLeft;
        _nickNameTf.font = [UIFont systemFontOfSize:15];
        _nickNameTf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _nickNameTf.tag = 4002;
        [_nickNameTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _nickNameTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textByView addSubview:_nickNameTf];
        
        
        textY  =  textY + 44;
        textBgH = textBgH + 44;
    }
    
    if(libConfig.ticketStartWay==1 || libConfig.emailShowFlag){
        // _emailTf
        _emailTf = [[UITextField alloc]init];
        _emailTf.delegate = self;
        _emailTf.backgroundColor = [UIColor clearColor];
        if(libConfig.ticketStartWay == 1 || libConfig.emailFlag){
            _emailTf.placeholder = ZCSTLocalString(@"请输入邮箱地址（必填）");
        }else{
            _emailTf.placeholder = ZCSTLocalString(@"请输入邮箱地址（选填）");
        }
        _emailTf.textAlignment = NSTextAlignmentLeft;
        _emailTf.font = [UIFont systemFontOfSize:15];
        _emailTf.keyboardType = UIKeyboardTypeEmailAddress;
        
        
        _emailTf.frame = CGRectMake(15, textY, textBgW, 44);
        _emailTf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _emailTf.tag = 4001;
        [_emailTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _emailTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textByView addSubview:_emailTf];
        
        
        if(textY>0){
            UIView *nickline = [[UIView alloc]initWithFrame:CGRectMake(15, textY, textBgW, 0.75)];
            nickline.backgroundColor = UIColorFromRGB(0Xd2d5d6);
            [textByView addSubview:nickline];
        }
        textBgH = textBgH + 44;
        textY  =  textY + 44;
    }
    
    
    
    
    if(libConfig.ticketStartWay==2 || libConfig.telShowFlag){
        
        
        // 电话号
        _phoneTf = [[UITextField alloc] initWithFrame:CGRectMake(15, textY, textBgW, 44)];
        _phoneTf.delegate = self;
        _phoneTf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _phoneTf.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTf.placeholder = ZCSTLocalString(@"请输入手机号码（选填）");
        if (libConfig.ticketStartWay == 2 || libConfig.telFlag) {
            _phoneTf.placeholder = ZCSTLocalString(@"请输入手机号码（必填）");
        }
        if (![@"" isEqual: zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.phone)]) {
            _phoneTf.text = [ZCLibClient getZCLibClient].libInitInfo.phone;
        }
        
        _phoneTf.backgroundColor = [UIColor clearColor];
        _phoneTf.textAlignment = NSTextAlignmentLeft;
        _phoneTf.font = [UIFont systemFontOfSize:15];
        _phoneTf.tag = 4003;
        [_phoneTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _phoneTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textByView addSubview:_phoneTf];
        
        
        textBgH = textBgH + 44;
        
        if(textY > 0){
            UIView *phoneline = [[UIView alloc]initWithFrame:CGRectMake(15, textY, textBgW, 0.75)];
            phoneline.backgroundColor = UIColorFromRGB(0Xd2d5d6);
            [textByView addSubview:phoneline];
        }
    }
    textBgY = textBgY + 15;
    textByView.frame = CGRectMake(0, textBgY, ScreenWidth, textBgH);
    
    textBgY = textBgY + textBgH;
    
    // 边框图层
    textByView.layer.masksToBounds = YES;
    textByView.layer.borderColor = UIColorFromRGB(0Xd2d5d6).CGColor;
    textByView.layer.borderWidth = 0.5f;
    if (iOS7) {
        textByView.layer.borderWidth = 0.75f;
    }
    
    
    // 是否显示提交按钮
    if ([_megTextView.text isEqualToString:@""] ||
       (((libConfig.ticketStartWay==1 || libConfig.emailFlag) ) && [_emailTf.text isEqualToString:@""]) ||
       (zcKitInfo.isShowNickName && zcKitInfo.isAddNickName && [_nickNameTf.text isEqualToString:@""] ) ||
        ((libConfig.ticketStartWay==2 || libConfig.telFlag)  && [_phoneTf.text isEqualToString:@""])) {
        self.moreButton.userInteractionEnabled = NO;
    }    
    
    
    
    // 重新计算后的高度（最终的高度）
    if (textBgY > _scrollView.frame.size.height) {

        _scrollView.contentSize = CGSizeMake(0, textBgY +20 + 216);
    }else{
        _scrollView.contentSize = CGSizeMake(0, _scrollView.frame.size.height + mvH +216);
    }
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
}


-(UIButton *)createImgButton:(int) tag{
    CGFloat photoW = (ScreenWidth - 30 - 40)/5;
    CGFloat buttonX = (tag - 1)*10 + (tag - 1)* photoW;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    button.tag = tag;
    [button setFrame:CGRectMake(buttonX, 0, photoW, photoW)];
    
    if(tag == imageArr.count + 1){
        [button setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_add_photo"] forState:UIControlStateNormal];
        [button setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_add_photo"] forState:UIControlStateHighlighted];
    }else{
        [button setImage:[UIImage imageWithContentsOfFile:[imageArr objectAtIndex:tag-1]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageWithContentsOfFile:[imageArr objectAtIndex:tag-1]] forState:UIControlStateHighlighted];
    }
    [button addTarget:self action:@selector(addOrViewLeavePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [_photoView addSubview:button];
    
    // 边框图层
//    button.layer.masksToBounds = YES;
//    button.layer.cornerRadius = 3.0f;
//    button.layer.borderColor = UIColorFromRGB(0Xd2d5d6).CGColor;
//    button.layer.borderWidth = 0.5f;
//    if (iOS7) {
//        button.layer.borderWidth = 0.75f;
//    }
    
    
    return button;
}



-(void)addOrViewLeavePhoto:(UIButton *) button{
    int tag = (int)button.tag;
    if(tag == imageArr.count + 1){
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"拍照"),ZCSTLocalString(@"从相册选择"), nil];
        [mysheet show];
        
        curCheckButton = button;
    }
    else{
        // 浏览图片
        ZCXJAlbumController *albumVC = [[ZCXJAlbumController alloc] initWithImgULocationArr:imageArr CurPage:tag-1];
        albumVC.myDelegate = self;
        [self.navigationController pushViewController:albumVC animated:YES];
    }
    
}


- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        // 保存图片到相册
        [self getPhotoByType:1];
    }
    if(buttonIndex == 1){
        [self getPhotoByType:2];
    }
}

#pragma mark --- 图片浏览代理
-(void)getCurPage:(NSInteger)curPage{
    
}
-(void)delCurPage:(NSInteger)curPage{
    [imageArr removeObjectAtIndex:curPage];
    [imageURLArr removeObjectAtIndex:curPage];
    for (int i=(int)curPage;i<=imageArr.count;i ++) {
        UIButton *button = [_photoView viewWithTag:i+1];
        if(i == imageArr.count){
            [button setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_add_photo"] forState:UIControlStateNormal];
            [button setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_add_photo"] forState:UIControlStateHighlighted];
        }else{
            [button setImage:[UIImage imageWithContentsOfFile:[imageArr objectAtIndex:i]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageWithContentsOfFile:[imageArr objectAtIndex:i]] forState:UIControlStateHighlighted];
        }
    }
    [[_photoView viewWithTag:imageArr.count+2] removeFromSuperview];
    [self checkCommitStatus];
}



#pragma mark --- textView 监听
- (void)textViewDidChange:(UITextView *)textView{
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    [self textChange:textView];
    
}


#pragma mark -- 判断提交按钮是否可以点击
- (void)textChange:(UITextView *)textView{
   [self checkCommitStatus];
}


-(void) checkCommitStatus{
    ZCKitInfo *zcKitInfo = [ZCUIConfigManager getInstance].kitInfo;
    ZCLibConfig *libConfig = [self getCurConfig];
    
    if ((_emailTf!=nil && (libConfig.ticketStartWay == 1 || libConfig.emailFlag) && [_emailTf.text isEqualToString:@""]) ||
        [zcLibTrimString(_megTextView.text) isEqualToString:@""] ||
        (zcKitInfo.isShowNickName && zcKitInfo.isAddNickName  && [_nickNameTf.text isEqualToString:@""]) ||
        (_phoneTf!=nil && (libConfig.ticketStartWay == 2 || libConfig.telFlag) && [_phoneTf.text isEqualToString:@""])
        || (libConfig.enclosureShowFlag && libConfig.enclosureFlag && imageURLArr.count == 0)) {
        self.moreButton.alpha = 0.4;
        [self.moreButton setUserInteractionEnabled:NO];
    }else{
        self.moreButton.alpha = 1;
        [self.moreButton setUserInteractionEnabled:YES];
    }
}

#pragma mark  -- 键盘处理事件


// textfield的键盘回收delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
 
    [self downKeyBoard:textField];
    return YES;
}
#pragma mark -- 键盘监听

-(void)textFieldDidChange:(UITextField *)textField{
    
    NSString *text = textField.text;
    // 昵称的输入要过滤表情
    if (textField.tag == 4002) {
        // 过滤Emoji表情
        __weak ZCUILeaveMessageController *saveSelf = self;
        [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            if(substring.length==2){
              saveSelf.nickNameTf.text  = [saveSelf.nickNameTf.text stringByReplacingOccurrencesOfString:substring withString:@""];
            }else{
                // 特殊Emoji，如搜狗输入法中的
                const unichar hs = [substring characterAtIndex:0];
                BOOL returnValue=NO;
                // non surrogate
                if (0x2100 <= hs && hs <= 0x27ff) {
                    returnValue = YES;
                } else if (0x2B05 <= hs && hs <= 0x2b07) {
                    returnValue = YES;
                } else if (0x2934 <= hs && hs <= 0x2935) {
                    returnValue = YES;
                } else if (0x3297 <= hs && hs <= 0x3299) {
                    returnValue = YES;
                } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                    returnValue = YES;
                }
                
                if(returnValue){
                    saveSelf.nickNameTf.text=[saveSelf.nickNameTf.text stringByReplacingOccurrencesOfString:substring withString:@""];
                }
            }
        }];

    }
    
    
    [self textChange:_megTextView];
    
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    // 限制输入字数
    NSString * tobeString = [textView.text stringByReplacingCharactersInRange:range withString:text];// 截取字符串
        if (tobeString.length > 200 && range.length!=199){// 最多输入两位数
            textView.text = [tobeString substringToIndex:199];
            
            if(self.navigationController){
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"文本超过最大限制，不能超过200个字符") duration:1.0f view:self.view position:ZCToastPositionCenter];
            }else{
                
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"文本超过最大限制，不能超过200个字符") duration:1.0f view:self.presentingViewController.view position:ZCToastPositionCenter];
            }

            return NO;
        }
    if ([text isEqualToString:@"\n"]) {
        [self downKeyBoard:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark -- 获取焦点
- (void)textViewDidBeginEditing:(UITextView *)textView{
//    _type = @"1";
    [_emailTf resignFirstResponder];
    [_phoneTf resignFirstResponder];
    [_nickNameTf resignFirstResponder];
    
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    if (ScreenHeight == 480 && ScreenWidth == 320) {
//        _scrollView.contentOffset = CGPointMake(0, _megTextView.frame.origin.y - _emailTf.frame.size.height - 40 );
//    }
//}


#pragma mark -- 邮箱格式
// 正则表达式判断
- (BOOL)match:(NSString *) email{
    // 1.创建正则表达式
    NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";// 判断输入的数字是否是1~99
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    // 2.测试字符串
    NSArray *results = [regex matchesInString:email options:0 range:NSMakeRange(0, email.length)];
    return results.count > 0;
}

// 关闭页面
-(void)goBack:(ExitType) isClose{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(iOS7){
        if(self.navigationController!=nil){
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
            self.navigationController.delegate = nil;
        }
    }
    if (isClose == ISCOLSE || isClose == ISBACKANDUPDATE) {
        [self isClose];
    }else{
        // 直接返回到上一级页面
        [self noIsClose : isClose];
    }
}

#pragma mark -- 返回到上一VC
- (void)backAction{
    if (_exitType == ISCOLSE) {
        [self isClose];
    }else{
        [self noIsClose:ISNOCOLSE];
    }

    [self downKeyBoard:nil];
}

// 是否直接退出SDK
- (void)isClose{
    if (self.navigationController) {
        if(iOS7){
            // 设置页面不能使用边缘手势关闭
            if(self.navigationController!=nil){
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
                self.navigationController.interactivePopGestureRecognizer.delegate = nil;
                self.navigationController.delegate = nil;
            }
        }
        // 用户接入VC -》chatVC -》留言VC
        if(self.navigationController.viewControllers.count>=3){
        
            [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count -3] animated:YES];
        }else{
            [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
        }
    
        CloseBlock();
        
    }else{
        [self dismissViewControllerAnimated:NO completion:^{
            CloseBlock();
        }];
    }
    
}

-(void)setCloseBlock:(void (^)())closeBlock{
    CloseBlock = closeBlock;
}


// 不直接退出
- (void)noIsClose:(ExitType) isExitType{
    
    switch (isExitType) {
        case 1:
            [self isClose];
            break;
        case 2:
            [self popSkillView];
            break;
        case 3:
            [self isClose];
            break;
        case 4:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"closeSkillView" object:nil];
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(popSkillView) userInfo:nil repeats:NO];
            
            break;
        case 5:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"gotoRobotChatAndLeavemeg" object:nil];
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(popSkillView) userInfo:nil repeats:NO];
            break;
        default:
            break;
    }
    
}

- (void)popSkillView{
    
    if(self.navigationController != nil ){
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}





#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    
    
    //    NSLog(@"url:%@  url.absoluteString:%@",url,url.absoluteString);
    [self doClickURL:url.absoluteString text:@""];
}


// 链接点击
-(void)ZCMLEmojiLabel:(ZCMLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(ZCMLEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}


// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        if(LinkedClickBlock){
            LinkedClickBlock(url);
        }else{
            if([url hasPrefix:@"tel:"] || zcLibValidateMobile(url)){
                callURL=url;
                
                //初始化AlertView
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[url stringByReplacingOccurrencesOfString:@"tel:" withString:@""]
                                                               delegate:self
                                                      cancelButtonTitle:ZCSTLocalString(@"取消")
                                                      otherButtonTitles:ZCSTLocalString(@"呼叫"),nil];
                alert.tag=1;
                [alert show];
            }else if([url hasPrefix:@"mailto:"] || zcLibValidateEmail(url)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
         
            else{
                if (![url hasPrefix:@"https"] && ![url hasPrefix:@"http"]) {
                    url = [@"http://" stringByAppendingString:url];
                }
                ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:zcUrlEncodedString(url)];
                if(self.navigationController != nil ){
                    [self.navigationController pushViewController:webPage animated:YES];
                }else{
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                    nav.navigationBarHidden=YES;
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
            }
        }
    }
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1){
        if(buttonIndex==1){
            // 打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
        }
    } else if(alertView.tag==2){
        if(buttonIndex == 1){
            
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeReSend obj:nil];
//                //                [_delegate itemOnClick:_tempModel clickType:SobotCellClickReSend];
//            }
        }
    }else if(alertView.tag==3){
        if(buttonIndex==1){
            // 打电话
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
            [self openQQ:callURL];
            callURL=@"";
        }
    }
}

-(BOOL)openQQ:(NSString *)qq{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",qq]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://wpa.qq.com/msgrd?v=3&uin=%@&site=qq&menu=yes",qq]]];
        return YES;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self downKeyBoard:nil];
}


#pragma mark - gesture delegate




#pragma mark 发送图片相关
/**
 *  根据类型获取图片
 *
 *  @param buttonIndex 2，来源照相机，1来源相册
 */
-(void)getPhotoByType:(NSInteger) buttonIndex{
    _zc_imagepicker = nil;
    _zc_imagepicker = [[UIImagePickerController alloc]init];
    _zc_imagepicker.delegate = self;
    [ZCSobotCore getPhotoByType:buttonIndex byUIImagePickerController:_zc_imagepicker Delegate:self];
}
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_zc_imagepicker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    __weak  ZCUILeaveMessageController *_myselft  = self;
 
    [ZCSobotCore  imagePickerController:_zc_imagepicker didFinishPickingMediaWithInfo:info WithView:self.view Delegate:self block:^(NSString *filePath, ZCMessageType type, NSString *duration) {
        [[[ZCUIConfigManager getInstance] getZCAPIServer] fileUploadForLeave:filePath commanyId:[self getCurConfig].companyID start:^{
            [[ZCUIToastTools shareToast] showProgress:@"上传中..." with:_myselft.view];
        } success:^(NSString *fileURL, ZCNetWorkCode code) {
            [imageArr addObject:filePath];
            [imageURLArr addObject:fileURL];
            [curCheckButton setImage:[UIImage imageWithContentsOfFile:[imageArr objectAtIndex:curCheckButton.tag-1]] forState:UIControlStateNormal];
            [curCheckButton setImage:[UIImage imageWithContentsOfFile:[imageArr objectAtIndex:curCheckButton.tag-1]] forState:UIControlStateHighlighted];
            
            if(imageArr.count < 5){
                [_myselft createImgButton:((int)curCheckButton.tag + 1)];
            }
            
            [[ZCUIToastTools shareToast] dismisProgress];
            // 图片上传成功后刷新一下提交按钮
            [self checkCommitStatus];
        } fail:^(ZCNetWorkCode errorCode) {
            [[ZCUIToastTools shareToast] showToast:@"网络错误" duration:2.0f view:_myselft.view position:ZCToastPositionCenter];
        }];
    }];
}



- (void)dealloc{
//    NSLog(@" go to dealloc");
    // 移除键盘的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
