//
//  Coin.h
//  tok
//
//  Created by Sang Won Lee on 10/8/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Environment.h"

@interface Coin : CCMenuItemSprite{
	
	CCLayer * delegate;
	BOOL selected;
	BOOL moving;
	BOOL isInBin;
	GridPoint point;
	CCLabelTTF * coinMessage;
	int a;
	BOOL isTapped;
	Color color;
	BOOL isGhost;
	float gScore;		//Ghost Score
}

@property BOOL isInBin;
@property GridPoint point;
@property BOOL moving;
@property BOOL isTapped;
@property Color color;
@property BOOL isGhost;
@property float gScore;
-(id) initWithColor: (Color)color delegate:(CCLayer *)layer;
-(void) moveCoinTo:(CGPoint) location Until: (NSDate *) date destroy:(BOOL) destroy;
- (CGPoint)convertGridToLocation:(GridPoint) point;
-(void) displayMsg : (NSString *) msg fadeOut:(BOOL) option;
-(void) setOpacityBack:(id) sender;
@end
