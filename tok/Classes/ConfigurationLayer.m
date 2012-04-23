//
//  ConfigurationLayer.m
//  tok
//
//  Created by Sang Won Lee on 11/29/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "ConfigurationLayer.h"
#import "Environment.h"
#import "Coin.h"
#import "DataHandler.h"
#import "RadioButton.h"

@implementation ConfigurationLayer

-(id) init
{
	
	self = [super init];
	if (self){
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// proceed to gridlayer
		CCLabelTTF * label = [CCLabelTTF labelWithString:@"Choose your color:" fontName:TOK_FONT_1 fontSize:20];
		label.position =  ccp( 120 , 270 );
		[self addChild:label];
		
		coins = [CCMenu menuWithItems: nil];
		
		for ( int i=0; i<MAX_NUMBER_OF_ROW; i++){
			Coin * coin = [[[Coin  alloc] initWithColor:i delegate:self] autorelease];
			[coins addChild:coin z:0 tag:i];
		}
		coins.position = ccp(160, 220);
		[coins alignItemsHorizontallyWithPadding:10];
		[self addChild:coins];
		
				CCLabelTTF * label2 = [CCLabelTTF labelWithString:@"Choose your metronome:" fontName:TOK_FONT_1 fontSize:20];
		label2.position =  ccp(150 , 170);
		[self addChild:label2];
		

		RadioButton * button1 = [RadioButton radioButtonWithTarget:self selector:@selector(metronomeButtonTapped:) WithLabel:@"Every beat"];
		RadioButton * button2 = [RadioButton radioButtonWithTarget:self selector:@selector(metronomeButtonTapped:) WithLabel:@"Every 2 beats"];
		RadioButton * button3 = [RadioButton radioButtonWithTarget:self selector:@selector(metronomeButtonTapped:) WithLabel:@"Every 4 beats"];
		RadioButton * button4 = [RadioButton radioButtonWithTarget:self selector:@selector(metronomeButtonTapped:) WithLabel:@"No Metronome"];
		button1.userInt = METRONOME_EVERYBEAT;
		button2.userInt = METRONOME_EVERYTWOBEAT;
		button3.userInt = METRONOME_EVERYFOURBEAT;
		button4.userInt = METRONOME_NONE;
		button1.contentSize = button3.contentSize;
		button2.contentSize = button3.contentSize;
		button4.contentSize = button3.contentSize;
		[button1 selected];
		
		CCMenu *toggleMenu = [CCMenu menuWithItems:button1, button2, button3,button4, nil];
		[toggleMenu alignItemsVerticallyWithPadding:5];
		toggleMenu.position = ccp(120, 100);
		[self addChild:toggleMenu z:0 tag:99];
		
		if ( [DataHandler sharedInstance].master){
			bpmLabel = [CCLabelTTF labelWithString:@"Set BPM" fontName:TOK_FONT_1 fontSize:20];
			bpmLabel.position =  ccp( 360 , 150 );
			[self addChild:bpmLabel];
			
			slider = [CCSlider sliderWithBackgroundFile:@"sliderBG.png" thumbFile:@"sliderThumb.png"];
			
			[slider addObserver:self forKeyPath:@"value" options: NSKeyValueObservingOptionNew  context: nil];
			slider.position = ccp( 360 , 130);
			
			[self addChild:slider];

			CCLabelTTF * ghostLabel = [CCLabelTTF labelWithString:@"Enable Ghost:" fontName:TOK_FONT_1 fontSize:20];
			ghostLabel.position =  ccp( 360 , 270 );
			[self addChild:ghostLabel];
			
			CCMenu * Ghost = [CCMenu menuWithItems: nil];
			
			CCMenuItemImage * ghostItem = [CCMenuItemImage itemFromNormalImage:@"ghost.png" 
																  selectedImage:@"ghost.png" ] ;
			CCMenuItemImage * noGhostItem = [CCMenuItemImage itemFromNormalImage:@"coinBlackSelected.png" 
																	selectedImage:@"coinBlackSelected.png" ] ;
			CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self 
																   selector:@selector(enableGhost:) items:noGhostItem,ghostItem, nil];
			CCMenu *ghostMenu = [CCMenu menuWithItems:toggleItem, nil];
			ghostMenu.position = ccp(360, 220);
			[self addChild:ghostMenu];
		}
		
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(coinSelectedByPeer:) 
													 name:@"conf_CoinSelected" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(readyToProceed:) 
													 name:@"confReadyToProceed" object:nil];
		
	}
	return self;
}

-(void) enableGhost: (id) sender{
#ifdef TOK_DEBUG
	NSLog(@"GhostSelected:");
#endif
	
	[Environment sharedInstance].ghostEnabled = ![Environment sharedInstance].ghostEnabled; 

}

-(void) metronomeButtonTapped: (RadioButton *) sender{
#ifdef TOK_DEBUG
	NSLog(@"ButtonTapped:%d", sender.userInt);
#endif
	
	[Environment sharedInstance].metronomeOption = sender.userInt;
	
}

-(void) readyToProceed : (NSNotification *) notification{
	[readyMenuItem.label setString: @"Start"];
	readyMenuItem.isEnabled = YES;
}

-(void) coinSelectedByPeer : (NSNotification *) notification{
	int color = [[[notification userInfo] objectForKey:@"color"] intValue];
	
	[[coins getChildByTag:color] displayMsg:@"Taken" fadeOut:NO];
	((Coin *)[coins getChildByTag:color]).isEnabled = NO;	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass: [CCSlider class] ] && [keyPath isEqualToString: @"value"])
    {
        NSNumber *valueObject = [change objectForKey: NSKeyValueChangeNewKey];
        float value = [valueObject floatValue];
    
		[Environment sharedInstance].bpm = TOK_MINIMUM_TEMPO + (TOK_MAXIMUM_TEMPO - TOK_MINIMUM_TEMPO) * value;
        // Change value of label.
        bpmLabel.string = [NSString stringWithFormat:@"Set BPM(%d)", [Environment sharedInstance].bpm];	
    }
}

-(void) selectCoin:(Coin *) coin{
#ifdef TOK_DEBUG
	NSLog(@"Selected Color : %d", coin.color); 
#endif
	[coin displayMsg:@"TOK!" fadeOut:NO];
	[[DataHandler sharedInstance] sendCoinSelected:coin.color];
	[Environment sharedInstance].myRow = coin.color;
	[[Environment sharedInstance] setConnected:coin.color With : YES];
	
	for (int i=0; i< [coins.children count]; i++)
	{
		if ( !((Coin *)[coins getChildByTag:i]).isEnabled )
			continue;
		if ( i != coin.color)
			[[coins getChildByTag:i] unselected];
		((Coin *)[coins getChildByTag:i]).isEnabled = NO;
		
	}
	
	
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCLabelTTF * readyWait = [CCLabelTTF labelWithString:@"Ready" fontName:TOK_FONT_1 fontSize:32];
	
	if ([DataHandler sharedInstance].master)
	{

		readyMenuItem = [CCMenuItemLabel itemWithLabel:readyWait 
												target:self
											  selector:@selector(proceedToPlayScene:)];
//		if ( [Environment sharedInstance].numRow == 
		readyWait.string = @"Waiting...";
		readyMenuItem.isEnabled = NO;
	}
	else{
		readyMenuItem = [CCMenuItemLabel itemWithLabel:readyWait 
												target:[DataHandler sharedInstance]
											  selector:@selector(sendSlaveIsReady)];
	}
		CCMenu * myMenu2 = [CCMenu menuWithItems:readyMenuItem,  nil];
	myMenu2.position =  ccp( 360 , 60 );
	[self addChild:myMenu2];	
	
}

-(void) proceedToPlayScene: (CCMenuItemLabel *) item{
	[[DataHandler sharedInstance] startSync];
	id appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate runPlayScene];
	[slider removeObserver:self forKeyPath:@"value"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) dealloc{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
