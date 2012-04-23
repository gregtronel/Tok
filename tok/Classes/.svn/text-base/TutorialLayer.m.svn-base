//
//  TutorialGUI.m
//  tok
//
//  Created by Sang Won Lee on 12/5/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "TutorialLayer.h"
#import "Constants.h"

@implementation TutorialLayer
-(id) init
{
	
	self = [super init];
	if (self){
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite * tutorialImage = [CCSprite spriteWithFile:@"tutorial.png"];
		tutorialImage.position = ccp(size.width/2,size.height/2 - 15);
		[self addChild:tutorialImage];
		
		CCMenuItemLabel * goBackMenuItem = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Go Back" fontName:TOK_FONT_1 fontSize:20]
																   target:self
																 selector:@selector(GoBackToMenuScene:)];
		goBackMenuItem.color = ccc3(0,0,0);

		
		CCMenu * menu = [CCMenu menuWithItems: goBackMenuItem, nil ];
		menu.position = ccp(360,260);
		[self addChild:menu];

	}
	return self;
}

-(void) GoBackToMenuScene: (CCMenuItemLabel *) sender{
#ifdef TOK_DEBUG
	NSLog(@"GoBackToMenuScene"); 
#endif
	id appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate removeTutorialScene];
}
@end
