//
//  GhostCoin.m
//  tok
//
//  Created by Ajay Srinivasamurthy on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GhostCoin.h"
#import "Grid.h"
#import "Constants.h"

@implementation GhostCoin


-(id) initWithColor: (Color)color delegate:(CCLayer *) layer{
	self = [super initWithColor: color delegate: layer];
	isGhost = YES;
	gScore = 1.0f;
	return self;
	
}

-(void) moveGhostCoin {
	[NSThread detachNewThreadSelector:@selector(checkMoveGhostCoin) 
							 toTarget:self 
						   withObject:nil];
}

-(void) checkMoveGhostCoin{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL flag = YES;
	int row;
	int col;
	while(flag){
		row = floor(rand()%MAX_NUMBER_OF_ROW);
		col = floor(rand()%NUMBER_OF_BEATS_PER_ROW);
		
		if (row < 0 || col < 0 || row >= MAX_NUMBER_OF_ROW || col >= NUMBER_OF_BEATS_PER_ROW)
#ifdef TOK_DEBUG
			NSLog(@"%d, %d ", row, col);
#endif
		
		if (![[Environment sharedInstance] isTheRowConnected: row])
			continue;
		
		flag = [[Grid sharedInstance] isCoinPresent: row with:col];
	}
	NSDate * now = [NSDate date];
	GridPoint cpoint;
	cpoint.row = row;
	cpoint.col = col;
	
	CGPoint quantizedLocation = [super convertGridToLocation:cpoint];
	[[Grid sharedInstance] move:self To:cpoint broadcast:YES];
#ifdef TOK_DEBUG
		NSLog(@"Ghost is moving to (%d, %d)", row, col);
#endif
	[[Grid sharedInstance] printGrid];
	[self moveCoinTo: quantizedLocation Until: now destroy:NO];
	
	[pool release];
}

-(void) moveCoinTo:(CGPoint) location Until: (NSDate *) date destroy:(BOOL) destroy;
{
	[super moveCoinTo:location Until:date destroy:destroy];
#ifdef TOK_DEBUG
		NSLog(@"ghost coin reached moving reached %p", self);
#endif

}

// Cannot select a ghost coin
-(void) selected{
	
}
 
-(void) unselected{

}

-(void) activate{
	
}

-(void) dealloc{
	[super dealloc];
}
@end
