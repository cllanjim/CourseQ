//
//  WebSchoolLoginViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-24.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "WebSchoolLoginViewController.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "DataParser.h"

#define USER_ID @"MemberID"
#define USER_ISSAVED @"UerInfoSaved"
#define USER_NICKNAME @"UserNickname"
#define USER_FULLNAME @"UserFullname"
#define USER_PASSWORD @"UserPassword"
#define USER_PORTRAIT @"UserPortrait"


static NSString *_WebAdressOfFreeboxWS_LOGIN_2_0 = @"http://kechengpai.com/php/call_ajax.php?LOGIN=";//网校
static NSString *_WebAdressOfFreeboxWS_PROFILE_2_0 = @"http://kechengpai.com/php/call_ajax.php?PROFILE";
static NSString *_WebAdressOfFreeboxWS_WeiboLoginOK_2_0 = @"http://test.kechengpai.com/php/weibo_login.php";//uid

@interface WebSchoolLoginViewController () <ASIHTTPRequestDelegate>
@property (retain, nonatomic) IBOutlet UITextField *userNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UIButton *rightBarBtn;
@end

@implementation WebSchoolLoginViewController

- (IBAction)userNameInputDone:(id)sender {
    // to dismiss keyboard
}

- (IBAction)passwordInputDone:(id)sender {
    // to dismiss keyboard
}

- (IBAction)leftBarBtnPressed:(id)sender {
    //back to LoginViewController
    [self.delegate didCancelLogin];
}

- (IBAction)rightBarBtnPressed:(id)sender {
    //login
    
    if ([self.userNameTextField.text length] == 0 ||
        [self.passwordTextField.text length] == 0)
    {
        //show hud = 请输入正确的信息
    }
    
    else
    {
        [self.rightBarBtn setEnabled:NO];
        
        //show hud = loading...
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        NSString *userInput = [NSString stringWithFormat:@"%@@-%@",
                               self.userNameTextField.text,
                               self.passwordTextField.text];
        NSString *loginResult = [NSString stringWithFormat:@"%@%@",
                                 _WebAdressOfFreeboxWS_LOGIN_2_0, userInput];
        NSURL *url = [NSURL URLWithString:loginResult];
        
        ASIHTTPRequest *request = [[ASIHTTPRequest requestWithURL:url] retain];
        [request setDelegate:self];
        [request setTag:10];
        [request startAsynchronous];
    }
}

#pragma mark - login

- (void)loginSuccess {
    
    NSLog(@"login success");
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //request to get user info from server
    //save info to NSUserDefault
    
    NSURL *url = [NSURL URLWithString:_WebAdressOfFreeboxWS_PROFILE_2_0];
    ASIHTTPRequest *request = [[ASIHTTPRequest requestWithURL:url] retain];
    [request startSynchronous];
    
    NSArray *userInfoArr = [[DataParser commonParser:[request responseString]]objectAtIndex:0];
    NSArray *userMemberIDArr = [[DataParser commonParser:[request responseString]]objectAtIndex:2];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:USER_ISSAVED];
    [ud setValue:userMemberIDArr[0] forKey:USER_ID];
    [ud setValue:userInfoArr[0] forKey:USER_FULLNAME];
    [ud setValue:userInfoArr[1] forKey:USER_PORTRAIT];
    [ud setValue:self.userNameTextField.text forKey:USER_NICKNAME];
    [ud setValue:self.passwordTextField.text forKey:USER_PASSWORD];
    [ud synchronize];
    
#warning 需要写到mongo，费老师
    
    //show hud - 登录成功
    
    //[request release];
    
    
    [self.delegate didFinishLogin];
}

- (void)loginFail {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //show hud - 请检查账号密码
    
    NSLog(@"login fail");
    [self.passwordTextField setText:@""];
}

#pragma mark - request delegate

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    if (request.tag == 10) {
        
        
        if ([[request.responseString substringToIndex:5] isEqualToString:@"LOGIN"])
        {
            //hide hud
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if ([DataParser loginApplication:request.responseString]) {
                [self loginSuccess];
            }else {
                [self loginFail];
            }
        }
        
        else
        {
            //show hud - 与服务器连接异常，请确认网络连接后重试
            NSLog(@"与服务器连接异常，请确认网络连接后重试");
        }
        
        //[request release];
        //[self.rightBarBtn setEnabled:YES];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    if (request.tag == 10) {
        
        if (request.error) {
            //show hud - error localizedDescription
        }
        
        //[request release];
        [self.rightBarBtn setEnabled:YES];
    }
}

#pragma mark - VC lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_userNameTextField release];
    [_passwordTextField release];
    [_rightBarBtn release];
    [super dealloc];
}
@end
