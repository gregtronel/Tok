//
//  HelloWorldLayer.h
//  HelloWorldcocos2D
//
//  Created by Gregoire Tronel on 10/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "TokClock.h"


// HelloWorldLayer
@interface Accelerometer : NSObject <UIAccelerometerDelegate>
{
	float frameRate;
	int numTapped;
	BOOL air;
	float kFilteringFactor;
	
	CCLayer * delegate;

	
	UIAccelerationValue accelX;
	UIAccelerationValue accelY;	
	UIAccelerationValue accelZ;

	UIAccelerationValue rawAccelX;
	UIAccelerationValue rawAccelY;	
	UIAccelerationValue rawAccelZ;
	BOOL calibrated;
}



// returns a CCScene that contains the HelloWorldLayer as the only child
-(void) smoothAccelerometerData;
-(id) initWithDelegate : (CCLayer *) layer;

@end
