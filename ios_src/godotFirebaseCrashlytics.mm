
#import "godotFirebaseCrashlytics.h"
#include "core/reference.h"

#import "Firebase.h"

@implementation GodotFirebaseCrashlytics{
    NSNumber *scriptId;
    NSString *userId;
}


- (bool) isInitialized; {
    return scriptId != nil;
}

- (void) init:(NSDictionary*)config_: (int)script_id_; {
    NSLog(@"Calling init from crashlytics");
    [Fabric with:@[[Crashlytics class]]];

    if (userId != nil) {
        [[Crashlytics sharedInstance] setUserIdentifier: userId];
    }
    scriptId = [NSNumber numberWithInt:script_id_];
}

- (void) setUserId:(NSString *) id_;{
    if (![self isInitialized]){
        userId = id_;
    }else{
        [[Crashlytics sharedInstance] setUserIdentifier: userId];
    }
}




@end
