#import "Accelerometer.h"

@implementation Accelerometer

#define STATE1 YES
#define STATE2 NO
#define kFilteringFactor 0.5

BOOL AIR = NO;
BOOL previousState = STATE1;

BOOL debounceFlag = YES;
float dt = 1.0f / 60.0f;
int c = 0;
double sumX=0, sumY=0, sumZ=0;
double calibX, calibY, calibZ;
double thresh = 0.01;
double count = 0;
int countFrame = 0;


-(id) initWithDelegate : (CCLayer *) layer
{
	self = [super init];

	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( self) {
		calibrated = YES; // by setting calibrated = NO ,it will start calibation
		delegate = layer;
		frameRate = dt;
		numTapped = 0;
		air = NO;
		UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
		accel.delegate = self;
		accel.updateInterval = frameRate;
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(statCalibrate:)
		 name:@"start_calibration"
		 object:nil ] ;
	}
	return self;
	
}

-(void) statCalibrate: (NSNotification *) notification{
	calibrated =NO;
	NSLog(@"calibration will start soon!");
}

- (void) accelerometer: (UIAccelerometer *) accelerometer didAccelerate: (UIAcceleration *) acceleration
{	
	
	countFrame++;
	if (countFrame > 10)
		debounceFlag = YES;
	
//CALIBRATION
	accelX = 0.0;
	accelY = 0.0;
	accelZ = 0.0;
	if ( calibrated == NO ){
		
		if ( fabs(rawAccelX - acceleration.x) >= thresh || fabs(rawAccelY - acceleration.y) >= thresh || fabs(rawAccelZ - acceleration.z) >= thresh )
		{
			// init calibration
			sumX = sumY = sumZ = 0;
			count = 0;
		}
		count++;
		sumX += acceleration.x;
		sumY += acceleration.y;
		sumZ += acceleration.z;
		if (count == 30){
			calibX = sumX/count;
			calibY = sumY/count;
			calibZ = sumZ/count;
			calibrated = YES;
			NSLog(@"%f\t %f\t %f", calibX, calibY, calibZ);
			//startTime = [[NSDate date] timeIntervalSince1970];
			NSLog(@"calibration finished!");
		}
	}
		
	rawAccelX = acceleration.x;
	rawAccelY = acceleration.y;
	rawAccelZ = acceleration.z;
	
	accelX = rawAccelX * kFilteringFactor + accelX * (1.0 - kFilteringFactor);
	accelY = rawAccelY * kFilteringFactor + accelY * (1.0 - kFilteringFactor);
	accelZ = rawAccelZ * kFilteringFactor + accelZ * (1.0 - kFilteringFactor);	
	[self smoothAccelerometerData];
	
}

int k = 0;
int averageCount = 5;
int q = 0;
double arr[5] = {0};
UIAccelerationValue points[480] = {0};	


-(void) smoothAccelerometerData{
	
	double threshold = 0.03;
	
	double sum = 0;
	BOOL currentState = STATE1;
	arr[q] = rawAccelY;
	
	for ( int j=0; j < averageCount; j++)
		sum += arr[j];		
	
	double avg = sum/averageCount;
	if (avg >= calibY + threshold || avg <= calibY - threshold){
		currentState = STATE2;
	}
	if (previousState == STATE2 && currentState == STATE1 && debounceFlag)
	{
		c++;
		debounceFlag = NO;
		countFrame = 0;
		[[TokClock sharedClock] computeAccuracy];
	}
	
	NSString * string2 = [NSString stringWithFormat:@"%i", c];
	previousState = currentState;
	
	q++;
	q=q%averageCount;
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	
	[super dealloc];
}
@end
