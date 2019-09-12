
#import "godotFirebaseRemoteConfig.h"
#include "core/reference.h"

#import "Firebase.h"

@implementation GodotFirebaseRemoteConfig

NSNumber *scriptId;
FIRRemoteConfig *remoteConfig;


- (void) init:(NSDictionary*)config_: (int)script_id_; {
    NSLog(@"Calling init from remote config");

    scriptId = [NSNumber numberWithInt:script_id_];

    remoteConfig = [FIRRemoteConfig remoteConfig];
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
    remoteConfig.configSettings = remoteConfigSettings;
    //<-- Setup default // mFirebaseRemoteConfig.setDefaults(R.xml.remote_config_defaults);
    //[self setRemoteDefaults: jsonData] // With R

	[self fetchRemoteConfigs];
}

- (void) fetchRemoteConfigs; {
    NSLog(@"Loading Remote Configs");

    NSNumber *cacheExpiration = [NSNumber numberWithInt:3600];

    if (remoteConfig.configSettings.isDeveloperModeEnabled){
        cacheExpiration = [NSNumber numberWithInt:0];
    }

    [remoteConfig fetchWithExpirationDuration: [cacheExpiration doubleValue]
    completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *_Nullable error){
        if (error){
            NSLog(@"RemoteConfig, Fetch Failed");
            if ([self isInitialized]){
                Object *obj = ObjectDB::get_instance([scriptId intValue]);
                obj->call_deferred(String("_on_firebase_remoteconfig_fetch_failed"), "FireBase RemoteConfig fetch failed.");
            }
        }else{
            NSLog(@"RemoteConfig, Fetch Successed");
            [remoteConfig activate];
            if ([self isInitialized]){
                Object *obj = ObjectDB::get_instance([scriptId intValue]);
                obj->call_deferred(String("_on_firebase_remoteconfig_fetch_successed"), "FireBase RemoteConfig fetch successed.");
            }
        }
    }];    
}


- (NSString *) getRemoteValue:(NSString *)key; {
    if (![self isInitialized]) { return @"NULL"; }

    NSLog(@"Getting Remote config value for: %@", key);
    return [remoteConfig configValueForKey:key].stringValue;
}

- (void) setRemoteDefaultsFile:(NSString *)path; {
    //<-- Load file content
    // [self setRemoteDefaults: jsonData];
}

- (void) setRemoteDefaults:(NSString *)jsonData; {
    //<-- Convert from json to dict
    //[self setDefaults: map];
    if ([self isInitialized]){
        Object *obj = ObjectDB::get_instance([scriptId intValue]);
        obj->call_deferred(String("_on_firebase_remoteconfig_defaults_set"), "FireBase RemoteConfig defaults set.");
    }
}




// Private Methods

- (bool) isInitialized; {
    if (scriptId == nil){
        NSLog(@"RemoteConfig is not initialized.");
        return false;
    }else{
        return true;
    }
}

@end
