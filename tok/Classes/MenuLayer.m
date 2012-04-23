//
//  MenuLayer.m
//  tok
//
//  Created by Sang Won Lee on 10/21/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "MenuLayer.h"


@implementation MenuLayer
// on "init" you need to initialize your instance
-(void) initMenu
{
	CCLabelTTF * label = [CCLabelTTF labelWithString:@"Start" fontName:@"Marker Felt" fontSize:32];
	CCMenuItemLabel * menuItem = [CCMenuItemLabel itemWithLabel:label 
														 target:self
													   selector:@selector(changeScene:)];
	//menuItem1.userData = [[NSString alloc] initWithString:@"C4.wav"];
	CCMenu * myMenu = [CCMenu menuWithItems:menuItem, nil];
	[myMenu alignItemsHorizontally];
	[self addChild:myMenu];	
	
}

-(void)changeScene: (CCMenuItem *) menuItem{

	tokAppDelegate *appDelegate 
	= (tokAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[appDelegate runPlayScene];
}
@end
