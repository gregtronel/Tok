//
//  MenyScene.m
//  tok
//
//  Created by Sang Won Lee on 10/21/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "MenuScene.h"


@implementation MenuScene
-(void) addLayer{
	BluetoothLayer * menuLayer = [BluetoothLayer node];
	[menuLayer initMenu];
	[self addChild:menuLayer];
}

@end
