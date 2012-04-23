//
//  GridLayer.m
//  tok
//
//  Created by Sang Won Lee on 9/14/11.
//  Copyright Stanford 2011. All rights reserved.
//


// Import the interfaces
#import "GridLayer.h"
#import "GhostCoin.h"

// GridLayer implementation
@implementation GridLayer

double offsetY = OFFSET_Y;
double width = 478;
double height = 320;
double gridHeight = ROW_HEIGHT;



-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void) selectCoin: (Coin  *) coin{
	if ( selectedCoin != coin)
		[selectedCoin unselected];
	selectedCoin = coin;
}

-(void) notifyDisplayed:(NSNotification *) notification
{
	[self display: [[notification userInfo] objectForKey:@"message"] 
		 duration:(ccTime)[[[notification userInfo] objectForKey:@"duration"] floatValue] ];
}

-(void) display:(NSString *) message duration:(ccTime) duration
{
	// add label
	CCLabelTTF * displayMessage = [CCLabelTTF labelWithString:message fontName:TOK_FONT_2 fontSize:64];
	displayMessage.color = ccc3(200,60,150);
	displayMessage.position = ccp(width/2, height/2+30);
	
	[self addChild:displayMessage z:0 tag:99];
	
	id action1 = [CCFadeOut actionWithDuration:GUI_MESSAGE_DISAPPEAR_TIME];  // the action it sounds like you have written above.
	id cleanupAction = [CCCallFunc actionWithTarget:self selector:@selector(cleanupTapMsg)];
	id seq = [CCSequence actions:action1, cleanupAction, nil];
	[displayMessage runAction:seq];
}

-(void)cleanupTapMsg{
	[self removeChildByTag:99 cleanup:TRUE];
}

// on "init" you need to initialize your instance
-(void) initMenu;
{
	self.isTouchEnabled = YES;
	accelerometer = [[Accelerometer alloc] initWithDelegate:self];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(listenCoinAdded:)
	 name:@"coinAdded"
	 object:nil ] ;
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(notifyDisplayed:)
	 name:@"notifyDisplayed"
	 object:nil ] ;
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(listenCoinMoved:)
	 name:@"coinMoved"
	 object:nil ] ;

	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(listenCoinRemoved:)
	 name:@"coinRemoved"
	 object:nil ] ;
	
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(addRewardCoin:)
	 name:@"RewardCoin"
	 object:nil ] ;
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(addGhostCoin:)
	 name:@"AddGhostCoin"
	 object:nil ] ;
	
	
	
	NSArray * array = [NSMutableArray arrayWithObjects: @"redCell480.png", @"greenCell480.png", @"blueCell480.png", @"purpleCell480.png",  nil];
	
	for (int i=0;i<MAX_NUMBER_OF_ROW; i++){
		CCSprite * button1 = nil;
		button1 = [CCSprite spriteWithFile: [array objectAtIndex:i]];
		button1.position = ccp(width/2,offsetY +  gridHeight * (i+0.5));
		if (![[Environment sharedInstance] isTheRowConnected: i])
			[button1 setOpacity:50];
		[self addChild:button1 z:-1];
	}
	
	
	Coins = [CCMenu menuWithItems: nil];
	[Grid sharedInstance].numCoinsInBin = 0;
	for ( int i=0; i< [Environment sharedInstance].numCoins; i++){
		Coin * coin = [[[Coin  alloc] initWithColor:[Environment sharedInstance].myRow delegate:self] autorelease];
		
		coin.position  = ccp(40 + i * 10, 40);
		[Coins addChild:coin z:0];
		[Grid sharedInstance].numCoinsInBin++;
	}
	switch ([Environment sharedInstance].myRow) {
		case RED:
			guidlineRed = 0.7;
			guidlineGreen = 0.2;
			guidlineBlue = 0.2;
			break;
		case PURPLE:
			guidlineRed = 0.5;
			guidlineGreen = 0.1;
			guidlineBlue = 0.5;
			break;
		case GREEN:
			guidlineRed = 0.2;
			guidlineGreen = 0.7;
			guidlineBlue = 0.2;
			break;
		case BLUE:
			guidlineRed = 0.2;
			guidlineGreen = 0.2;
			guidlineBlue = 0.7;
			break;
		default:
			break;
	}

	bin = [CCSprite spriteWithFile: @"bin74.png"];
	bin.position = ccp(87,40);
	
	CCSprite * scoreboard= [CCSprite spriteWithFile: @"scoreboard.png"];
	scoreboard.position = ccp(272,40);
	[self addChild:scoreboard z:-1];

	CCMenuItemImage * quit= [CCMenuItemImage itemFromNormalImage:@"quit.png" selectedImage:@"quit.png" target:self selector:@selector(quitMenu:)];
	CCMenu * quitMenu = [CCMenu menuWithItems:quit, nil];
	quitMenu.position = ccp(427,40);
	[self addChild:quitMenu z:-1];

	
	[self addChild:bin z:-1];
	Coins.position = ccp(0,0);
	[self addChild:Coins z:-1];
	
	CCMenu * ghostMenu=[CCMenu menuWithItems:nil];
	[self addChild:ghostMenu z:-1];
}

-(void)quitMenu: (CCMenuItemSprite *) item{
	NSLog(@"quit the Game");
}
-(void) addGhostCoin: (NSNotification *)notification {
	
	Coin *mycoin = nil;
	
	for(id item in Coins.children)
	{
		
		if ( ![item isKindOfClass:[Coin class]] )
			continue;
		
		Coin * coinItem = (Coin *) item;
		if (coinItem.color == GHOST)
			continue;
		
		if (coinItem.point.row != [Environment sharedInstance].myRow || coinItem.isInBin)
			continue;
		
		mycoin = coinItem;
		break;
			
	}
	
	if  (!mycoin ) 
		return;
	// Remove the coin there
	GridPoint pt = mycoin.point;
	[[Grid sharedInstance] remove:(Coin *) mycoin broadcast:YES toBin:NO];
	[mycoin removeFromParentAndCleanup:YES];
	// Add the ghost and broadcast
	GhostCoin * gcoin = [[[GhostCoin  alloc] initWithColor:GHOST delegate:self] autorelease];
	CGPoint quantizedLocation =[self convertGridToLocation:pt];
	gcoin.position = quantizedLocation;
	[Coins addChild:gcoin z:0];
	gcoin.isInBin = YES;
	
	[self display:@"Errrrr!" duration:GUI_MESSAGE_DISAPPEAR_TIME];
	[gcoin moveCoinTo: quantizedLocation Until: [NSDate date] destroy:NO];
	
	[[Grid sharedInstance] move: gcoin To:pt broadcast:YES];
}


- (void) moveCoinToBin{
#ifdef TOK_DEBUG	
	NSLog(@"hey, let's move this coin to bin");
#endif
	NSDate * now = [NSDate date];
	[selectedCoin moveCoinTo: ccp(40 + [Grid sharedInstance].numCoinsInBin * 10,40) Until: now destroy:NO];
	[[Grid sharedInstance] remove:selectedCoin broadcast:YES toBin:YES];
	[self deselectCoin];
	[[Grid sharedInstance] printGrid];	

	
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
	if (!selectedCoin)
		return;
	
	//decide whether to draw guidline 
	[self updateGuidLine:touch];
}

-(void) updateGuidLine:(UITouch *)touch{
	CGPoint location = [self convertTouchToNodeSpace: touch];
	GridPoint point = [self convertLocationToGrid: location];
	
	if ( point.row <0 || ![[Environment sharedInstance] isTheRowConnected: point.row])
	{ // if touch event go out of grid, let's not draw it. 
		destinationSelected = NO;
	}else 
	{
		destinationSelected = YES;
		guidelineLocation =[self convertGridToLocation:point];
	}
}

-(void) draw{

	// draw guidlines 
	if ( destinationSelected ) 
	{
		glColor4f(guidlineRed,guidlineGreen,guidlineBlue,1.0);  
		glLineWidth(2.0f);
		ccDrawLine(ccp(0.0, guidelineLocation.y ), ccp(480.0, guidelineLocation.y));	
		ccDrawLine(ccp(guidelineLocation.x,offsetY), ccp(guidelineLocation.x,320));
	}
	
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (!selectedCoin)
		return YES;
	
	[self updateGuidLine:touch];

    return YES;
}

- (CGPoint)convertGridToLocation:(GridPoint) point{
	
	double newX = (double)point.col * (width/NUMBER_OF_GRID);
	double newY = point.row * gridHeight;
	newY += offsetY;
	newY += (height-offsetY)/4.0/2.0;
	newX += (width/NUMBER_OF_GRID) +1;
	CGPoint convertedLocation = CGPointMake(newX, newY);
	return convertedLocation;
	
}

- (GridPoint)convertLocationToGrid: (CGPoint) location{

	GridPoint point ;

	point.col = min(max(round(location.x / (width/NUMBER_OF_GRID) - 1),0), NUMBER_OF_BEATS_PER_ROW - 1);
	point.row = min(round((location.y - offsetY)/ ((height-offsetY)/4.0)-0.5),MAX_NUMBER_OF_ROW - 1);
	
	return point;
}


- (BOOL)containsTouchLocation:(CGPoint) p withNode:(CCNode *) node
{
	CGSize s = [node contentSize];
	CGRect r = CGRectMake(node.positionInPixels.x - s.width/2,node.positionInPixels.y - s.height/2, s.width, s.height);
	return CGRectContainsPoint(r, p);
}

-(void) deselectCoin{
	[selectedCoin unselected];
	selectedCoin = nil;
	return;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

	if (!selectedCoin)
		return;
	
	destinationSelected = NO;
	CGPoint location = [self convertTouchToNodeSpace: touch];

	// check if bin is selected
	if ([self containsTouchLocation: location withNode: bin])
		if ( !selectedCoin.isInBin )  
			return [self moveCoinToBin];
							
	GridPoint point = [self convertLocationToGrid: location];

	// check if the coin is on screen
	if ( point.row <0 || ![[Environment sharedInstance] isTheRowConnected: point.row])
		return [self deselectCoin];

	//	if the gridPoint is empty
	if([[Grid sharedInstance] isCoinThereAt:point])
	{
#ifdef TOK_DEBUG		
		NSLog(@"ERROR:uhoh, you can't move it. it's taken(%d, %d)", point.row,point.col);
#endif
		return [self deselectCoin];
	}
	
	CGPoint quantizedLocation =[self convertGridToLocation:point];
	
	NSDate * now = [NSDate date];
	[selectedCoin moveCoinTo: quantizedLocation Until: now destroy:NO];
	[[Grid sharedInstance] move:selectedCoin To:point broadcast:YES];
	[self deselectCoin];
	[[Grid sharedInstance] printGrid];
}


- (void)listenCoinAdded:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
	GridPoint point;
	point.row = [[data objectForKey:@"row"] intValue];
	point.col = [[data objectForKey:@"col"] intValue];
	Color color = [[data objectForKey:@"color"] intValue];
	[self addNewCoinToGrid:point Until:nil withColor:color];
}

- (void)listenCoinMoved:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
	GridPoint source;
	GridPoint destination;
	source.row = [[data objectForKey:@"sourceRow"] intValue];
	source.col = [[data objectForKey:@"sourceCol"] intValue];
	destination.row = [[data objectForKey:@"destRow"] intValue];
	destination.col = [[data objectForKey:@"destCol"] intValue];
	[[Grid sharedInstance] getCoinAt:source].gScore = [[data objectForKey:@"score"] floatValue];
	CGPoint quantizedLocation =[self convertGridToLocation:destination];
	
	NSDate * now = [NSDate date];
	[[[Grid sharedInstance] getCoinAt:source] moveCoinTo: quantizedLocation Until: now destroy:NO];
	[[Grid sharedInstance] move:[[Grid sharedInstance] getCoinAt:source] To:destination broadcast:NO];	
}


- (void)listenCoinRemoved:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
	GridPoint point;
	point.row = [[data objectForKey:@"row"] intValue];
	point.col = [[data objectForKey:@"col"] intValue];
	BOOL fadeOut = [[data objectForKey:@"fadeOut"] boolValue];
	Coin * coin = [[Grid sharedInstance] getCoinAt:point];
	[[Grid sharedInstance] remove:coin broadcast:NO toBin:NO];

		
	CGPoint quantizedLocation =[self convertGridToLocation:coin.point];
	if (!fadeOut)
		quantizedLocation.y = GUI_COIN_DISAPPEAR_Y;
	NSDate * now = [NSDate date];
	[coin moveCoinTo: quantizedLocation Until: now destroy:YES];
}


-(void) addNewCoinToGrid:(GridPoint) location Until: (NSDate *) date withColor:(Color) color{
	CGPoint quantizedLocation =[self convertGridToLocation:location];
	Coin * coin;
	CGPoint startingLocation;
	if ( color == GHOST){
		coin = [[[GhostCoin  alloc] initWithColor:color delegate:self] autorelease];
		startingLocation = quantizedLocation;
		[self display:@"Errrr!" duration:GUI_MESSAGE_DISAPPEAR_TIME];
	}
	else{
		coin = [[[Coin  alloc] initWithColor:color delegate:self] autorelease];
		startingLocation = ccp(quantizedLocation.x,GUI_COIN_DISAPPEAR_Y);
	}

	coin.position  = startingLocation;
	[Coins addChild:coin z:0];
	
	NSDate * now = [NSDate date];
	[coin moveCoinTo: quantizedLocation Until: now destroy:NO];
	[[Grid sharedInstance] put:coin At:location fromBin:NO];
	
}

-(void) addRewardCoin:(NSNotification *)notification {
	Coin * coin = [[[Coin  alloc] initWithColor: [self convertRewardColor:[Environment sharedInstance].myRow] delegate:self] autorelease];
	[self display:@"Extra coin earned!" duration:GUI_MESSAGE_DISAPPEAR_TIME];
	coin.position  = ccp(50, 40);
	[Coins addChild:coin z:0];
	coin.isInBin = YES;
}

-(Color) convertRewardColor:(int) colorInt{
	switch (colorInt) {
		case RED:
			return RED_REWARD;
		case BLUE:
			return BLUE_REWARD;
		case GREEN:
			return GREEN_REWARD;
		case PURPLE:
			return PURPLE_REWARD;
		default:
			break;
	}
	return GHOST;
}

-(void) addNewCoinToBin:(GridPoint) location Until: (NSDate *) date withColor:(Color) color{
	// prototype TODO : just to replace with init part
	
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[accelerometer release];
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
