//
//  TokClock.h
//  echobo
//
//  Created by Ajay Srinivasamurthy on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"
#import	"Constants.h"
#import "Grid.h"


//#import "HelloWorldLayer.h"


@interface TokClock : NSObject {
	
	NSDate * initDate;
	int bpm;
	int tickCount;
	NSTimer *tokTimer;
	int numTicksSoFar;
	NSTimeInterval nextTickTime;
	NSTimeInterval TickStartTime;
	BOOL flagOn;
	double t_offset;
	double tickInterval;
	float testTimerCount;
	int PosOnScore;
	int tt1;
	NSDateFormatter * dateFormat;
	NSDate * Tnext;
	NSTimeInterval oneMeasureLen;;
	NSTimeInterval MetroStartMaster;
	int NumMeasures;
	NSTimeInterval TimeStamp1;
	NSTimeInterval TimeStamp2;
	NSTimeInterval latency;
	NSMutableArray * SyncTimeStart;
	NSMutableArray * SyncTimeEnd;
	int SyncCount;
	// Accuracy variables
	NSTimeInterval tapTime;
	NSString *tapMessage;
	float rhythmicAccuracy;
	int MetroEnable[NUMBER_OF_BEATS_PER_MEASURE*2];
	float alpha1;
	float alpha2;
	int RewardMeasureCount;
}

@property int bpm;
@property int tickCount;
@property int numTicksSoFar;
@property NSTimeInterval nextTickTime;
@property NSTimeInterval TickStartTime;
@property BOOL flagOn;
@property double t_offset;
@property double tickInterval;
@property float testTimerCount;
@property int PosOnScore;
@property int tt1;

@property (retain, nonatomic) NSDate * initDate;
@property (retain, nonatomic) NSDateFormatter * dateFormat;
@property (retain, nonatomic) NSDate * Tnext;
@property (retain, nonatomic) NSMutableArray * SyncTimeStart;
@property (retain, nonatomic) NSMutableArray * SyncTimeEnd;
@property NSTimeInterval oneMeasureLen;
@property NSTimeInterval MetroStartMaster;
@property int NumMeasures;
@property NSTimeInterval TimeStamp1;
@property NSTimeInterval TimeStamp2;
@property NSTimeInterval latency;
@property int SyncCount;
@property NSTimeInterval tapTime;

@property (retain, nonatomic) NSString *tapMessage;

@property float rhythmicAccuracy;
@property float alpha1;
@property float alpha2;
@property int RewardMeasureCount;

+(TokClock *) sharedClock;
-(void) startMetronomeAfter: (double) watingTime;
-(void) resetClockWithNow;
-(void) computeAccuracy;
-(void) MetroEnablePositions: (int) option;
-(void) CheckRewardStatus;
-(void) stopTimer;
-(void) resumeTimer;



@end