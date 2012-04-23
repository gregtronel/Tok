//
//  Grid.m
//  tok
//
//  Created by Sang Won Lee on 10/13/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "Grid.h"


@implementation Grid

@synthesize numCoinsInBin;
@synthesize gridChanged;

static Grid * instance = nil;

GridPoint bin;

+(Grid *)sharedInstance
{
	@synchronized(self) {
		if(!instance) {
			instance = [[Grid alloc] init];
		}
	}
	
	return instance;
}


-(Grid *) init{
	self = [super init];
	if(self){
		for ( int i=0; i< MAX_NUMBER_OF_ROW; i++)
			for (int j=0; j< NUMBER_OF_BEATS_PER_ROW; j++)
				coins[i][j] = nil;
		bin.row = -1;
		bin.col = -1;
		ghostCoinThreshold = (GHOST_INTERVAL*60/[Environment sharedInstance].bpm);
	}
	return self;
}

-(BOOL) isCoinThereAt:(GridPoint) point{
	return([self isCoinPresent:point.row with:point.col]);
}

-(BOOL) isCoinPresent: (int) rowNum with: (int) colNum{
	if(rowNum < 0 || colNum < 0)
		return NO;
	return (coins[rowNum][colNum] != nil);
}

-(BOOL) isCoinArrived: (int) rowNum with: (int) colNum{
	if(rowNum < 0 || colNum < 0)
		return NO;
	if(coins[rowNum][colNum] != nil)
		return (!coins[rowNum][colNum].moving);
	return NO;
}

-(Coin *) getCoinAt:(GridPoint) point{
	return coins[point.row][point.col];
}


-(void) move:(Coin *) coin To:(GridPoint) destination broadcast:(BOOL) broadcast{
	if (!coin) {
		NSLog(@"HEYHEYHEY, coin is nil it can't be happening, debug it");
		return;
	}

	if(coin.isInBin){ 
		[[DataHandler sharedInstance] sendAddCoinTo: destination withColor:coin.color];
	}
	else{
		if(broadcast)
			[[DataHandler sharedInstance] sendMoveCoinFrom:coin.point To:destination WithEnergy: coin.gScore];
		[self remove:coin broadcast:NO toBin:YES];
	}
	[self put:coin At:destination fromBin:YES];

}

//
//-(void) addGhost:(Coin *) coin To:(GridPoint) destination broadcast:(BOOL) broadcast{
//	[[DataHandler sharedInstance] sendAddCoinTo: destination withColor:coin.color];
//	[self put:coin At:destination fromBin:NO];
//	gridChanged++;
//}


-(void) put:(Coin *) coin At:(GridPoint) destination fromBin:(BOOL)fromBin {
	if ( coins[destination.row][destination.col]  != nil) 
#ifdef TOK_DEBUG
		NSLog(@" there is already a coin:%p", coins[destination.row][destination.col]);
#endif
	coins[destination.row][destination.col] = coin;
	coin.point = destination;
	coin.isInBin = NO;
	if ( fromBin)
		numCoinsInBin--;
	if(coin.point.row == [Environment sharedInstance].myRow || destination.row == [Environment sharedInstance].myRow)
	{
		timeofLastMove = [[NSDate date] timeIntervalSince1970];
#ifdef TOK_DEBUG
		NSLog(@"timeOfLastMove Updated:%f", timeofLastMove);
#endif
	}
}

-(void) remove:(Coin *) coin broadcast:(BOOL) broadcast toBin:(BOOL) goToBin{
	coins[coin.point.row][coin.point.col] = nil;
	if(broadcast)
		[[DataHandler sharedInstance] sendRemoveCoinAt: coin.point fadeOut:!goToBin];
	
	if (goToBin)
	{
		coin.point= bin;
		coin.isInBin = YES;
		numCoinsInBin++;
	}
}


-(void) printGrid{
#ifdef TOK_DEBUG
	NSLog(@"printGrid");
	for(int i=MAX_NUMBER_OF_ROW-1; i>=0 ; i--)
	{
		NSString * result = @"";

		for(int j=0; j<NUMBER_OF_BEATS_PER_ROW; j++)
		{
			result = [result stringByAppendingFormat:@"%d", (coins[i][j] != nil)];
		}
		NSLog(result);
	}
#endif
}


-(int) numCoinsInRow: (int) rowNum {
	int p = 0;
	for(int k = 0;k < NUMBER_OF_BEATS_PER_ROW;k++){
		if ([self isCoinPresent:rowNum with:k]){
			p++;
		}
	}
	return p;
}

-(void) checkGridActivity{
	//Check Grid activity and add ghost coin
	NSTimeInterval time = [[NSDate date] timeIntervalSince1970]; 
	if (time - timeofLastMove > ghostCoinThreshold){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AddGhostCoin" object: nil userInfo:nil];
		timeofLastMove = time;
#ifdef TOK_DEBUG
		NSLog(@"timeOfLastMove: %f", time);
#endif
		
	}
	
}



@end
