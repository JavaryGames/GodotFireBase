#import "app_delegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface GodotFirebaseCrashlytics : NSObject {
}

- (void) init;
- (void) setUserId:(NSString *) id;
// Method headers here

// Private methods

- (bool) isInitialized;

@end
