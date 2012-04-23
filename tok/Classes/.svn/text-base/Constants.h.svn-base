//
//  Constants.h
//  tok
//
//  Created by Sang Won Lee on 10/8/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#define TOK_DEBUG 
#define NUMBER_OF_BEATS_PER_MEASURE 8
#define NUMBER_OF_MEASURE 2
#define NUMBER_OF_BEATS_PER_ROW NUMBER_OF_BEATS_PER_MEASURE * NUMBER_OF_MEASURE
#define	NUMBER_OF_GRID 17.0
#define	MAX_NUMBER_OF_ROW 4
#define NUMBER_OF_INITIAL_COIN 4

//Accuracy
//Intervals
#define PERFECT (0.2)
#define GOOD (0.4)
#define OKAY (0.7)
#define MISS (0.9)
// Accumulation Index 
#define ACCU_ALPHA1 (0.9)
#define ACCU_ALPHA2 (0.9)
#define ACCU_THRESHOLD (0.3f)
#define ACCU_SLIDER_VELOCITY (0.01f)
// Points
#define PERFECT_SCORE (1)
#define GOOD_SCORE (0.8)
#define OKAY_SCORE (0.5)
#define MISS_SCORE (0.0)
#define NUM_MEASURES_REWARD (2)		//Number of measures to wait for rewards

//Clock
#define CLOCK_DEBOUNCE_START (0.8)
#define NUMBER_OF_TICK_PER_MEASURE 8
#define TIMER_RESOLUTION 0.005
#define METRONOME_WAIT_TIME 1.5
#define INITIAL_COIN_CAPACITY 20

// Ghost Coin
#define GRID_ACTIVITY_FACTOR 2
#define GHOST_INTERVAL (6 * NUMBER_OF_TICK_PER_MEASURE)
#define GHOST_SCORE_THRESHOLD (0.3f)
#define GHOST_SCORE_DECREASE_FACTOR (0.1f)
#define MOVE_GHOST_THRESHOLD GOOD_SCORE

//GUI
#define OFFSET_Y 80
#define ROW_HEIGHT 60
#define SCREEN_HEIGHT 320
#define SCREEN_WIDTH 480
#define SCORE_BAR_POS_Y 9						// For score bars
#define SCORE_BAR_POS_X 179
#define SCORE_BAR_MAX_LENGTH 200			// In pixels
#define INIT_BAR_LEN 2
#define SCORE_HEIGHT 60
#define SCORE_BAR_MARGIN 2
#define	GUI_COIN_DISAPPEAR_Y 350
#define GUI_MESSAGE_DISAPPEAR_TIME 0.5

//FONT 
#define TOK_FONT_1 @"American Typewriter"
#define TOK_FONT_2 @"Marker Felt"

//BLUETOOTH Conenction
#define CONNECTION_TIMEOUT 10

//BLUETOOTH MESSAGE

#define DECLARE_MASTER (@"DMR")
#define SYNC_DECLARE_MASTER (@"DCM")	
#define SYNC_RESPOND_TO_MASTER (@"RTM")	
#define SYNC_RESPOND_TO_SLAVE (@"RTS")	
#define SYNC_MASTER_SYNC (@"MAC")
#define SYNC_SLAVE_SYNC (@"SSK")
#define START_METRONOME_GLOBAL (@"SMG")
#define GAME_MOVE_COIN (@"GMC")
#define GAME_ADD_COIN (@"GAC")
#define GAME_REMOVE_COIN (@"GRC")
#define GAME_POINT_UPDATE (@"GPU")
#define SLAVE_IS_READY (@"SIR")
#define CONF_COIN_SELECTED (@"CCS")

#define NUM_SYNC (11)

//Notification Messages:
#define UPDATE_PEER_LIST (@"UPDATE_PEER_LIST")
#define UPDATE_CONNECTING (@"UPDATE_CONNECTING_PEERS")
#define NOTIFICATION_DEVICE_AVAILABLE @"notif_device_available"
#define NOTIFICATION_DEVICE_UNAVAILABLE @"notif_device_unavailable"
#define NOTIFICATION_DEVICE_CONNECTED @"notif_device_connected"
#define NOTIFICATION_DEVICE_CONNECTION_FAILED @"notif_device_connection_failed"
#define NOTIFICATION_DEVICE_DISCONNECTED @"notif_device_disconnected"

// GAME STATE
#define TOK_BLUETOOTH_STATE 0
#define TOK_CONFIGURATION_STATE 1
#define TOK_PLAY_STATE 2

// string constants
#define DEVICE_KEY @"Device"
#define TOK_GLOBAL_SESSION_ID (@"TOK_BLUETOOTH_SESSION")

//SyncState
#define NOTSYNCED 1
#define SYNCING 0
#define SYNCED 2

#define READY 1
#define NOT_READY 0

// TEMPO RANGE
#define TOK_MINIMUM_TEMPO 60
#define TOK_MAXIMUM_TEMPO 180
#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif

// Metronome option 
#define METRONOME_EVERYBEAT 0
#define METRONOME_EVERYTWOBEAT 1
#define METRONOME_EVERYFOURBEAT 2
#define METRONOME_NONE 3

#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif

typedef enum{
	RED,GREEN,BLUE,PURPLE,GHOST,RED_REWARD,GREEN_REWARD,BLUE_REWARD,PURPLE_REWARD
} Color;
	

struct GridPoint
{
	int row;
	int col;
};
typedef struct GridPoint GridPoint;