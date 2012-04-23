//
//  Bluetooth.h
//  tok
//
//  Created by Sang Won Lee on 10/21/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "Environment.h"
#import "TokClock.h"
//#import "tokAppDelegate.h"


@interface Bluetooth : NSObject<GKSessionDelegate> {

	GKSession * currentSession;
	NSString * mySelfPeerID;
	NSMutableDictionary * peerList;
	NSMutableDictionary * connectedPeerList;
	BOOL master;
	int syncState;		// 1 = Not called by master; 2 = already called by master; 0 = On call right now.
	int TotalPeers;
	int TotalPeersSynced;
	NSMutableArray * connectedPeerArray;
}

@property (retain, nonatomic) NSMutableDictionary * peerList;
@property (retain, nonatomic) NSMutableDictionary * connectedPeerList;
@property int syncState;

+(Bluetooth *) sharedInstance;
-(NSMutableDictionary *) searchPeers;
-(void) connectWithPeer: (NSString *) peerID;
-(void) startSync;
-(void) sendMessage:(NSString *) msgID withDataArray:(NSArray*) Data;
-(void) sendMessage:(NSString *) msgID withData:(NSString*) Data;
-(NSTimeInterval) sendSyncMessage:(NSString *) msgID;
-(void) sendSyncMessage;
-(void) syncDone;
-(void) sendRemoveCoinAt:(GridPoint)point;
-(void) sendAddCoinTo:(GridPoint) destination;
-(void) sendMoveCoinFrom:(GridPoint) source To: (GridPoint) destination;

@end
