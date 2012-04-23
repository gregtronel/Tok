//
//  RadioButton.m
//  tok
//
//  Created by Sang Won Lee on 12/3/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "RadioButton.h"
#import "Constants.h"

@implementation RadioButton
@synthesize userInt;

+ (RadioButton *) radioButtonWithTarget:		(id) 	target
							   selector:		(SEL) 	selector 
							  WithLabel:(NSString *) string{
	
	
	RadioButton *button = [[[RadioButton alloc] initWithTarget:target selector:selector WithLabel:string] autorelease];
	
	return button;
	
	
}


- (id) initWithTarget:		(id) 	target
			 selector:		(SEL) 	selector 
			WithLabel:(NSString *) string{
	
	self = [super initWithTarget:target selector:selector];
	if (self){
		selected = NO;
		notified = NO;
		button = [CCSprite spriteWithFile:@"radioButton30.png"] ;
		label = [CCLabelTTF labelWithString:string fontName:TOK_FONT_1 fontSize:20];
		self.contentSize = CGSizeMake(BUTTON_LABEL_MARGIN + button.contentSize.width + label.contentSize.width, button.contentSize.height);

		[self addChild:button];
		button.position = ccp(button.contentSize.width/2, 0);
		[self addChild:label];
		label.position = ccp(button.contentSize.width+ BUTTON_LABEL_MARGIN + label.contentSize.width/2, 0);
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(unselect:)
		 name:@"radioButtonSelected"
		 object:nil ] ;
	}
	return self;
}

-(void) unselect:(NSNotification *)notification{
	if (!notified)
	{
		selected = YES;
		[self selected];
	}
	notified = NO;
}

-(void) selected{
	if ( selected ) {
		[button initWithFile: @"radioButton30.png"];
		button.position = ccp(button.contentSize.width/2, 0);
	}
	else {
		[button initWithFile: @"radioButtonSelected30.png"];
		button.position = ccp(button.contentSize.width/2, 0);
		notified = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"radioButtonSelected" object: nil userInfo:nil ];
		[super activate];
	}
	selected = !selected;
	[super selected];
}

-(void) activate{
}

@end
