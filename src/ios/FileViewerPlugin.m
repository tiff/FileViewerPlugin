#import "FileViewerPlugin.h"
#import <Cordova/CDV.h>

@implementation FileViewerPlugin
@synthesize previewViewController, activityViewController;

- (void)view:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    BOOL pluginSuccess = NO;
    
    NSDictionary* arguments = [command.arguments objectAtIndex:0];
    NSString* filePath = [arguments objectForKey:@"url"];
    
    self.previewViewController = [[FileViewerPluginViewController alloc] init];
    pluginSuccess = [self.previewViewController viewFile:filePath usingViewController:[super viewController]];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:pluginSuccess];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)hide:(CDVInvokedUrlCommand*)command
{
    [self.previewViewController.documentInteractionController dismissPreviewAnimated:YES];
    [self.previewViewController.documentInteractionController dismissMenuAnimated:YES];
    [self.activityViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)share:(CDVInvokedUrlCommand*)command
{
    BOOL pluginSuccess = NO;
    
    NSDictionary* arguments = [command.arguments objectAtIndex:0];
    NSString* filePath = [arguments objectForKey:@"url"];
    NSString *shareString = @"";
    NSURL *fileUrl = nil;
    
    if (!filePath) {
        NSDictionary* extras = [arguments objectForKey:@"extras"];
        if ([extras objectForKey:@"android.intent.extra.STREAM"]) {
            filePath = [extras objectForKey:@"android.intent.extra.STREAM"];
            if (filePath) {
                fileUrl = [NSURL fileURLWithPath:filePath];
            }
        }
        if ([extras objectForKey:@"android.intent.extra.TEXT"]) {
            shareString = [extras objectForKey:@"android.intent.extra.TEXT"];
        }
    }
    
    if (shareString.length != 0) {
        NSArray *activityItems = [NSArray arrayWithObjects:shareString, fileUrl, nil];
        
        self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        self.activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [[super viewController] presentViewController:self.activityViewController animated:YES completion:nil];
    } else {
        self.previewViewController = [[FileViewerPluginViewController alloc] init];
        pluginSuccess = [self.previewViewController openFile:fileUrl usingViewController:[super viewController]];
    }
}

@end
