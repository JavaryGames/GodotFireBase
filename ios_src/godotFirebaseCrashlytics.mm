
#import "godotFirebaseCrashlytics.h"
#include "core/reference.h"

#import "Firebase.h"

@implementation GodotFirebaseCrashlytics

NSNumber *scriptId;
NSString *userId;

- (void) init:(NSDictionary*)config_: (int)script_id_; {
    NSLog(@"Calling init from crashlytics");
    // final Fabric fabric = new Fabric.Builder(activity)
    //     .kits(new Crashlytics(), new CrashlyticsNdk())
    //     .build();
    // Fabric.with(fabric);
    if (userId != null) {
        // Crashlytics.setUserIdentifier(userId);
    }
    scriptId = [NSNumber numberWithInt:script_id_]
}

- (void) setUserId:(NSString *) id_;{
    if (!isInitialized()){
        userId = id_;
    }else{
        // Crashlytics.setUserIdentifier(userId);
    }
}


- (bool) isInitialized {
    return scriptId != nil;
}