#import "app_delegate.h"
#import <FirebaseRemoteConfig/FirebaseRemoteConfig.h>

@interface GodotFirebaseRemoteConfig : NSObject {
}

- (void) init:(NSDictionary*)config_: (int)script_id_;

- (NSString *) getRemoteValue:(NSString *)key;
- (void) setRemoteDefaultsFile:(NSString *)path;
- (void) setRemoteDefaults:(NSString *)jsonData;

// Private methods

- (bool) isInitialized;
- (void) fetchRemoteConfigs;

@end
