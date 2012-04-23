//
//  Bluetooth.m
//  tok
//
//  Created by Sang Won Lee on 10/21/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "Bluetooth.h"


@implementation Bluetooth

@synthesize peerList;
@synthesize syncState;
@synthesize connectedPeerList;

static Bluetooth * instance = nil;

+(Bluetooth *)sharedInstance
{
	@synchronized(self) {
		if(!instance) {
			instance = [[Bluetooth alloc] init];
		}
	}
	
	return instance;
}

-(id) init{
	self = [super init];
	
	if ( self ) {
		sleep(0.5);
		currentSession = [[GKSession alloc] initWithSessionID:@"TOKBLUETOOTH" 
												  displayName:nil 
												  sessionMode:GKSessionModePeer];
		currentSession.delegate = self;
		[currentSession setDataReceiveHandler:self withContext:nil];
		currentSession.available = YES;
		
		mySelfPeerID = currentSession.peerID;
		peerList = [[NSMutableDictionary alloc] init];
		connectedPeerList = [[NSMutableDictionary alloc] init];
		connectedPeerArray = [[NSMutableArray alloc] init];
		master = NO;
		self.syncState = NOTSYNCED;
		currentSession.available = YES;

	}
	return self;
}

- (void)start {
	currentSession.available = YES;
}



- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"Connection Failed to %@ with the reason(%@)", peerID, [error localizedDescription]);
	NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:peerID,@"peerID" , [session displayNameForPeer : peerID], @"display",[error localizedDescription] ,@"error", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_CONNECTING object: nil userInfo:data ];	
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error{
	NSLog(@"Session Failed with the reason(%@)",  [error localizedDescription]);
	[currentSession release];
	
	currentSession = [[GKSession alloc] initWithSessionID:@"TOKBLUETOOTH" 
											  displayName:nil 
											  sessionMode:GKSessionModePeer];
}
-(void) connectWithPeer: (NSString *) peerID{

	[currentSession connectToPeer:peerID  withTimeout:10];
	NSLog(@"Connection requested to %@ (%@)", peerID, [peerList objectForKey:peerID]);

}

- (void)session:(GKSession *)session
didReceiveConnectionRequestFromPeer:(NSString *)peerID{
	NSLog(@"Conection request received from %@(%@)",[session displayNameForPeer: peerID], peerID);
	[session acceptConnectionFromPeer:peerID error:nil];
}



-(void) sendMessage:(NSString *) msgID withDataArray:(NSArray*) Data{
	
	NSString * concatnatedString = [NSString stringWithString:@""];
	
	for(NSString * compononet in Data)
		concatnatedString = [concatnatedString stringByAppendingPathComponent:compononet];
	
	[self sendMessage:msgID withData: concatnatedString];
}

-(void) sendMessage:(NSString *) msgID withData:(NSString*) Data{
	BOOL sent = NO;
	if (Data != nil)
		msgID = [msgID stringByAppendingPathComponent:Data]; 
	NSData * data = [msgID dataUsingEncoding: NSASCIIStringEncoding];
	NSString* str=[[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];

	NSLog(@"session:%@\n data:%@\n msgID:%@", currentSession, str, msgID);
	NSError * error;
	sent=[currentSession sendDataToAllPeers:data 
								   withDataMode:GKSendDataReliable 
										  error:&error];
	if(sent)
		NSLog(@"message Sent :%@", msgID);
	else 
		NSLog(@"message Sending Failed:%@", [error localizedDescription]);

}

-(void) sendSyncMessage {
	if (master){
		[self sendMessage:SYNC_MASTER_SYNC withData:nil];
	}
	else {
		//NSNumber * currTime = [[NSNumber init] initWithDouble:[[NSDate date] timeIntervalSince1970]];
		[[TokClock sharedClock].SyncTimeStart addObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
		NSLog(@"%f",[[NSDate date] timeIntervalSince1970]);
		[self sendMessage:SYNC_SLAVE_SYNC withData:nil];
	}

		
}

-(void) sendRemoveCoinAt:(GridPoint)point
{
	NSArray * data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", point.row], [NSString stringWithFormat:@"%d", point.col], nil];
	[self sendMessage:GAME_REMOVE_COIN withDataArray:data];
	NSLog(@"Removed");
}

-(void) sendAddCoinTo:(GridPoint) destination
{
	NSString * msgNum1=[NSString stringWithFormat:@"%d", destination.row];
	NSString * msgNum2=[NSString stringWithFormat:@"%d", destination.col];
	NSString * msgNum3=[NSString stringWithFormat:@"%d", [Environment sharedInstance].myRow];
	[self sendMessage:GAME_ADD_COIN withDataArray:[NSArray arrayWithObjects:msgNum1,msgNum2,msgNum3,nil]];
	NSLog(@"Added");
}

-(void) sendMoveCoinFrom:(GridPoint) source To: (GridPoint) destination
{
	NSString * msgNum1=[NSString stringWithFormat:@"%d", source.row];
	NSString * msgNum2=[NSString stringWithFormat:@"%d", source.col];
	NSString * msgNum3=[NSString stringWithFormat:@"%d", destination.row];
	NSString * msgNum4=[NSString stringWithFormat:@"%d", destination.col];
	[self sendMessage:GAME_MOVE_COIN withDataArray:[NSArray arrayWithObjects:msgNum1,msgNum2,msgNum3,msgNum4,nil]];
	NSLog(@"Moved");
}


-(void) startSync {
	
	[connectedPeerArray addObjectsFromArray:[connectedPeerList allKeys]];
	TotalPeers = [connectedPeerArray count];
	
	if (TotalPeers == 0)
		return;
	NSLog(@"Peer List of the Master Phone %d",TotalPeers);
	master = YES;
	TotalPeersSynced = 0;
	NSArray * msgContents=[NSArray arrayWithObjects:[connectedPeerArray objectAtIndex:TotalPeersSynced],
						   [NSString stringWithFormat:@"%d", TotalPeersSynced+1], nil];
	
	[self sendMessage:SYNC_DECLARE_MASTER withDataArray:msgContents];

}

-(void) syncDone {
	self.syncState = SYNCED;
	NSMutableArray *timeArray = [[NSMutableArray alloc] init];
	NSLog(@"Done with synchronization after %d", [TokClock sharedClock].SyncCount);
	for(int i = 0; i <NUM_SYNC; i++){
		NSLog(@"%f\t%f",[[[TokClock sharedClock].SyncTimeStart objectAtIndex:i] doubleValue],[[[TokClock sharedClock].SyncTimeEnd objectAtIndex:i] doubleValue]);
		double temp = [[[TokClock sharedClock].SyncTimeEnd objectAtIndex:i] doubleValue] - [[[TokClock sharedClock].SyncTimeStart objectAtIndex:i] doubleValue];
		[timeArray addObject:[NSNumber numberWithDouble:temp]];
	}
	NSArray *sortedArray = [timeArray sortedArrayUsingSelector:@selector(compare:)];
	[TokClock sharedClock].latency = ([[sortedArray objectAtIndex:(NUM_SYNC-1)/2] doubleValue]) /2;
	NSLog(@"Median Latency: %f",[TokClock sharedClock].latency);
	
	[self sendMessage:SYNC_RESPOND_TO_MASTER withData:nil];
	
}

- (void) receiveData:(NSData *)data 
            fromPeer:(NSString *)peer 
           inSession:(GKSession *)session 
             context:(void *)context {
	NSLog(@"Message Received");
	NSString* str=[[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	NSLog(@"%@", str);
	NSArray * msg=[str pathComponents];
	NSString * msgType = [msg objectAtIndex:0];
	if([msgType isEqualToString:SYNC_SLAVE_SYNC]){
		if(master){
			[self sendSyncMessage];
		}
	}
	else if([msgType isEqualToString:SYNC_MASTER_SYNC]){
		if(self.syncState==SYNCING){
			
			[[TokClock sharedClock].SyncTimeEnd addObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
			[TokClock sharedClock].SyncCount ++;
			if([TokClock sharedClock].SyncCount >= NUM_SYNC){
				[self syncDone];
			}
			else {
				[self sendSyncMessage];
			}
		}
	}
	else if([msgType isEqualToString:SYNC_DECLARE_MASTER]) {

		if([[msg objectAtIndex:1] isEqualToString:mySelfPeerID]){

			self.syncState = SYNCING;
			[Environment sharedInstance].myRow=[[msg objectAtIndex:2] intValue];
			NSLog(@"row number received as %d",[Environment sharedInstance].myRow);
			id appDelegate = [[UIApplication sharedApplication] delegate];
			[appDelegate runPlayScene];
			[TokClock sharedClock].SyncCount = 0;
			[self sendSyncMessage]; 
		}
	}
	else if([msgType isEqualToString:SYNC_RESPOND_TO_MASTER]) {
		if(master)
		{
			TotalPeersSynced++;
			NSLog(@"else part is running(%d>=%d)",TotalPeersSynced ,TotalPeers);
			if(TotalPeersSynced >= TotalPeers){
				
				[[TokClock sharedClock] startMetronomeAfter: METRONOME_WAIT_TIME];
				[self sendMessage:START_METRONOME_GLOBAL withData:nil];//[NSString stringWithFormat:@"%f", now]];
				
			}
			else{
				NSArray * msgContents=[NSArray arrayWithObjects:[connectedPeerArray objectAtIndex:TotalPeersSynced], 
									   [NSString stringWithFormat:@"%d", TotalPeersSynced+1], nil];

				[self sendMessage:SYNC_DECLARE_MASTER withDataArray:msgContents];
				NSLog(@"else part is running2");
			}
			
		}
	}
	else if([msgType isEqualToString:START_METRONOME_GLOBAL]) {
		
		double waitTimeSlave = METRONOME_WAIT_TIME - [TokClock sharedClock].latency;
		[[TokClock sharedClock] startMetronomeAfter: waitTimeSlave];
		NSLog(@"Slave metronome starts in %f\n", waitTimeSlave);
		
	}
	else if ([msgType isEqualToString:GAME_ADD_COIN])
	{
		NSLog(@"New Coin is added to (%d,%d) by the player %d", [[msg objectAtIndex:1] intValue],[[msg objectAtIndex:2] intValue],[[msg objectAtIndex:3] intValue]);
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:[msg objectAtIndex:1],@"row" , [msg objectAtIndex:2],@"col" , [msg objectAtIndex:3] ,@"color", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"coinAdded" object: nil userInfo:data ];
	}
	else if ([msgType isEqualToString:GAME_MOVE_COIN])
	{
		NSLog(@" Coin is moved from (%d,%d) to (%d,%d)",[[msg objectAtIndex:1] intValue],[[msg objectAtIndex:2] intValue],[[msg objectAtIndex:3] intValue],[[msg objectAtIndex:4] intValue]);
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:[msg objectAtIndex:1],@"sourceRow" , [msg objectAtIndex:2],@"sourceCol" , [msg objectAtIndex:3] ,@"destRow",[msg objectAtIndex:4] ,@"destCol", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"coinMoved" object: nil userInfo:data ];

	}
	else if ([msgType isEqualToString:GAME_REMOVE_COIN])
	{
		NSLog(@" Coin is removed!!");
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:[msg objectAtIndex:1],@"row" , [msg objectAtIndex:2],@"col", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"coinRemoved" object: nil userInfo:data ];
	}

}

-(void)session:(GKSession *)session 
           peer:(NSString *)peerID 
 didChangeState:(GKPeerConnectionState)state {

	switch (state)
    {
        case GKPeerStateConnected:
			NSLog(@"StateChanged : GKPeerStateConnected(%d) of %@", state, [currentSession displayNameForPeer: peerID]);

			[connectedPeerList setObject:[NSString stringWithFormat:@"%@", [currentSession displayNameForPeer: peerID]] forKey:peerID];
			[peerList removeObjectForKey:peerID];

			break;
        case GKPeerStateDisconnected:
			NSLog(@"StateChanged : GKPeerStateDisconnected(%d) of %@", state, [currentSession displayNameForPeer: peerID]);
			[connectedPeerList removeObjectForKey:peerID];
            break;
        case GKPeerStateAvailable:
			NSLog(@"StateChanged : GKPeerStateAvailable(%d) of %@", state, [currentSession displayNameForPeer: peerID]);
			[peerList setObject:[NSString stringWithFormat:@"%@", [currentSession displayNameForPeer: peerID]] forKey:peerID];
            break;
        case GKPeerStateUnavailable:
			NSLog(@"StateChanged : GKPeerStateUnavailable(%d) of %@", state, [currentSession displayNameForPeer: peerID]);
			[peerList removeObjectForKey:peerID];
            break;
        case GKPeerStateConnecting:
			NSLog(@"StateChanged : GKPeerStateConnecting(%d) of %@", state, [currentSession displayNameForPeer: peerID]);
            break;
    }
	NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:peerList,@"available" , connectedPeerList,@"connected", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PEER_LIST object:nil userInfo:data];
}


- (void) dealloc
{
	[currentSession disconnectFromAllPeers];
	currentSession.delegate = nil;
	currentSession.available = NO;
	[currentSession release];
	[peerList release];
	[connectedPeerList release];
	[connectedPeerArray release];
	[super dealloc];
}


@end
