#import "app_delegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface GodotFirebaseCrashlytics : NSObject {
}

- (void) init:(NSDictionary*)config_: (int)script_id_;
- (void) setUserId:(NSString *) id;
- (void) crash;
- (void) crashSetString: (NSString *) ns_value: (NSString *) ns_key;
- (void) crashSetBool: (BOOL) ns_value: (NSString *) ns_key;
- (void) crashSetReal: (float) value: (NSString *) ns_key;
- (void) crashSetInt: (int) value: (NSString *) ns_key;
- (void) crashLogException: (NSString *) ns_value;
- (void) crashLogError: (NSString *) ns_value;
- (void) crashLogWarning: (NSString *) ns_value;

// Private methods

- (bool) isInitialized;

@end
