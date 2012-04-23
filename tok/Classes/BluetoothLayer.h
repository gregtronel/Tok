//
//  MenuLayer.h
//  tok
//
//  Created by Sang Won Lee on 10/21/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DataHandler.h"
#import "SessionManager.h"

@interface BluetoothLayer : CCLayer {
	CCMenu * myPeerIDMenu;
	NSMutableDictionary * peers;
	int peersCount;
	
	CCMenuItemLabel * nextMenuItem;
}

-(void) initMenu;


@end
