//
//  Coin.m
//  tok
//
//  Created by Sang Won Lee on 10/8/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "Coin.h"


@implementation Coin
@synthesize moving;
@synthesize isInBin;
@synthesize point;
@synthesize isTapped;
@synthesize color;
@synthesize isGhost;
@synthesize gScore;

// using menuItem like toggle switch
-(void) selected{
	if (moving)
		return;
	[self cleanupCoinMsg];
	selected = !selected;

	if (selected){
		if( !isInBin)
			if(![[Environment sharedInstance] isThisMyRow : self.point.row])
			{
#ifdef TOK_DEBUG
				NSLog(@"ERROR:you can't move coins not in your row(%d, %d)", self.point.row,self.point.col);
#endif				
				selected = !selected;
				return;
			}
		[super selected];
	}
	else
		[super unselected];
}

// We don't know if the touch go out of the coin or if the touch event ended within coin 
// if activaate is executed it means that it ended within coin so I will mark selected = true
// so for now suppose it is unselected. 
-(void) unselected{
	
	selected = !selected; 
	[super unselected];
	[self cleanupCoinMsg];
}

-(void) activate{
	if(!selected){ // if it's true , it means that the user is deselecting the coin( when s/he wants to cancel the move. 
		[super activate]; 
		[super selected];
	}
	selected = !selected; // if activated is executed, it means touch event ended within the coin so I would keep it selected. 
}

-(id) initWithColor: (Color)colorSelected delegate:(CCLayer *) layer{
	NSString * coinFileName;
	NSString * coinSelectedFileName;
	color = colorSelected;
	isGhost= NO;
	gScore = 1;

	switch (color) {
		case RED:
			coinFileName= [NSString stringWithString:@"coinRed.png"];
			coinSelectedFileName= [NSString stringWithString:@"coinRedSelected.png"];
			break;

		case BLUE:
			coinFileName= [NSString stringWithString:@"coinBlue.png"];
			coinSelectedFileName= [NSString stringWithString:@"coinBlueSelected.png"];
			break;

		case GREEN:
			coinFileName= [NSString stringWithString:@"coinGreen.png"];
			coinSelectedFileName= [NSString stringWithString:@"coinGreenSelected.png"];
			break;

		case PURPLE:
			coinFileName= [NSString stringWithString:@"coinPurple.png"];
			coinSelectedFileName= [NSString stringWithString:@"coinPurpleSelected.png"];
			break;
		case GHOST:
			coinFileName= [NSString stringWithString:@"ghost.png"];
			coinSelectedFileName= [NSString stringWithString:@"ghost.png"];
			break;
		case RED_REWARD:
			coinFileName= [NSString stringWithString:@"coinRedReward.png"];
			coinSelectedFileName= [NSString stringWithString:@"coinRedRewardSelected.png"];
			break;	
		case BLUE_REWARD:
			coinFileName= [NSString stringWithString:@"coinBlueReward.png"];
			coinSelectedFileName= [NSString stringWithString:@"coinBlueRewardSelected.png"];
			break;	
		case GREEN_REWARD:
			coinFileName= [NSString stringWithString:@"coinGreenReward.png"];
			coinSelectedFileName= [NSString stringWithString:@"coinGreenRewardSelected.png"];
			break;	
		case PURPLE_REWARD:
			coinFileName= [NSString stringWithString:@"coinPurpleReward.png"];
			coinSelectedFileName= [NSString stringWithString:@"coinPurpleRewardSelected.png"];
			break;	
		default:
			break;
	}
	CCSprite * normalSprite = [CCSprite spriteWithFile: coinFileName];
	CCSprite * selectedSprite = [CCSprite spriteWithFile: coinSelectedFileName];
	CCSprite * disabledSprite = [CCSprite spriteWithFile:coinFileName];
	delegate = layer;
	self = [super initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite 
								target:delegate selector:@selector(selectCoin:)];
	selected = NO;
	isInBin = YES;
	isTapped = NO;
	coinMessage = [CCLabelTTF labelWithString:@"" fontName:TOK_FONT_2 fontSize:16];
	coinMessage.position = ccp(	self.contentSize.width/2,	self.contentSize.height/2);
	coinMessage.color = ccc3(0,0,0);
	
	[self addChild:coinMessage z:0 tag:99];
	point.row = -1;
	point.col = -1;
	return self;
}


-(void) displayMsg : (NSString *) msg fadeOut:(BOOL) option{
	[coinMessage setString: msg];
	
	if (option){
		id action1 = [CCFadeOut actionWithDuration:0.5];  // the action it sounds like you have written above.
		id cleanupAction = [CCCallFunc actionWithTarget:self selector:@selector(cleanupCoinMsg)];
		id seq = [CCSequence actions:action1, cleanupAction, nil];
		[coinMessage runAction:seq];
	}
}


-(void) cleanupCoinMsg {
	[coinMessage setString:@""];
}


-(void) cleanup: (id) sender{
	[self removeFromParentAndCleanup:NO];
}

-(void) setOpacityBack:(id) sender{
	[self setOpacity:(GLubyte)(gScore * 255.0)];
#ifdef TOK_DEBUG
	NSLog(@"Opacity:%d, %d", self.opacity, self.gScore);
#endif
	moving = NO;
}



-(void) moveCoinTo:(CGPoint)location Until:(NSDate *)date destroy:(BOOL) destroy{
#ifdef TOK_DEBUG
	NSLog(@"plain moveCoinTo reached %p(isGhost:%d)", self, isGhost);
#endif
	CCMoveTo * action1 = [CCMoveTo actionWithDuration:1 position:location];    
	[self setOpacity: 100];
	moving = YES;
	id cleanupAction, seq, setOpacityBack;
	if ( destroy)
	{
		cleanupAction = [CCCallFunc actionWithTarget:self selector:@selector(cleanup:)];
		seq = [CCSequence actions:action1, cleanupAction, nil];
	}
	else {
		setOpacityBack = [CCCallFunc actionWithTarget:self selector:@selector(setOpacityBack:)]; 
		seq = [CCSequence actions:action1, setOpacityBack, nil];
	}
	
	[self runAction:seq];
	
	
	
}
/*
-(BOOL)isMine{
	return (point.row == [Environment sharedInstance].myRow);
}*/

- (CGPoint)convertGridToLocation:(GridPoint) cpoint{
	double offsetY = OFFSET_Y;
	double width = 478;
	double height = 320;
	double gridHeight = ROW_HEIGHT;
	double newX = (double)cpoint.col * (width/NUMBER_OF_GRID);
	double newY = cpoint.row * gridHeight;
	newY += offsetY;
	newY += (height-offsetY)/4.0/2.0;
	newX += (width/NUMBER_OF_GRID) +1;
	CGPoint convertedLocation = CGPointMake(newX, newY);
	return convertedLocation;
	
}
@end
