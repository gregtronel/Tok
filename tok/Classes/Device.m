/*
 
 File: Device.m
 Abstract: Represents a phisical device.
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
 Neither the name, trademarks, service marks or logos of A	rcTouch Inc. may
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

#import "Device.h"
#import "SessionManager.h"



@implementation Device

@synthesize deviceName;
@synthesize peerID;
@synthesize state;

- (id)initWithSession:(GKSession *)openSession peer:(NSString *)ID {
	self = [super init];
	if (self) {
		session = [openSession retain];
		state = -1;
		peerID = [ID copy];
		deviceName = [[session displayNameForPeer:peerID] copy];
	}
	return self;
}

- (BOOL)isEqual:(id)object {
	// Basically, compares the peerIDs
	return object && ([object isKindOfClass:[Device class]]) && ([((Device *) object).peerID isEqual:peerID]);
}

- (void)connectAndReplyTo:(id)delegate selector:(SEL)connectionStablishedConnection errorSelector:(SEL)connectionNotStablishedConnection {
	// We need to persist this info, because the call to connect is assynchronous.
	delegateToCallAboutConnection = delegate;
	selectorToPerformWhenConnectionWasStablished = connectionStablishedConnection;
	selectorToPerformWhenConnectionWasNotStablished = connectionNotStablishedConnection;
#ifdef TOK_DEBUG	
	NSLog(@"ConnectionReqeusted To:%@(%@)", peerID, deviceName);
#endif
	// The SessionManager will be responsible for sending the notification that will be caught here.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerConnectionSuccessfull:) name:NOTIFICATION_DEVICE_CONNECTED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerConnectionFailed:) name:NOTIFICATION_DEVICE_CONNECTION_FAILED object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerConnectionFailed:) name:NOTIFICATION_DEVICE_UNAVAILABLE object:nil];

	[session connectToPeer:peerID withTimeout:CONNECTION_TIMEOUT];
}

- (void)triggerConnectionSuccessfull:(NSNotification *)notification {
#ifdef TOK_DEBUG	
	NSLog(@"triggerConnectionSuccessfull");
#endif	
	Device *device = [notification.userInfo objectForKey:DEVICE_KEY];
	
	if ([self isEqual:device] && delegateToCallAboutConnection &&
		[delegateToCallAboutConnection respondsToSelector:selectorToPerformWhenConnectionWasStablished]) {
		[delegateToCallAboutConnection performSelector:selectorToPerformWhenConnectionWasStablished];

		delegateToCallAboutConnection = nil;
		selectorToPerformWhenConnectionWasStablished = nil;
		selectorToPerformWhenConnectionWasNotStablished = nil;
	}
}

- (void)triggerConnectionFailed:(NSNotification *)notification {
#ifdef TOK_DEBUG	
	NSLog(@"triggerConnectionFailed");
#endif
	Device *device = [notification.userInfo objectForKey:DEVICE_KEY];
	if ([self isEqual:device] && delegateToCallAboutConnection &&
		[delegateToCallAboutConnection respondsToSelector:selectorToPerformWhenConnectionWasNotStablished]) {
		[delegateToCallAboutConnection performSelector:selectorToPerformWhenConnectionWasNotStablished withObject:notification.userInfo];
		if ( [Environment sharedInstance].state == TOK_BLUETOOTH_STATE)
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_AVAILABLE object:nil userInfo:[device getDeviceInfo]];

		delegateToCallAboutConnection = nil;
		selectorToPerformWhenConnectionWasStablished = nil;
		selectorToPerformWhenConnectionWasNotStablished = nil;
	}
}

- (void)disconnect {
	[session disconnectPeerFromAllPeers:peerID];
}

- (void)cancelConnection {
	[session cancelConnectToPeer:peerID];
}

- (BOOL)isConnected {
	// Checks if this device is in the Sessions Connected List
	NSArray *peers = [session peersWithConnectionState:GKPeerStateConnected];
	
	BOOL found = NO;
	
	for (NSString *p in peers) {
		if ([p isEqual:peerID]) {
			found = YES;
			break;
		}
	}
	
	return found;
}

- (BOOL)sendData:(NSData *)data error:(NSError **)error {
	return [session sendData:data toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataReliable error:error];
}

- (NSMutableDictionary *)getDeviceInfo{
	return [NSMutableDictionary dictionaryWithObject:self forKey:DEVICE_KEY];
}

- (void)dealloc {
	[session release];
	
	[peerID release];
	[deviceName release];
	
    [super dealloc];
}

@end