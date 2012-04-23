//
//  Grid.h
//  tok
//
//  Created by Sang Won Lee on 10/13/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coin.h"
#import "DataHandler.h"



@interface Grid : NSObject {
	// whether there is coin or not will be determined by 
	// the array of coin reference. 
	Coin * coins[MAX_NUMBER_OF_ROW][NUMBER_OF_BEATS_PER_ROW] ; // 2Dimensional Array 
	int gridChanged;
	int numCoinsInBin;
	int MeasuresSinceGridChange;
	NSTimeInterval timeofLastMove;
	float ghostCoinThreshold;
}

+(Grid *) sharedInstance;
-(Grid *) init;
-(BOOL) isCoinThereAt:(GridPoint) point;
-(Coin *) getCoinAt:(GridPoint) point;
-(void) move:(Coin *) coin To:(GridPoint) destination broadcast:(BOOL) braodcast;
-(void) put:(Coin *) coin At:(GridPoint) destination fromBin:(BOOL)fromBin;
-(void) remove:(Coin *) coin broadcast:(BOOL) broadcast toBin:(BOOL) killCoin;
-(void) addGhost:(Coin *) coin To:(GridPoint) destination broadcast:(BOOL) broadcast;

-(void) printGrid;
-(BOOL) isCoinPresent: (int) rowNum with: (int) colNum;
-(BOOL) isCoinArrived: (int) rowNum with: (int) colNum;
-(int) numCoinsInRow: (int) rowNum;
-(void) checkGridActivity;

@property int numCoinsInBin;
@property int gridChanged;


@end
