
#import "godotFirebaseAnalytics.h"
#include "core/reference.h"

#import "Firebase.h"

@implementation GodotFirebaseAnalytics

- (void) init:(NSDictionary*)config_: (int)script_id_; {
    NSLog(@"Calling init from analytics");
}

- (void) setScreenName: (NSString *) screen_name; {
    NSLog(@"Set screen name to %@", screen_name);
    
    [FIRAnalytics setScreenName:screen_name screenClass:nil];
    
}

- (void) send_events: (NSString *) event_name: (Dictionary *)  key_values; {
    NSLog(@"Sending analytics event");
    NSLog(@"Name: %@", event_name);
    
    // Convert godot dictionary to objc nsdictionary
    NSMutableDictionary *event_parameters = [NSMutableDictionary new];
    List<Variant> keys;
    key_values->get_key_list(&keys);
    for (List<Variant>::Element *E = keys.front(); E; E = E->next()) {
        String key = E->get();
        Variant *value = key_values->getptr(key);

        if (value->get_type_name(value->get_type()) == "int"){
            int int_value = (int)*value;
            event_parameters[[NSString stringWithCString:key.utf8().get_data() encoding: NSUTF8StringEncoding]] = [NSNumber numberWithInt:int_value];
        } else {
            String string_value = (String)*value;
            event_parameters[[NSString stringWithCString:key.utf8().get_data() encoding: NSUTF8StringEncoding]] = [NSString stringWithCString:string_value.utf8().get_data() encoding: NSUTF8StringEncoding];
        }

    }
    
    // send data to firebase
    [FIRAnalytics logEventWithName:event_name parameters:event_parameters];
}


@end
