
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

- (void) crash; {
    if (![self isInitialized]) {return;}
    [[Crashlytics sharedInstance] crash];
}

- (void) crashSetString:(NSString *) ns_value: (NSString *) ns_key; {
    if (![self isInitialized]) {return;}
    [[Crashlytics sharedInstance] setObjectValue: ns_value forKey: ns_key];
}

- (void) crashSetBool:(BOOL) ns_value: (NSString *) ns_key; {
    if (![self isInitialized]) {return;}
    [[Crashlytics sharedInstance] setBoolValue: ns_value forKey: ns_key];
}

- (void) crashSetReal:(float) value: (NSString *) ns_key; {
    if (![self isInitialized]) {return;}
    [[Crashlytics sharedInstance] setFloatValue: value forKey: ns_key];
}

- (void) crashSetInt:(int) value: (NSString *) ns_key; {
    if (![self isInitialized]) {return;}
    [[Crashlytics sharedInstance] setIntValue: value forKey: ns_key];
}

- (void) crashLogException:(NSString *) ns_message; {
    if (![self isInitialized]) {return;}
    [[Crashlytics sharedInstance] logEvent: ns_message];
}

- (void) crashLogError:(NSString *) ns_message; {
    if (![self isInitialized]) {return;}
    [[Crashlytics sharedInstance] logEvent: ns_message];
}

- (void) crashLogWarning:(NSString *) ns_message; {
    if (![self isInitialized]) {return;}
    [[Crashlytics sharedInstance] logEvent: ns_message];
}

@end
