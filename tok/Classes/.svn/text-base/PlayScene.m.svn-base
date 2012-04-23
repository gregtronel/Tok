//
//  KeyboardScene.m
//  echobo
//
//  Created by Sang Won Lee on 10/5/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "PlayScene.h"


@implementation PlayScene

-(id) init{
	self = [super init];
	if(self){
		[self addLayer];
	}
	return self;
}

-(void) addLayer{
	GridLayer *gridLayer = [GridLayer node];
	CCLayerColor *bgLayer = [CCLayerColor node];
	ClockLayer * cueLayer = [ClockLayer node];
	
	[gridLayer initMenu];
	[bgLayer initWithColor:ccc4(255,255,255,255)];

	[self addChild:bgLayer	z:-1];
	[self addChild:gridLayer z:0];
	[self addChild:cueLayer z:1];
}


@end
