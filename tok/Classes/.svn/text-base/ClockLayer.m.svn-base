//
//  AudioVisualCue.m
//  echobo
//
//  Created by Ajay Srinivasamurthy on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClockLayer.h"


@implementation ClockLayer

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
		
/*
		label = [CCLabelTTF labelWithString:@"" fontName:TOK_FONT_1 fontSize:16];
		label.position =  ccp( 200,300 );
		label.color = ccc3(200,60,150);
*/
		for(int i=0;i<MAX_NUMBER_OF_ROW;i++)
			currValue[i] = 0.0;
	}
	return self;
}

-(void) draw
{
	
	float timePassed = [[TokClock sharedClock].initDate timeIntervalSinceNow];
	
#ifdef TOK_DEBUG
//	 [label setString: [NSString stringWithFormat:@"%.2f\t\t\t%d\t\t\t%.2f\t\t\t%d\t\t\t%d\t\t\t%.5f", -timePassed, [TokClock sharedClock].numTicksSoFar, [TokClock sharedClock].nextTickTime,[TokClock sharedClock].tt1,[TokClock sharedClock].PosOnScore, [TokClock sharedClock].latency]];
#endif

	float width = [Environment sharedInstance].screenWidth;
	float barWidth = width/NUMBER_OF_GRID;
	double posX = (double)(([TokClock sharedClock].PosOnScore)/2)  *barWidth * 2  + barWidth ;

	CGPoint vertices2[] = {
		ccp(posX-barWidth,OFFSET_Y),
		ccp(posX+barWidth,OFFSET_Y),
		ccp(posX+barWidth, SCREEN_HEIGHT ),
		ccp(posX-barWidth, SCREEN_HEIGHT)
	};
	glColor4f(.8f, 0.2f, .2f, .3f);
	CCDrawFilledPoly(vertices2, 4, YES);

	
	// Now to draw the score bars
	float stroke = SCORE_HEIGHT / [Environment sharedInstance].numRow ;
	glLineWidth(SCORE_HEIGHT / [Environment sharedInstance].numRow - SCORE_BAR_MARGIN);
	float j=-0.5;
	for(int i=0;i<MAX_NUMBER_OF_ROW;i++){	
		if (![[Environment sharedInstance] isTheRowConnected: i])
			continue;
		j++;
		switch (i) {
			case RED:
				glColor4f(0.8f, 0.34f, 0.34f, 0.99f);
				break;
			case BLUE:
				glColor4f(0.4f, 0.6f, 0.9f, 0.99f);
				break;
			case GREEN:
				glColor4f(0.6f, 0.8f, 0.2f, 0.99f);
				break;
			case PURPLE:
				glColor4f(0.575f, 0.437f, 0.86f, 0.99f);
				break;
			default:
				break;
		}
		if ( [[Environment sharedInstance] getSharePointsOf:i] > (currValue[i]+ACCU_SLIDER_VELOCITY) ) 
			currValue[i]+=ACCU_SLIDER_VELOCITY;
		if ( [[Environment sharedInstance] getSharePointsOf:i] < (currValue[i]-ACCU_SLIDER_VELOCITY) ) 
			currValue[i]-=ACCU_SLIDER_VELOCITY;
		
		ccDrawLine(ccp(SCORE_BAR_POS_X,SCORE_BAR_POS_Y+j*stroke +SCORE_BAR_MARGIN /2 ),ccp(SCORE_BAR_POS_X+INIT_BAR_LEN+SCORE_BAR_MAX_LENGTH*currValue[i],SCORE_BAR_POS_Y+j*stroke +SCORE_BAR_MARGIN /2));
	}
		
	
	// To draw the accuracy points sliders
	float xlim1 = SCORE_BAR_POS_X;
	float xlim2 = SCORE_BAR_POS_X+[Environment sharedInstance].AccuThreshold*SCORE_BAR_MAX_LENGTH;
	float ylim1 = SCORE_BAR_POS_Y;
	float ylim2 = SCORE_BAR_POS_Y+SCORE_HEIGHT + SCORE_BAR_MARGIN;
	glColor4f(0.0f, 0.0f, 0.0f, 0.99f);		// Black
	glLineWidth(2.0f);
	ccDrawLine(ccp(xlim1,ylim1),ccp(xlim1,ylim2));
	glColor4f(0.99f, 0.7f, 0.05f, 0.99f);		//Gold
	ccDrawLine(ccp(xlim2,ylim1),ccp(xlim2,ylim2));
	
}

void CCDrawFilledPoly(CGPoint *poli, int points, BOOL closePolygon )
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, poli);
	if( closePolygon )
		//	 glDrawArrays(GL_LINE_LOOP, 0, points);
		glDrawArrays(GL_TRIANGLE_FAN, 0, points);
	else
		glDrawArrays(GL_LINE_STRIP, 0, points);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}


- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
