//
//  RadioButton.h
//  tok
//
//  Created by Sang Won Lee on 12/3/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#define BUTTON_LABEL_MARGIN 5
@interface RadioButton : CCMenuItem	{
	CCLabelTTF * label;
	CCSprite * button;
	BOOL notified;
	BOOL selected;
	int userInt;
}

@property int userInt;

+ (RadioButton *) radioButtonWithTarget:		(id) 	target
							   selector:		(SEL) 	selector 
							  WithLabel:(NSString *) string;

@end
