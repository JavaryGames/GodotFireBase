#import "app_delegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface GodotFirebaseCrashlytics : NSObject {
}

- (void) init:(NSDictionary*)config_: (int)script_id_;
- (void) setUserId:(NSString *) id;
// Method headers here

// Private methods

- (bool) isInitialized;

@end
