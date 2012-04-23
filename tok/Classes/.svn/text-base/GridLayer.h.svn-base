//
//  HelloWorldLayer.h
//  tok
//
//  Created by Sang Won Lee on 9/14/11.
//  Copyright Stanford 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CCTouchDispatcher.h"
#import "Grid.h"
#import "Accelerometer.h"

@interface GridLayer : CCLayerColor
{

	BOOL destinationSelected;
	Coin * selectedCoin;
	CGPoint guidelineLocation;
	NSMutableSet * coinsInBin;
	CCSprite * bin;
	Accelerometer * accelerometer;
	CCMenu * Coins;
	float guidlineRed;
	float guidlineGreen;
	float guidlineBlue;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
-(void) initMenu;
-(void) tapped:(NSNotification *) notification;
-(void)cleanupTapMsg:(id) sender;
-(void) selectCoin: (Coin  *) coin;
-(void) deselectCoin;
-(void) updateGuidLine:(UITouch *)touch;
- (GridPoint)convertLocationToGrid: (CGPoint) location;
- (CGPoint)convertGridToLocation:(GridPoint) point;
-(void) addNewCoinToGrid:(GridPoint) location Until: (NSDate *) date withColor:(Color) color;
-(void) addRewardCoin:(NSNotification *) notification;
-(void) addGhostCoin:(NSNotification *) notification;
-(Color) convertRewardColor:(int) colorInt;
@end
