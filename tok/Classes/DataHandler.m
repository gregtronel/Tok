/*
 
 File: DataHandler.h
 Abstract: Concentrates the management of the messages related to the application specific protocol. It retrieves the data to send and store from the DataProvider.
 This is and example of the protocol (4 first bytes = command):
 
 Peer A -> SENDFoo bar
 Peer B -> ACPT
 Peer A -> SIZE8
 Peer B -> ACKN
 Peer A -> Beam It!
 Peer B -> SUCS
 
 Refer to DataHandler.m for more details.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This ArcTouch software is supplied to you by 
 ArcTouch Inc. ("ArcTouch") in consideration of your agreement to the 
 following terms, and your use, installation, modification or redistribution 
 of this ArcTouch software constitutes acceptance of these terms.  
 If you do not agree with these terms, please do not use, install, 
 modify or redistribute this ArcTouch software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, ArcTouch grants you a personal, non-exclusive
 license, under ArcTouch's copyrights in this original ArcTouch software (the
 "ArcTouch Software"), to use, reproduce, modify and redistribute the ArcTouch
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the ArcTouch Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the ArcTouch Software.
 Neither the name, trademarks, service marks or logos of ArcTouch Inc. may
 be used to endorse or promote products derived from the ArcTouch Software
 without specific prior written permission from ArcTouch.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by ArcTouch herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the ArcTouch Software may be incorporated.
 
 The ArcTouch Software is provided by ArcTouch on an "AS IS" basis.  ARCTOUCH
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE ARCTOUCH SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL ARCTOUCH BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE ARCTOUCH SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF ARCTOUCH HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "DataHandler.h"

#define BEAM_IT_REQUESTING_PERMISSION_TO_SEND @"SEND"
#define BEAM_IT_ACCEPT_CONTACT @"ACPT"
#define BEAM_IT_REJECT_CONTACT @"RJCT"
#define BEAM_IT_INFO_SIZE @"SIZE"
#define BEAM_IT_ACKNOWLEDGE @"ACKN"
#define BEAM_IT_SUCCESS @"SUCS"
#define BEAM_IT_I_AM_BUSY @"BUSY"
#define BEAM_IT_ERROR @"ERRO"
#define BEAM_IT_CANCEL @"CNCL"

#define PROCESSING_TAG 0
#define CONFIRMATION_RETRY_TAG 1
#define CONFIRMATION_RECEIVE_TAG 2

#define ERROR_SOUND_FILE_NAME "error"
#define RECEIVED_SOUND_FILE_NAME "received"
#define REQUEST_SOUND_FILE_NAME "request"
#define SEND_SOUND_FILE_NAME "sent"


@implementation DataHandler

@synthesize currentSession;
@synthesize devicesManager;
@synthesize master;

static DataHandler * instance = nil;

+(DataHandler *)sharedInstance
{
	@synchronized(self) {
		if(!instance) {
			instance = [[DataHandler alloc] init];
			
		}
	}
	return instance;
}

+(void)cleanupDataHandler
{
	@synchronized(self) {
		if(instance) {
			[instance release];
			instance = nil;
		}
	}
}

- (id)init{
	self = [super init];
	
	if (self) {
		currentState = DHSNone;
		master = NO;
		connectedPeerArray = [[NSMutableArray alloc] init];
		syncState = NOTSYNCED;
	}
	
	[self loadSounds];
	
	return self;
}
-(void) sendMessage:(NSString *) msgID toPeer: (NSString *) peerID withDataArray:(NSArray*) Data{
	
	NSString * concatnatedString = [NSString stringWithString:@""];
	
	for(NSString * compononet in Data)
		concatnatedString = [concatnatedString stringByAppendingPathComponent:compononet];
	
	[self sendMessage:msgID toPeer:peerID withData:concatnatedString];
}

-(void) sendMessage:(NSString *) msgID toPeer: (NSString *) peerID withData:(NSString*) Data{
	BOOL sent = NO;
	if (Data != nil)
		msgID = [msgID stringByAppendingPathComponent:Data]; 
	NSData * data = [msgID dataUsingEncoding: NSASCIIStringEncoding];
	
	NSError * error;
	if(peerID!=nil){
		NSArray* peer = [NSArray arrayWithObject:peerID];
		sent=[currentSession sendData:data toPeers:peer
							 withDataMode:GKSendDataReliable 
									error:nil];

	}
	else{
		sent=[currentSession sendDataToAllPeers:data
									   withDataMode:GKSendDataReliable 
											  error:nil];
	}
#ifdef TOK_DEBUG	
	if(sent)
		NSLog(@"message Sent :%@", msgID);
	else 
		NSLog(@"message Sending Failed:%@", [error localizedDescription]);
#endif
	
}

-(void) sendSyncMessageTo:(NSString *) peerID {
	if (master){
		[self sendMessage:SYNC_MASTER_SYNC toPeer:peerID withData:nil];
	}
	else {
		//NSNumber * currTime = [[NSNumber init] initWithDouble:[[NSDate date] timeIntervalSince1970]];
		[[TokClock sharedClock].SyncTimeStart addObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
#ifdef TOK_DEBUG
		NSLog(@"SyncTimeStart:%f", [[[TokClock sharedClock].SyncTimeStart lastObject] doubleValue]);
#endif
		[self sendMessage:SYNC_SLAVE_SYNC toPeer:peerID withData:nil];

	}
	
	
}

-(void) sendSlaveIsReady
{
	[self sendMessage:SLAVE_IS_READY toPeer:masterPeerID withDataArray:nil];
#ifdef TOK_DEBUG
	NSLog(@"Slave Said Ready");
#endif
}

-(void) sendRemoveCoinAt:(GridPoint)point fadeOut:(BOOL) fadeOutOption
{
	NSArray * data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", point.row], [NSString stringWithFormat:@"%d", point.col], [NSString stringWithFormat:@"%d", fadeOutOption],nil];
	[self sendMessage:GAME_REMOVE_COIN toPeer:nil withDataArray:data];
#ifdef TOK_DEBUG	
	NSLog(@"Removed");
#endif
}

-(void) sendAddCoinTo:(GridPoint) destination withColor:(int)color
{
	NSString * msgNum1=[NSString stringWithFormat:@"%d", destination.row];
	NSString * msgNum2=[NSString stringWithFormat:@"%d", destination.col];
	NSString * msgNum3=[NSString stringWithFormat:@"%d", color];
	[self sendMessage:GAME_ADD_COIN toPeer:nil withDataArray:[NSArray arrayWithObjects:msgNum1,msgNum2,msgNum3,nil]];
#ifdef TOK_DEBUG	
	NSLog(@"Added");
#endif
}

-(void) broadcastScore: (float) rhyAccu atRow: (int) theRow {
	NSString * scoreStr = [NSString stringWithFormat:@"%f", rhyAccu];
	NSString * rowStr = [NSString stringWithFormat:@"%d", theRow];
	[self sendMessage:GAME_POINT_UPDATE toPeer:nil withDataArray:[NSArray arrayWithObjects:scoreStr,rowStr,nil]];
	
}


-(void) sendMoveCoinFrom:(GridPoint) source To: (GridPoint) destination WithEnergy: (float) energy
{
	NSString * msgNum1=[NSString stringWithFormat:@"%d", source.row];
	NSString * msgNum2=[NSString stringWithFormat:@"%d", source.col];
	NSString * msgNum3=[NSString stringWithFormat:@"%d", destination.row];
	NSString * msgNum4=[NSString stringWithFormat:@"%d", destination.col];
	NSString * msgNum5=[NSString stringWithFormat:@"%f", energy];
	[self sendMessage:GAME_MOVE_COIN toPeer:nil withDataArray:[NSArray arrayWithObjects:msgNum1,msgNum2,msgNum3,msgNum4,msgNum5,nil]];
#ifdef TOK_DEBUG	
	NSLog(@"Moved");
#endif
}

-(void) sendCoinSelected:(int) color{
	NSString * msgNum1=[NSString stringWithFormat:@"%d", color];
	[self sendMessage:CONF_COIN_SELECTED toPeer:nil withData:msgNum1];
#ifdef TOK_DEBUG	
	NSLog(@"color selection of %d is sent",color);
#endif
}

-(void) declareMaster{
	for( Device * device in [devicesManager sortedDevices])
	{
		if([device isConnected])
			[connectedPeerArray addObject: device.peerID];
	}
	
	TotalPeers = [connectedPeerArray count];
	slaveNotReady = [[NSMutableArray alloc] init] ;
	[ slaveNotReady addObjectsFromArray:connectedPeerArray];
	
	master = YES;
	/*CAUTION: The Below Line shold be removed, and done when pressing 'Next', not 'Start'*/
	masterPeerID = currentSession.peerID;
	/*CAUTION: The above Line shold be removed, and done when pressing 'Next', not 'Start'*/
	[Environment sharedInstance].numRow = TotalPeers+1;
	NSArray * msgContents=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", TotalPeers+1],nil];
	[self sendMessage:DECLARE_MASTER toPeer: nil withDataArray:msgContents];
}

-(void) startSync {

	if (TotalPeers == 0)
		return;
#ifdef TOK_DEBUG
	NSLog(@"Peer List of the Master Phone %d",TotalPeers);
#endif	
	TotalPeersSynced = 0;
	NSArray * msgContents=[NSArray arrayWithObjects:[connectedPeerArray objectAtIndex:TotalPeersSynced],
						   [NSString stringWithFormat:@"%d", TotalPeersSynced+1],[NSString stringWithFormat:@"%d", [Environment sharedInstance].bpm], nil];
	
	[self sendMessage:SYNC_DECLARE_MASTER toPeer: [connectedPeerArray objectAtIndex:TotalPeersSynced] withDataArray:msgContents];
	
}

-(void) syncDone {
	syncState = SYNCED;
	NSMutableArray *timeArray = [[[NSMutableArray alloc] init] autorelease];
#ifdef TOK_DEBUG	
	NSLog(@"Done with synchronization after %d", [TokClock sharedClock].SyncCount);
#endif	
	for(int i = 0; i <NUM_SYNC-1; i++){
#ifdef TOK_DEBUG		
		NSLog(@"%f\t%f",[[[TokClock sharedClock].SyncTimeStart objectAtIndex:i] doubleValue],[[[TokClock sharedClock].SyncTimeEnd objectAtIndex:i] doubleValue]);
#endif		
		double temp = [[[TokClock sharedClock].SyncTimeEnd objectAtIndex:i] doubleValue] - [[[TokClock sharedClock].SyncTimeStart objectAtIndex:i] doubleValue];
		[timeArray addObject:[NSNumber numberWithDouble:temp]];
	}
	NSArray *sortedArray = [timeArray sortedArrayUsingSelector:@selector(compare:)];
	[TokClock sharedClock].latency = 0;
	int k = 0;
	//Taking the mean of the three median values
	for(k = -2; k<=2; k++){
		[TokClock sharedClock].latency += ([[sortedArray objectAtIndex:((NUM_SYNC-1)/2+k)] doubleValue]);
	}
	[TokClock sharedClock].latency = [TokClock sharedClock].latency / (2*(2*k-1));
#ifdef TOK_DEBUG
	NSLog(@"Median Latency: %f",[TokClock sharedClock].latency);
#endif	
	[self sendMessage:SYNC_RESPOND_TO_MASTER toPeer:nil withData:nil];

}

- (void) receiveData:(NSData *)data 
            fromPeer:(NSString *)peer 
           inSession:(GKSession *)session 
             context:(void *)context {
#ifdef TOK_DEBUG	
	NSLog(@"Message Received");
#endif	
	NSString* str=[[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
#ifdef TOK_DEBUG	
	NSLog(@"%@", str);
#endif
	NSArray * msg=[str pathComponents];
	NSString * msgType = [msg objectAtIndex:0];
	if ([msgType isEqualToString:SLAVE_IS_READY])
	{
		if(master){
			[slaveNotReady removeObjectIdenticalTo:peer];
			if([slaveNotReady count] == 0)
				[[NSNotificationCenter defaultCenter] postNotificationName:@"confReadyToProceed" object: nil userInfo:nil ];
	
		}
	}
	else if([msgType isEqualToString:CONF_COIN_SELECTED]){
#ifdef TOK_DEBUG		
		NSLog(@"coin selection of No. %@ is received", [msg objectAtIndex:1]);
#endif		
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:[msg objectAtIndex:1],@"color" , nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"conf_CoinSelected" object: nil userInfo:data ];
		[[Environment sharedInstance] setConnected:[[msg objectAtIndex:1] intValue] With : YES];
	}
	else if([msgType isEqualToString:SYNC_SLAVE_SYNC]){
		if(master){
			[self sendSyncMessageTo:[connectedPeerArray objectAtIndex:TotalPeersSynced]];
		}
	}
	else if([msgType isEqualToString:SYNC_MASTER_SYNC]){
		if(syncState==SYNCING){
			
			[[TokClock sharedClock].SyncTimeEnd addObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
#ifdef TOK_DEBUG
			NSLog(@"SyncTimeEnd:%f", [[[TokClock sharedClock].SyncTimeEnd lastObject] doubleValue]);
#endif
			[TokClock sharedClock].SyncCount ++;
			if([TokClock sharedClock].SyncCount >= NUM_SYNC){
				[self syncDone];
			}
			else {
				[self sendSyncMessageTo:peer];
			}
		}
	}
	else if([msgType isEqualToString:DECLARE_MASTER]) {
			[Environment sharedInstance].numRow = [[msg objectAtIndex:1] intValue];
			TotalPeers=[Environment sharedInstance].numRow;			// Added 
			masterPeerID = peer;
			id appDelegate = [[UIApplication sharedApplication] delegate];
			[appDelegate runConfScene];
	}
	else if([msgType isEqualToString:SYNC_DECLARE_MASTER]) {
		if([[msg objectAtIndex:1] isEqualToString:currentSession.peerID]){
			
			syncState = SYNCING;
#ifdef TOK_DEBUG			
			NSLog(@"row number received as %d",[Environment sharedInstance].myRow);
#endif
			id appDelegate = [[UIApplication sharedApplication] delegate];
			//[Environment sharedInstance].numRow = [[msg objectAtIndex:3] intValue];
			[Environment sharedInstance].bpm = [[msg objectAtIndex:3] intValue];
			[appDelegate runPlayScene];
			[TokClock sharedClock].SyncCount = 0;
			[self sendSyncMessageTo:peer]; 
			//TotalPeers=[Environment sharedInstance].numRow;			// Added 
		}
	}
	else if([msgType isEqualToString:SYNC_RESPOND_TO_MASTER]) {
		if(master)
		{
			TotalPeersSynced++;
#ifdef TOK_DEBUG
			NSLog(@"else part is running(%d>=%d)",TotalPeersSynced ,TotalPeers);
#endif			
			if(TotalPeersSynced >= TotalPeers){
				NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970] + METRONOME_WAIT_TIME;
				for(int i=0; i<TotalPeers;i++){
					NSTimeInterval waitTime = startTime - [[NSDate date] timeIntervalSince1970];
					NSString *str = [NSString stringWithFormat:@"%f", waitTime];
					[self sendMessage:START_METRONOME_GLOBAL toPeer: [connectedPeerArray objectAtIndex:i] withData:str];//[NSString stringWithFormat:@"%f", now]];
				}
				NSTimeInterval waitTime = startTime - [[NSDate date] timeIntervalSince1970];
				[[TokClock sharedClock] startMetronomeAfter: waitTime];
			}
			else{
				NSArray * msgContents=[NSArray arrayWithObjects:[connectedPeerArray objectAtIndex:TotalPeersSynced], 
									   [NSString stringWithFormat:@"%d", TotalPeersSynced+1], [NSString stringWithFormat:@"%d", [Environment sharedInstance].bpm], nil];
				
				[self sendMessage:SYNC_DECLARE_MASTER toPeer: [connectedPeerArray objectAtIndex:TotalPeersSynced]  withDataArray:msgContents];
#ifdef TOK_DEBUG				
				NSLog(@"else part is running2");
#endif
			}
			
		}
	}
	else if([msgType isEqualToString:START_METRONOME_GLOBAL]) {
		NSTimeInterval waitTime = [[msg objectAtIndex:1] doubleValue];
		double waitTimeSlave = waitTime - [TokClock sharedClock].latency;
		[[TokClock sharedClock] startMetronomeAfter: waitTimeSlave];
#ifdef TOK_DEBUG		
		NSLog(@"Slave metronome starts in %f\n", waitTimeSlave);
#endif	
	}
	else if ([msgType isEqualToString:GAME_ADD_COIN])
	{
#ifdef TOK_DEBUG		
		NSLog(@"New Coin is added to (%d,%d) by the player %d", [[msg objectAtIndex:1] intValue],[[msg objectAtIndex:2] intValue],[[msg objectAtIndex:3] intValue]);
#endif		
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:[msg objectAtIndex:1],@"row" , [msg objectAtIndex:2],@"col" , [msg objectAtIndex:3] ,@"color", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"coinAdded" object: nil userInfo:data ];
	}
	else if ([msgType isEqualToString:GAME_POINT_UPDATE])
	{
		int theRow = [[msg objectAtIndex:2] intValue];
		float rhyAccu = [[msg objectAtIndex:1] floatValue];
#ifdef TOK_DEBUG		
		NSLog(@"rhyAccy is %f",rhyAccu);
#endif		
		//[[Environment sharedInstance].sharedPoints replaceObjectAtIndex:(NSUInteger) theRow withObject:[NSNumber numberWithFloat:rhyAccu]];
		[[Environment sharedInstance] setSharePoints:rhyAccu toRow:theRow];
#ifdef TOK_DEBUG
		for (int j=0;j<TotalPeers;j++){
			NSLog(@"score of row %d is %f.",j+1,[[Environment sharedInstance] getSharePointsOf:j]);
		}
#endif		
	}
	else if ([msgType isEqualToString:GAME_MOVE_COIN])
	{
#ifdef TOK_DEBUG
		NSLog(@" Coin is moved from (%d,%d) to (%d,%d) with score = %.3f",[[msg objectAtIndex:1] intValue],[[msg objectAtIndex:2] intValue],[[msg objectAtIndex:3] intValue],[[msg objectAtIndex:4] intValue],[[msg objectAtIndex:5] floatValue]);
#endif
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:[msg objectAtIndex:1],@"sourceRow" , [msg objectAtIndex:2],@"sourceCol" , [msg objectAtIndex:3] ,@"destRow",[msg objectAtIndex:4] ,@"destCol", [msg objectAtIndex:5] ,@"score",nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"coinMoved" object: nil userInfo:data ];
	}
	else if ([msgType isEqualToString:GAME_REMOVE_COIN])
	{
#ifdef TOK_DEBUG		
		NSLog(@" Coin is removed!!");
#endif		
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:[msg objectAtIndex:1],@"row" , [msg objectAtIndex:2],@"col",[msg objectAtIndex:3],@"fadeOut", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"coinRemoved" object: nil userInfo:data ];
	}
	
}

- (void)loadSounds {
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	
	CFURLRef errorURL = CFBundleCopyResourceURL(mainBundle, CFSTR(ERROR_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	CFURLRef receivedURL = CFBundleCopyResourceURL(mainBundle, CFSTR(RECEIVED_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	CFURLRef requestURL = CFBundleCopyResourceURL(mainBundle, CFSTR(REQUEST_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	CFURLRef sendURL = CFBundleCopyResourceURL(mainBundle, CFSTR(SEND_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	
	AudioServicesCreateSystemSoundID(errorURL, &errorSound);
	AudioServicesCreateSystemSoundID(receivedURL, &receivedSound);
	AudioServicesCreateSystemSoundID(requestURL, &requestSound);
	AudioServicesCreateSystemSoundID(sendURL, &sendSound);
	
	CFRelease(errorURL);
	CFRelease(receivedURL);
	CFRelease(requestURL);
	CFRelease(sendURL);
}


- (void)dealloc {
	[connectedPeerArray release];
    [slaveNotReady release];
	[super dealloc];
}

@end
