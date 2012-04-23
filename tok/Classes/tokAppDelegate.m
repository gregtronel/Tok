//
//  tokAppDelegate.m
//  tok
//
//  Created by Sang Won Lee on 9/14/11.
//  Copyright Stanford 2011. All rights reserved.
//

#import "cocos2d.h"

#import "tokAppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"
#import "TokClock.h"
#import "TutorialScene.h"

@implementation tokAppDelegate

@synthesize window;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	[application
	 setStatusBarHidden:NO animated:NO];
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	// Run the intro Scene
	CCScene * menuScene = [MenuScene node];
	[menuScene addLayer];
	[director runWithScene: menuScene];
}

- (void)runPlayScene{
	[Environment sharedInstance].state = TOK_PLAY_STATE;
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	[[CCDirector sharedDirector] replaceScene: [PlayScene node]];

}

-(void) runConfScene{
	[[CCDirector sharedDirector] replaceScene: [ConfigurationScene node]];
}

-(void) runTutorialScene{
	
	[[CCDirector sharedDirector]  pushScene: [TutorialScene node]];
	
}

-(void) removeTutorialScene{
	
	[[CCDirector sharedDirector]  popScene];
	
}
- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
#ifdef TOK_DEBUG
	NSLog(@"resign Active");
#endif
	if ([Environment sharedInstance].state == TOK_PLAY_STATE)
		[[TokClock sharedClock] stopTimer];
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
#ifdef TOK_DEBUG
	NSLog(@"become Active");
#endif
	[[CCDirector sharedDirector] resume];
	if ([Environment sharedInstance].state == TOK_PLAY_STATE)
		[[TokClock sharedClock] resumeTimer];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
#ifdef TOK_DEBUG
	NSLog(@"applicationDidEnterBackground ");
#endif
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
#ifdef TOK_DEBUG
	NSLog(@"applicationWillEnterForeground ");
#endif
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
#ifdef TOK_DEBUG
	NSLog(@"applicationWillTerminate ");
#endif
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
