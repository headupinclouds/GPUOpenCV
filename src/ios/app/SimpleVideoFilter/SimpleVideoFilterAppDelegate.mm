#import "SimpleVideoFilterAppDelegate.h"
#import "SimpleVideoFilterViewController.h"

@implementation SimpleVideoFilterAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    //[_window release]; /* DJH */
    //[super dealloc];   /* DJH */
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease]; /* DJH */
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    rootViewController = [[SimpleVideoFilterViewController alloc] initWithNibName:@"SimpleVideoFilterViewController" bundle:nil];
    
    // FORCE LINKER TO LINK GPUImageView
    // http://stackoverflow.com/questions/1725881/unknown-class-myclass-in-interface-builder-file-error-at-runtime
    //
    // Despite the "Unknown class MyClass in Interface Builder file." error printed at runtime,
    // this issue has nothing to do with Interface Builder, but rather with the linker, which is
    // not linking a class because no code uses it directly.
    //
    // Apparently this will work, if I can find the cmake flags for it:
    // 
    // -all_load -ObjC flags to the Other Linker Flags
    
    GPUImageView * filterView = [[GPUImageView alloc] init];
    
    rootViewController.view.frame = [[UIScreen mainScreen] bounds];
    [self.window addSubview:rootViewController.view];

    [self.window makeKeyAndVisible];
    [self.window layoutSubviews];
    self.window.rootViewController = rootViewController;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
