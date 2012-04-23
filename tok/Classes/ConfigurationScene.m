//
//  ConfigurationScene.m
//  tok
//
//  Created by Sang Won Lee on 11/29/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "ConfigurationScene.h"
#import "ConfigurationLayer.h"

@implementation ConfigurationScene


-(id) init{
	self = [super init];
	if(self){
		[self addLayer];
	}
	return self;
}


-(void) addLayer{
	ConfigurationLayer * confLayer = [ConfigurationLayer node];
	[self addChild:confLayer];
}
@end
