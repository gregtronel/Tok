//
//  Environment.h
//  echobo
//
//  Created by Sang Won Lee on 10/4/11.
//  Copyright 2011 Stanford. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Environment : NSObject {
	int interval;
	NSDate * initDate;
	int bpm;
	long movingDurationInMS;
	int myRow;
	int numRow;
	float sharedPoints[MAX_NUMBER_OF_ROW];
	BOOL isConnected[MAX_NUMBER_OF_ROW];

	float screenWidth;
	int metronomeOption;
	int state;
	int numCoins;
	float AccuThreshold;
	BOOL ghostEnabled;
}
@property long movingDurationInMS;
@property int interval;
@property int bpm;
@property int myRow;
@property int numRow;
@property float screenWidth;
@property (retain, nonatomic) NSDate * initDate;
@property int metronomeOption;
@property int state;
@property int numCoins;
@property float AccuThreshold;

@property BOOL ghostEnabled;

+(Environment *) sharedInstance;
-(void) resetClockWithNow;
-(BOOL) isThisMyRow:(int) row;
-(void) setSharePoints: (float) new_point toRow:(int) rowNumber;
-(float) getSharePointsOf: (int) rowNumber;
-(BOOL) isTheRowConnected: (int) rowNumber;
-(void) setConnected: (int) rowNumber With:(BOOL) connectedState;

@end
