//
//  SecondViewController.m
//  UMSAgentExample
//
//  Created by guowei on 12-10-14.
//
//

#import "ThirdViewController.h"
#import "UMSAgent.h"

@interface ThirdViewController ()<UIWebViewDelegate>
{
    UIWebView *webView;
}

@property (nonatomic,retain) IBOutlet UIWebView *webView;
@end

@implementation ThirdViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [UMSAgent startTracPage:@"第三页"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [UMSAgent endTracPage:@"第三页"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    webView.scalesPageToFit =YES;
    webView.delegate = self;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [webView loadRequest:request];

}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //call native sdk function
    NSString *urlString = [[request URL] absoluteString];
    NSArray *urlComps = [urlString componentsSeparatedByString:@":$"];
    if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"ums"])
        
    {
        NSString *funcStr = [urlComps objectAtIndex:1];
        NSInteger paramsCount = [urlComps count]-2;
        if([funcStr isEqualToString:@"onevent"])
        {
            if(paramsCount >=1)
            {
                NSString * eventIdentifier = [urlComps objectAtIndex:2];
                [UMSAgent postEvent:eventIdentifier];
            }
            else
            {
                NSLog(@"onEvent error param.");
            }
        }
        else if([funcStr isEqualToString:@"oneventacc"])
        {
            if(paramsCount >=2)
            {
                NSString * eventIdentifier = [urlComps objectAtIndex:2];
                NSString * acc = [urlComps objectAtIndex:3];
                [UMSAgent postEvent:eventIdentifier acc:[acc intValue]];
            }
            else
            {
                NSLog(@"oneventacc error param.");
            }
        }
        else if([funcStr isEqualToString:@"oneventjson"])
        {
            if(paramsCount >=2)
            {
                NSString * eventIdentifier = [urlComps objectAtIndex:2];
                NSString * json = [urlComps objectAtIndex:3];
                [UMSAgent postEventJSON:eventIdentifier json:json];
            }
            else
            {
                NSLog(@"oneventjson error param.");
            }
        }
        return NO;
    }
    else
    {
        CFStringRef pageStr = CFURLCreateStringByAddingPercentEscapes(
                                                                        NULL,
                                                                        (CFStringRef)urlString,
                                                                        NULL,
                                                                        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                        kCFStringEncodingUTF8 );
        NSString *pageName =  (NSString *)CFBridgingRelease(pageStr);
        [self performSelector:@selector(tracePage:) withObject:pageName afterDelay:1];
            }
    return YES;
}

-(void)tracePage:(NSString*)pageName
{
    [UMSAgent tracePage:pageName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
