//
//  MenuLayer.m
//  tok
//
//  Created by Sang Won Lee on 10/21/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "BluetoothLayer.h"


@implementation BluetoothLayer
// on "init" you need to initialize your instance
-(void) initMenu
{
	peersCount = 0;
	CGSize size = [[CCDirector sharedDirector] winSize];
	[Environment sharedInstance].state = TOK_BLUETOOTH_STATE;

	CCLabelTTF * tutoriallabel = [CCLabelTTF labelWithString:@"Tutorial" fontName:TOK_FONT_1 fontSize:20];
	CCMenuItemLabel * tutoMenuItem = [CCMenuItemLabel itemWithLabel:tutoriallabel 
										   target:[[UIApplication sharedApplication] delegate]
										 selector:@selector(runTutorialScene)];
	
	CCMenu * myMenu3 = [CCMenu menuWithItems:tutoMenuItem,  nil];
	myMenu3.position =  ccp( size.width *1/5 , size.height*1/5 );
	[myMenu3 alignItemsHorizontally];
	[self addChild:myMenu3];	
	
	CCLabelTTF * instruction = [CCLabelTTF labelWithString:@"Looking for local TOK players... Click to connect." fontName:TOK_FONT_1 fontSize:20];
	instruction.position = ccp(size.width/2, size.height*5/7+20);
	instruction.color = ccc3(255,255,0);
	
	CCLabelTTF * welcomeMessage = [CCLabelTTF labelWithString:@"TOK! with your friends.              " fontName:TOK_FONT_1 fontSize:20];
	welcomeMessage.position = ccp(size.width/3, size.height*5/6+10);
	welcomeMessage.color = ccc3(255,255,0);

	[self addChild:welcomeMessage];
	[self addChild:instruction];
	
	// proceed to gridlayer
	CCLabelTTF * label = [CCLabelTTF labelWithString:@"Next" fontName:TOK_FONT_1 fontSize:32];
	nextMenuItem = [CCMenuItemLabel itemWithLabel:label 
										   target:self
										 selector:@selector(proceedToConfigurationScene:)];
	nextMenuItem.isEnabled = NO;

	CCMenu * myMenu2 = [CCMenu menuWithItems:nextMenuItem,  nil];
	myMenu2.position =  ccp( size.width *4/5 , size.height*1/5 );
	[myMenu2 alignItemsHorizontally];
	[self addChild:myMenu2];	

	myPeerIDMenu=[CCMenu menuWithItems:nil];
	myPeerIDMenu.position =  ccp( size.width* 1/2 , size.height/2 );
	[self addChild: myPeerIDMenu];
	[[SessionManager sharedInstance] start];
	
	//[[NSNotificationCenter defaultCenter]
//	 addObserver:self
//	 selector:@selector(updatePeers:)
//	 name:UPDATE_PEER_LIST
//	 object:nil ] ;
//	
//	
//	[[NSNotificationCenter defaultCenter]
//	 addObserver:self
//	 selector:@selector(updateConnectingPeers:)
//	 name:UPDATE_CONNECTING
//	 object:nil ] ;

	peers = [[NSMutableDictionary alloc]init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(deviceStateChanged:) 
												 name:NOTIFICATION_DEVICE_CONNECTED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(deviceStateChanged:) 
												 name:NOTIFICATION_DEVICE_AVAILABLE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(removeDeviceMenu:) 
												 name:NOTIFICATION_DEVICE_UNAVAILABLE object:nil];
	
}

-(void) proceedToConfigurationScene: (CCMenuItemLabel *) sender
{
	NSLog(@"nextPressed");
	[[DataHandler sharedInstance] declareMaster];
	id appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate runConfScene];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) deviceStateChanged : (NSNotification * ) notification{
    Device * device = [[notification userInfo] objectForKey:DEVICE_KEY];
	if( [peers objectForKey:device.peerID] == nil)
		[self addNewDeviceMenu:device];
	else {
		[self updateStatePeer: device];
	}
}

-(void) removeDeviceMenu:(NSNotification*) notification{
    Device * device = [[notification userInfo] objectForKey:DEVICE_KEY];

	if( [peers objectForKey:device.peerID] != nil)
	{
		int menuTag = [[peers objectForKey:device.peerID] intValue];
		NSLog(@"Removing Menu: %@, %@, state:%d, tag:%d", device.peerID, device.deviceName, device.state, menuTag);
		
		[myPeerIDMenu removeChild:[myPeerIDMenu getChildByTag:[[peers objectForKey:device.peerID] intValue]] 
						  cleanup:YES];
		[peers removeObjectForKey:device.peerID];
		[myPeerIDMenu alignItemsVertically];
		if ( [peers count] == 0 ) 
			nextMenuItem.isEnabled = NO;
			
	}
}

-(void) updateStatePeer: (Device *) device{
	int menuTag = [[peers objectForKey:device.peerID] intValue];
	NSLog(@"update state of Menu: %@, %@, state:%d, tag:%d", device.peerID, device.deviceName, device.state, menuTag);
	CCMenuItemLabel * deviceMenu = [myPeerIDMenu getChildByTag:menuTag];
	[deviceMenu setString:[NSString stringWithFormat:@"%@", device.deviceName, device.state]];
	
	if ( device.state == GKPeerStateConnected ) 
	{
		nextMenuItem.isEnabled = YES;
		[[deviceMenu getChildByTag:99] removeFromParentAndCleanup:YES];
		CCSprite * connected = [CCSprite spriteWithFile:@"connected.png"];
		connected.position = ccp(deviceMenu.contentSize.width + connected.contentSize.width/2, deviceMenu.contentSize.height/2);
		[deviceMenu addChild:connected z:0 tag:98];
	}
	else
		if( [deviceMenu getChildByTag:99])
			[[deviceMenu getChildByTag:99] removeFromParentAndCleanup : YES];
}
-(void) addNewDeviceMenu: (Device *) device{
	NSLog(@"adding new Menu: %@, %@, state:%d, tag:%d", device.peerID, device.deviceName, device.state, peersCount);
	CCLabelTTF *labelPeerID = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"%@", device.deviceName] fontName:TOK_FONT_1 fontSize:26];
	CCMenuItemLabel * menuItemLabelPeerID = [CCMenuItemLabel itemWithLabel:labelPeerID target: self selector: @selector(connectWithPeer:) ];
	menuItemLabelPeerID.userData = [NSString stringWithString:device.peerID];
	[myPeerIDMenu addChild: menuItemLabelPeerID z:0 tag:peersCount];
	[peers setObject: [NSNumber numberWithInteger: peersCount] forKey: device.peerID];
	peersCount++;
	[myPeerIDMenu alignItemsVertically];
}



-(void) updateConnectingPeers : (NSNotification*) notification{
    NSDictionary *data = [notification userInfo];
	[[peers objectForKey:[data objectForKey:@"peerID"]] 
	 setString : [NSString stringWithFormat:@"%@ on", [data objectForKey:@"display"]]] ;
}

//-(void) connectWithPeer : (CCMenuItem *) sender{
//	
//	[[peers objectForKey:sender.userData] setString: [NSString stringWithString:@"connecting"]];
//	[[Bluetooth sharedInstance] connectWithPeer:sender.userData];
//}

-(void) connectWithPeer : (CCMenuItemLabel *) sender{
 

	CCSprite * connecting = [CCSprite spriteWithFile:@"connecting.png"];
	connecting.position = ccp(sender.contentSize.width + connecting.contentSize.width/2, sender.contentSize.height/2);
	[sender addChild:connecting z:0 tag:99];
	id action = [CCRepeatForever actionWithAction: [CCRotateBy actionWithDuration:2 angle:360]];

	[connecting runAction: action];
	[[[SessionManager sharedInstance].devicesManager deviceWithID:sender.userData ]connectAndReplyTo:self selector:@selector(deviceConnected) errorSelector:@selector(deviceConnectionFailed:)];
}

-(void) deviceConnected{
		[self showMessageWithTitle:@"BLUETOOTH" message:@"Connected!"];
}

-(void) deviceConnectionFailed:(NSDictionary *) dictionary{
	Device * device  = [dictionary objectForKey:DEVICE_KEY];

	CCNode * deviceMenu = [myPeerIDMenu getChildByTag:
						   [[peers objectForKey: device.peerID] intValue]];
	if ( [deviceMenu getChildByTag:99] ) 
		[[deviceMenu getChildByTag:99] removeFromParentAndCleanup:YES];
	[self showMessageWithTitle:@"BLUETOOTH" message:[dictionary objectForKey:@"error"]];
}


- (void)showMessageWithTitle:(NSString *)title message:(NSString *)msg {
	
	UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:title
															   message:msg
															  delegate:nil
													 cancelButtonTitle:@"OK"
													 otherButtonTitles:nil];
	
	[confirmationView show];
	[confirmationView release];
}

- (void)throwError:(NSString *)message {
//	AudioServicesPlaySystemSound(errorSound);
	[self showMessageWithTitle:NSLocalizedString(@"ERROR_VIEW_TITLE", @"Error dialog title") message:message];

}


- (void) updatePeers:(NSNotification*) notification{
	
	NSLog(@"Finding peers...");
    NSDictionary *data = [notification userInfo];
	NSMutableDictionary * connectedPeers = [data objectForKey:@"connected"];
	NSMutableDictionary * availablePeers = [data objectForKey:@"available"];
	NSMutableArray * peersShouldBeRemoved = [[[NSMutableArray alloc]init]autorelease];
	for (NSString * key in peers)
		if (  [connectedPeers objectForKey:key] == nil&&[availablePeers objectForKey:key] == nil)
			[peersShouldBeRemoved addObject:key];
	
	for(NSString *key in peersShouldBeRemoved){
		[peers removeObjectForKey:key];
		[[peers objectForKey:key] removeFromParentAndCleanup:YES];
	}
	
	for (NSString* key in connectedPeers) {
		if (  [peers objectForKey:key] != nil) // there is an already item
			[[peers objectForKey:key] setString: [NSString stringWithFormat:@"%@ ready", [connectedPeers objectForKey:key]]];
		else{	
			CCLabelTTF *labelPeerID = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"%@ ready",[connectedPeers objectForKey:key]] fontName:TOK_FONT_1 fontSize:32];
			CCMenuItemLabel * menuItemLabelPeerID = [CCMenuItemLabel itemWithLabel:labelPeerID target: self selector: @selector(connectWithPeer:) ];
			menuItemLabelPeerID.userData = [NSString stringWithString:key];
			[myPeerIDMenu addChild: menuItemLabelPeerID];
			NSLog(@"%@,%@", key, [connectedPeers objectForKey:key] );
			[peers setObject:menuItemLabelPeerID forKey:key];
		}
	}
	
	for (NSString* key in availablePeers) {
		if ( [peers objectForKey:key] != nil) // there is an already item
			[[peers objectForKey:key] setString: [NSString stringWithFormat:@"%@ on", [availablePeers objectForKey:key]]];
		else{	
			CCLabelTTF *labelPeerID = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@ on", [availablePeers objectForKey:key]] fontName:TOK_FONT_1 fontSize:32];
			CCMenuItemLabel * menuItemLabelPeerID = [CCMenuItemLabel itemWithLabel:labelPeerID target: self selector: @selector(connectWithPeer:) ];
			menuItemLabelPeerID.userData = [NSString stringWithString:key];
			[myPeerIDMenu addChild: menuItemLabelPeerID];
			NSLog(@"%@,%@", key, [availablePeers objectForKey:key] );
			[peers setObject:menuItemLabelPeerID forKey:key];

		}
	}
	
	[myPeerIDMenu alignItemsVertically];

	
}

-(void) dealloc{
	[peers release];
	[super dealloc];
}
@end
