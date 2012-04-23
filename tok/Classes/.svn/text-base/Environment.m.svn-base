//
//  Environment.m
//  echobo
//
//  Created by Sang Won Lee on 10/4/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "Environment.h"


@implementation Environment

static Environment * instance = nil;

@synthesize interval;
@synthesize initDate;
@synthesize bpm;
@synthesize myRow;
@synthesize movingDurationInMS;
@synthesize numRow;
@synthesize screenWidth;
@synthesize metronomeOption;
@synthesize state;
@synthesize numCoins;
@synthesize AccuThreshold;
@synthesize ghostEnabled;

+(Environment *)sharedInstance
{
	@synchronized(self) {
		if(!instance) {
			instance = [[Environment alloc] init];
		}
	}
	return instance;
}

-(void) setSharePoints: (float) new_point toRow:(int) rowNumber {
	sharedPoints[rowNumber] = new_point;
}

-(float) getSharePointsOf: (int) rowNumber {
	return sharedPoints[rowNumber];
}

-(BOOL) isTheRowConnected: (int) rowNumber{
	if ( rowNumber >= MAX_NUMBER_OF_ROW || rowNumber < 0) 
		return NO;
	return isConnected[rowNumber];
}

-(void) setConnected: (int) rowNumber With:(BOOL) connectedState{
	isConnected[rowNumber] = connectedState;
}

-(Environment *) init{
	self = [super init];
	
	if ( self ) {
		// init here
		self.interval = 5;
		self.initDate = [NSDate date];
		self.bpm = (TOK_MAXIMUM_TEMPO + TOK_MINIMUM_TEMPO) / 2;
		myRow = 0;
		numRow = 1;
		screenWidth = 480;
		metronomeOption = METRONOME_EVERYBEAT;
		numCoins = NUMBER_OF_INITIAL_COIN;
		AccuThreshold = ACCU_THRESHOLD;
		ghostEnabled = NO;
		for(int i=0;i<MAX_NUMBER_OF_ROW;i++)
		{
			sharedPoints[i] = 0.0; 
		}
    }
	
	return self;
}

-(void) resetClockWithNow{
	self.initDate = [NSDate date];
}

-(BOOL) isThisMyRow:(int) row{
	return (self.myRow == row);
}
@end
