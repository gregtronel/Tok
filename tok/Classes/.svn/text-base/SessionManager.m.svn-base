/*
 
 File: SessionManager.m
 Abstract: Delegate for the session and sends notifications when it changes.
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

#import "SessionManager.h"

@interface SessionManager ()


- (Device *)addDevice:(NSString *)peerID;
- (void)removeDevice:(Device *)device;


@end


@implementation SessionManager
@synthesize devicesManager;

static SessionManager * instance = nil;

+(SessionManager *)sharedInstance
{
	@synchronized(self) {
		if(!instance){
			instance = [[SessionManager alloc] init];
		}
	}
	
	return instance;
}

+(void)cleanUpSessionManager
{
	@synchronized(self) {
		if(instance){
			[instance release];
			instance = nil;
		}
	}
}

- (id)init{
	self = [super init];
	
	if (self) {
		devicesManager = [[DevicesManager alloc] init];
		
		currentSession = [[GKSession alloc] initWithSessionID:TOK_GLOBAL_SESSION_ID displayName:nil sessionMode:GKSessionModePeer];
		currentSession.available = NO;
		
		[DataHandler sharedInstance].currentSession = currentSession;
		[DataHandler sharedInstance].devicesManager = devicesManager;
		[currentSession disconnectFromAllPeers];
		currentSession.delegate = self;
		[currentSession setDataReceiveHandler:[DataHandler sharedInstance] withContext:nil];
	}
	
	return self;
}

- (void)start {
	currentSession.available = YES;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	
	if ( currentSession != session) 
		return;
	Device *currentDevice = [devicesManager deviceWithID:peerID];
#ifdef TOK_DEBUG
	NSLog(@"didChangeState:%@(%p), %p, %p,state:%d (%@,%@)", peerID, currentDevice,session,  currentSession,state, [session displayNameForPeer:peerID], [currentSession displayNameForPeer:peerID]);//currentSession: %@, receivedSession:%@", [currentSession description], [session description]);
#endif
	if (!currentDevice) {
		currentDevice = [self addDevice:peerID];
	}
	
	currentDevice.state = state;
	
	// Instead of trying to respond to the event directly, it delegates the events.
	// The availability is checked by the main ViewController.
	// The connection is verified by each Device.
	switch (state) {
		case GKPeerStateConnected:
			if([Environment sharedInstance].state == TOK_BLUETOOTH_STATE)
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTED object:nil userInfo:[currentDevice getDeviceInfo]];
			
			break;
		case GKPeerStateConnecting:
		case GKPeerStateAvailable:
			
			if([Environment sharedInstance].state == TOK_BLUETOOTH_STATE)
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_AVAILABLE object:nil userInfo:[currentDevice getDeviceInfo]];
			break;
		case GKPeerStateUnavailable:
		case GKPeerStateDisconnected:
			[currentDevice retain];
			[self removeDevice:currentDevice];
			currentDevice.state = GKPeerStateUnavailable;
			if([Environment sharedInstance].state == TOK_BLUETOOTH_STATE)
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_UNAVAILABLE object:nil userInfo:[currentDevice getDeviceInfo]];
			break;
			
	}
	
}

- (Device *)addDevice:(NSString *)peerID {
	Device *device = [[Device alloc] initWithSession:currentSession peer:peerID];
	[devicesManager addDevice:device];
	[device release];
	
	return device;
}

-(void *)searchPeers
{
	
	NSArray * peerAvailable =  [[[NSArray alloc] initWithArray:[currentSession peersWithConnectionState:GKPeerStateAvailable]] autorelease];
	NSArray * peerConnected =  [[[NSArray alloc] initWithArray:[currentSession peersWithConnectionState:GKPeerStateConnected]] autorelease];
	
	NSEnumerator *e1 = [peerConnected objectEnumerator];
	NSString * peerID;
	while ((peerID = [e1 nextObject])) {
		
		Device *currentDevice = [devicesManager deviceWithID:peerID];
		
		if(!currentDevice){
			currentDevice = [self addDevice:peerID];
#ifdef TOK_DEBUG
			NSLog(@"Connected device added by timer:%@(%@)", peerID, [currentSession displayNameForPeer:peerID]);
#endif
		}
		if ( currentDevice.state != GKPeerStateConnected){
#ifdef TOK_DEBUG
			NSLog(@"Connected device updated by timer:%@(%@)", peerID, [currentSession displayNameForPeer:peerID]);
#endif
			currentDevice.state = GKPeerStateConnected;
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTED object:nil userInfo:[currentDevice getDeviceInfo]];
		}
	}
	
	e1 = [peerAvailable objectEnumerator];
	
	while ((peerID = [e1 nextObject])) {
		
		Device *currentDevice = [devicesManager deviceWithID:peerID];
		
		if(!currentDevice){
			currentDevice = [self addDevice:peerID];
#ifdef TOK_DEBUG
			NSLog(@"Available device added by timer:%@(%@)", peerID, [currentSession displayNameForPeer:peerID]);
#endif
		}
		
		if ( currentDevice.state != GKPeerStateAvailable){
#ifdef TOK_DEBUG
			NSLog(@"Available device updated by timer:%@(%@)", peerID, [currentSession displayNameForPeer:peerID]);
#endif
			currentDevice.state = GKPeerStateAvailable;
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_AVAILABLE object:nil userInfo:[currentDevice getDeviceInfo]];
		}
	}
	
}

- (void)removeDevice:(Device *)device {
	[devicesManager removeDevice:device];
}



- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
#ifdef TOK_DEBUG
	NSLog(@"Connection Reqeust Receiveded To:%@(%@)", peerID, [session displayNameForPeer: peerID]);
#endif
	[currentSession acceptConnectionFromPeer:peerID error:nil];
}
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef TOK_DEBUG
	NSLog(@"Connection Failed to %@ with the reason(%@)", peerID, [error localizedDescription]);
#endif
	
	Device *currentDevice = [devicesManager deviceWithID:peerID];
	// Does the same thing as the didStateChange method. It tells a Device that the connection failed.
	if (currentDevice) {
		NSMutableDictionary * data = [currentDevice getDeviceInfo];
		[data setObject:[error localizedDescription] forKey:@"error"];
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTION_FAILED object:nil userInfo:data];
	}
}
//
//- (void)session:(GKSession *)session didFailWithError:(NSError *)error{
//	NSLog(@"Session Failed with the reason(%@)",  [error localizedDescription]);
//	[currentSession release];
//	
//	currentSession = [[GKSession alloc] initWithSessionID:TOK_GLOBAL_SESSION_ID 
//											  displayName:nil 
//											  sessionMode:GKSessionModePeer];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	return;
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Error"
														message:[error localizedDescription]
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	
	[currentSession release];
	
	currentSession = [[GKSession alloc] initWithSessionID:TOK_GLOBAL_SESSION_ID 
											  displayName:nil 
											  sessionMode:GKSessionModePeer];
	currentSession.delegate = self;
	[DataHandler sharedInstance].currentSession = currentSession;
	
	[currentSession setDataReceiveHandler:[DataHandler sharedInstance] withContext:nil];
	
	if (!currentSession.available)
		currentSession.available = YES;
	[errorView show];
	[errorView release];
}


- (void) dealloc
{
#ifdef TOK_DEBUG
	NSLog(@"dealloc reached");
#endif
	[currentSession disconnectFromAllPeers];
	currentSession.delegate = nil;
	currentSession.available = NO;
	[currentSession release];
	[devicesManager release];
	[super dealloc];
}
@end
