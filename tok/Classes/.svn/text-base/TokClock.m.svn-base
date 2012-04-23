//
//  TokClock.m
//  echobo
//
//  Created by Ajay Srinivasamurthy on 10/10/11.
//  Copyright 2011 __MyCompanyselfName__. All rights reserved.
//

#import "TokClock.h"
#import "GhostCoin.h"

@implementation TokClock

static TokClock *instance = nil;

@synthesize initDate;
@synthesize bpm;
@synthesize tickCount;	
@synthesize numTicksSoFar;
@synthesize nextTickTime;
@synthesize TickStartTime;
@synthesize flagOn;
@synthesize t_offset;
@synthesize tickInterval;
@synthesize testTimerCount;
@synthesize tt1;
@synthesize PosOnScore;
@synthesize dateFormat;
@synthesize oneMeasureLen;
@synthesize NumMeasures;
@synthesize TimeStamp1;
@synthesize TimeStamp2;
@synthesize MetroStartMaster;
@synthesize latency;
@synthesize SyncTimeStart;
@synthesize SyncTimeEnd;
@synthesize SyncCount;
@synthesize Tnext;
@synthesize RewardMeasureCount;

// Accuracy variables
@synthesize tapTime;
@synthesize tapMessage;
@synthesize rhythmicAccuracy;
@synthesize alpha1;
@synthesize alpha2;

+(TokClock *)sharedClock
{
	@synchronized(self) {
		if(!instance) {
			instance = [[TokClock alloc] init];
		}
	}
	
	return instance;
}

-(TokClock *) init{
	self = [super init];
	
	if ( self ) {
		// init here
		self.bpm = [Environment sharedInstance].bpm;
		self.numTicksSoFar= 0;
		self.t_offset = 0;
		self.flagOn = NO;
		self.dateFormat = [[[NSDateFormatter alloc] init] autorelease];
		[self.dateFormat setDateFormat:@"HH:mm:ss:SSS"];
		self.initDate = [NSDate date];
		self.Tnext = [[[NSDate alloc] init] autorelease];
		self.oneMeasureLen = NUMBER_OF_BEATS_PER_MEASURE*60.0/(float)self.bpm;
		self.MetroStartMaster = [[NSDate date] timeIntervalSince1970];
		self.NumMeasures = 0;
		self.TimeStamp1 = 0;
		self.TimeStamp2 = 0;
		self.latency = 0;
		self.PosOnScore = -2;
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"ticks.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"ting.wav"];
		self.SyncTimeStart = [[NSMutableArray alloc] init];
		self.SyncTimeEnd = [[NSMutableArray alloc] init];
		self.tapTime = 0.0;
		self.tapMessage = [NSString stringWithString:@""];
		self.rhythmicAccuracy = 0;
		self.RewardMeasureCount = 0;
		for(int k=0; k<2*NUMBER_OF_BEATS_PER_MEASURE; k++){
			MetroEnable[k] = 0;
		}
		self.alpha1 = ACCU_ALPHA1;
		self.alpha2 = ACCU_ALPHA2;
    }
	
	return self;
}

-(void) resetClockWithNow{
	self.initDate = [NSDate date];
}

-(void) startMetronomeAfter: (double) waitingTime{
	tickInterval = 60/((float)bpm)/2;
	numTicksSoFar = 0;
	flagOn = NO;
	tt1 = 0;
	[self MetroEnablePositions: [Environment sharedInstance].metronomeOption];
	[self resetClockWithNow];
	tokTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_RESOLUTION target:self selector:@selector(OnTimerTick) userInfo:nil repeats:YES];
	TickStartTime = [[NSDate date] timeIntervalSince1970] + waitingTime;
#ifdef TOK_DEBUG	
	NSLog(@"Current Time %f",[[NSDate date] timeIntervalSince1970]);
	NSLog(@"Tick Start Time %f",TickStartTime);
#endif	
	nextTickTime =  TickStartTime;
	// Start calibration
	[[NSNotificationCenter defaultCenter] postNotificationName:@"start_calibration" object:nil userInfo:nil];
}

-(void) OnTimerTick {
	// main Clock Timer Tick: Audio cue and visual cue
	NSTimeInterval tp = [[NSDate date] timeIntervalSince1970];
	if(tp > CLOCK_DEBOUNCE_START*nextTickTime){		// Metro enabler: using a debouncer
		flagOn = YES;
	}
	
	if ( [Environment sharedInstance].ghostEnabled) [[Grid sharedInstance] checkGridActivity];		//Method to check Coin movement activity and introduce Ghost coins

	if(tp < nextTickTime || !flagOn)
		return;
	

	// proceed the metronome bar
	numTicksSoFar++;
	nextTickTime += tickInterval;
	flagOn = NO;
	int prevPos = PosOnScore;
	PosOnScore++;
	self.NumMeasures+=PosOnScore/(NUMBER_OF_TICK_PER_MEASURE*2);
	PosOnScore %=(NUMBER_OF_TICK_PER_MEASURE*2);
	
	if (PosOnScore == 0 && MetroEnable[PosOnScore]) {
		[[SimpleAudioEngine sharedEngine] playEffect: @"ting.wav"];		
	}
	else if (PosOnScore % 2 == 0 && MetroEnable[PosOnScore]){
		[[SimpleAudioEngine sharedEngine] playEffect: @"ticks.wav"];	
	}
	GridPoint point;
	point.row = [Environment sharedInstance].myRow;
	point.col = prevPos;
	if([[Grid sharedInstance] isCoinArrived:point.row with:point.col]){
		if(![[Grid sharedInstance] getCoinAt: point].isTapped){
			rhythmicAccuracy *= alpha2;
			[[Environment sharedInstance] setSharePoints:rhythmicAccuracy toRow:[Environment sharedInstance].myRow];
			[[DataHandler sharedInstance] broadcastScore: rhythmicAccuracy atRow: [Environment sharedInstance].myRow];
		}
		else {
			[[Grid sharedInstance] getCoinAt: point].isTapped = NO;
		}
	}
	//End of measure check
	if (PosOnScore == NUMBER_OF_TICK_PER_MEASURE*2 - 1) {
		[self CheckRewardStatus];
	}
	
	//CountDown
	if ( PosOnScore < 0 && PosOnScore %2 == 0){
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSString stringWithFormat:@"%d", -PosOnScore/2], @"message", 
							   [NSNumber numberWithFloat:GUI_MESSAGE_DISAPPEAR_TIME], @"duration", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"notifyDisplayed" object: nil userInfo:data ];
	}

}

-(void) CheckRewardStatus{
	int MaxRow = 0;
	float Maxval = 0;
	float pts = 0;
	for(int i = 0;i<MAX_NUMBER_OF_ROW;i++){
		if (![[Environment sharedInstance] isTheRowConnected: i])
			continue;
		pts = [[Environment sharedInstance] getSharePointsOf:i];

		if(pts < [Environment sharedInstance].AccuThreshold)
		{
			self.RewardMeasureCount = 0;
			return;
		}
		
		if(pts>Maxval){
			Maxval = pts;
			MaxRow = i;
		}
	}
	self.RewardMeasureCount++;
	
	if (self.RewardMeasureCount > NUM_MEASURES_REWARD) {
		
		if([Environment sharedInstance].myRow == MaxRow){		//If I have the best accuracy 
			//Add Reward Coin to Bin
#ifdef TOK_DEBUG			
			NSLog(@"REWARD to me");
#endif				
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RewardCoin" object: nil userInfo:nil];
		}
		self.RewardMeasureCount = 0;
#ifdef TOK_DEBUG		
		NSLog(@"REWARD to %d player",MaxRow+1);
#endif	
	}
		
}

-(void) computeAccuracy{
	float GameScore;
	NSTimeInterval actTapTime;
	double diff;
	tapTime = [[NSDate date] timeIntervalSince1970];
	tapMessage = @"MISS";
	BOOL coinPresent = [[Grid sharedInstance] isCoinArrived: [Environment sharedInstance].myRow with: PosOnScore];
#ifdef TOK_DEBUG	
	if(coinPresent)
		NSLog(@"Coin Present");
	else {
		NSLog(@"Coin Absent");
	}
#endif
	if(coinPresent){
		GridPoint point;
		point.row = [Environment sharedInstance].myRow;
		point.col = PosOnScore;
		Coin * coin = [[Grid sharedInstance] getCoinAt : point];
		coin.isTapped = YES;
		[coin displayMsg : @"TOK!" fadeOut:YES];
		actTapTime = TickStartTime + NumMeasures*oneMeasureLen + (PosOnScore+1)*tickInterval;
		diff = fabs(actTapTime - tapTime);
		if (diff < PERFECT*tickInterval) {
			GameScore = PERFECT_SCORE;
			tapMessage = @"PERFECT";
		}
		else if(diff < GOOD*tickInterval){
			GameScore = GOOD_SCORE;
			tapMessage = @"GOOD";
		}
		else if(diff < OKAY*tickInterval){
			GameScore = OKAY_SCORE;
			tapMessage = @"OKAY";
		}
		else {
			GameScore = MISS_SCORE;
			tapMessage = @"MISS";
		}
#ifdef TOK_DEBUG
		NSLog(@"Actual Time of Tap: %f, %f, %f",actTapTime, tapTime, tickInterval);
		NSLog(@"Error: %f",diff);
		NSLog(@"Points: %f",GameScore);
#endif
		// This will penalize the ghost coin and make it disappear
		if ( GameScore >= MOVE_GHOST_THRESHOLD && [[Grid sharedInstance] getCoinAt : point].isGhost){
			float score = coin.gScore;
			if (score < GHOST_SCORE_THRESHOLD){
				[[Grid sharedInstance] remove: coin broadcast:YES toBin:NO];
				[coin removeFromParentAndCleanup:YES];
			}
			else{
				score = score - GHOST_SCORE_DECREASE_FACTOR;
				[coin moveGhostCoin];
				coin.gScore = score;
#ifdef TOK_DEBUG				
				NSLog(@"Ghost Score: %f and opacity: %d",coin.gScore,coin.opacity);
#endif				
			}
		}
	}
	else {
		GameScore = 0;
		tapMessage = @"MISS";
	}
	//Scoring
	rhythmicAccuracy = alpha1*rhythmicAccuracy + (1-alpha1)*GameScore;
	NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:tapMessage, @"message", [NSNumber numberWithFloat:GUI_MESSAGE_DISAPPEAR_TIME], @"duration", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"notifyDisplayed" object: nil userInfo:data ];

	[[Environment sharedInstance] setSharePoints:rhythmicAccuracy toRow:[Environment sharedInstance].myRow];
	[[DataHandler sharedInstance] broadcastScore: rhythmicAccuracy atRow: [Environment sharedInstance].myRow];
}

-(void) MetroEnablePositions: (int) option{
	switch (option) {
		case METRONOME_EVERYBEAT:		//Every beat
			for(int k = 0; k<NUMBER_OF_TICK_PER_MEASURE;k++)
				MetroEnable[2*k] = 1;
			break;
			
		case METRONOME_EVERYTWOBEAT:		//Every Alternate beat
			for(int k = 0; k<NUMBER_OF_TICK_PER_MEASURE/2;k++)
				MetroEnable[4*k] = 1;
			break;
			
		case METRONOME_EVERYFOURBEAT:		// Evey fourth beat
			for(int k = 0; k<NUMBER_OF_TICK_PER_MEASURE/4;k++)
				MetroEnable[8*k] = 1;
			break;
		case METRONOME_NONE:
			break;
		default:		//Every beat
			for(int k = 0; k<NUMBER_OF_TICK_PER_MEASURE;k++)
				MetroEnable[2*k] = 1;
			break;
	}
#ifdef TOK_DEBUG
	NSString * result = @"";
	for(int j=0; j<NUMBER_OF_TICK_PER_MEASURE*2; j++)
	{
		result = [result stringByAppendingFormat:@"%d", MetroEnable[j]];
	}
	NSLog(result);
#endif	
}

-(void) stopTimer {
	[tokTimer invalidate];
	tokTimer = nil; // ensures we never invalidate an already invalid Timer
}

-(void) resumeTimer {
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
#ifdef TOK_DEBUG	
	NSLog(@"nextTickTime: %f, now:%f, TickStartTime:%f, tickInterval:%f", nextTickTime, now, TickStartTime, tickInterval);
#endif	
	nextTickTime = (double)((int)((now - TickStartTime)/tickInterval)+1) * tickInterval + TickStartTime;
#ifdef TOK_DEBUG	
	NSLog(@"nextTickTime: %f, now:%f, TickStartTime:%f, tickInterval:%f", nextTickTime, now, TickStartTime, tickInterval);
#endif
	self.flagOn = NO;
	PosOnScore = ( (int)((now - TickStartTime)/tickInterval)-1);
	PosOnScore %= (NUMBER_OF_TICK_PER_MEASURE*2);
	tokTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_RESOLUTION target:self selector:@selector(OnTimerTick) userInfo:nil repeats:YES];
}

@end
