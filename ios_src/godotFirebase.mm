
#include "godotFirebase.h"
#import "app_delegate.h"
#include "core/project_settings.h"

#if VERSION_MAJOR == 3
#define CLASS_DB ClassDB
#else
#define CLASS_DB ctTypeDB
#endif

//GADInterstitial *interstitial = NULL;
NSDictionary *config = NULL;
int godot_script_id;

GodotFirebase::GodotFirebase() {
}

GodotFirebase::~GodotFirebase() {
}

void GodotFirebase::initWithJson(const String &json, const int script_id) {
    NSLog(@"Initializing firebase from objective-C...");
    NSLog(@"json = %@", [NSString stringWithCString:json.utf8().get_data() encoding: NSUTF8StringEncoding]);
    
    godot_script_id = script_id;

    [FIRApp configure];

    config = [NSJSONSerialization JSONObjectWithData:[[NSString stringWithCString:json.utf8().get_data() encoding: NSUTF8StringEncoding]  dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                                                      
    interstitialAd = [GodotFirebaseInterstitialAd alloc];
    [interstitialAd init: config: script_id];
    
    rewardedVideo = [GodotFirebaseRewardedVideo alloc];
    [rewardedVideo init: config: script_id];
    
    analytics = [GodotFirebaseAnalytics alloc];
    [analytics init];
    
    notifications = [GodotFirebaseNotifications alloc];
    [notifications initWithCallback: ^(){
        NSLog(@"FireBase initialized. Calling _on_firebase_initialized on GDScript.");
    	Object *obj = ObjectDB::get_instance(script_id);
        Array params = Array();
        params.push_back(String("FireBase successfully initialized."));
    	obj->call_deferred(String("_on_firebase_initialized"), params);
    }];
    
}

void GodotFirebase::load_interstitial() {
    NSLog(@"load_insterstitial from ObjC");
    [interstitialAd load];
    
}

void GodotFirebase::show_interstitial_ad() {
    NSLog(@"show_instertitial_ad from ObjC");
    [interstitialAd show];
    
}

void GodotFirebase::load_rewarded_video() {
    NSLog(@"load rewarded video from ObjC");
    [rewardedVideo load];
}

void GodotFirebase::show_rewarded_video() {
    NSLog(@"show rewarded video from ObjC");
    [rewardedVideo show];
}

void GodotFirebase::setScreenName(const String &screen_name) {
    NSLog(@"set screen name from ObjC");
    [analytics setScreenName: [NSString stringWithCString:screen_name.utf8().get_data() encoding: NSUTF8StringEncoding]];
}

void GodotFirebase::send_events(const String &event_name, const Dictionary& key_values) {
    NSLog(@"send events from ObjC");
    NSLog(@"GodotFirebase::send_events with values size: %lf", key_values.size());
    [analytics send_events:[NSString stringWithCString:event_name.utf8().get_data() encoding: NSUTF8StringEncoding]: key_values];
}

// Notifications ++

NSString *ns_string_from_gd_string(const String &string) {
    NSString * rv = [NSString stringWithCString: string.utf8().get_data() encoding: NSUTF8StringEncoding];
    NSLog(@"Converted GDString into %@", rv);
    return rv;
}

String GodotFirebase::getToken(){
    return String([[notifications getToken] UTF8String]);
}

void GodotFirebase::notifyInSecsWithTag(const String &message, const int seconds, const String &tag) {
    NSString *title = ns_string_from_gd_string(String(ProjectSettings::get_singleton()->get_setting(String("application/config/name"))));
    NSString *ns_message = ns_string_from_gd_string(message);
    NSString *ns_tag = ns_string_from_gd_string(tag);
    NSLog(@"godotFirebase.mm::notifyInSecsWithTag: %@ %@ %@", title, ns_message, ns_tag);
    [notifications notifyInSecondsWithMessage: ns_message
                                 withTitle: title
                               withSeconds: seconds
                                   withTag: ns_tag];
}

void GodotFirebase::cancelNotificationWithTag(const String &tag) {
    [notifications cancelNotificationWithTag: ns_string_from_gd_string(tag)];
}

void GodotFirebase::cancelAllPendingNotificationRequests() {
    [notifications cancelAllPendingNotificationRequests];
}

void GodotFirebase::setRemoteDefaults(const String &jsonData) {
    NSLog(@"godotFirebase.mm::setRemoteDefaults: Not yet implemented");

    // Tell godot that remote config was set
    Object *obj = ObjectDB::get_instance(godot_script_id);
    Array params = Array();
    params.push_back(String("FireBase RemoteConfig defaults set."));
    obj->call_deferred(String("_on_firebase_remoteconfig_defaults_set"), params);
}

void GodotFirebase::crash_set_user_id(const String &id) {
    NSLog(@"godotFirebase.mm::crash_set_user_id: Not yet implemented");
}

// Notifications --

void GodotFirebase::_bind_methods() {
    CLASS_DB::bind_method("initWithJson", &GodotFirebase::initWithJson);
    
    // Admob functions
    CLASS_DB::bind_method("load_interstitial", &GodotFirebase::load_interstitial);
    CLASS_DB::bind_method("show_interstitial_ad", &GodotFirebase::show_interstitial_ad);
    CLASS_DB::bind_method("load_rewarded_video", &GodotFirebase::load_rewarded_video);
    CLASS_DB::bind_method("show_rewarded_video", &GodotFirebase::show_rewarded_video);
    CLASS_DB::bind_method("setScreenName",  &GodotFirebase::setScreenName);
    CLASS_DB::bind_method("send_events", &GodotFirebase::send_events);
    // Notifications
    CLASS_DB::bind_method("notify_in_secs_with_tag", &GodotFirebase::notifyInSecsWithTag);
    CLASS_DB::bind_method("cancel_notification_with_tag", &GodotFirebase::cancelNotificationWithTag);
    CLASS_DB::bind_method("cancel_all_pending_notification_requests", &GodotFirebase::cancelAllPendingNotificationRequests);
    CLASS_DB::bind_method("getToken", &GodotFirebase::getToken);
    //
    CLASS_DB::bind_method("crash_set_user_id", &GodotFirebase::crash_set_user_id);
    // Remote config
    CLASS_DB::bind_method("setRemoteDefaults", &GodotFirebase::setRemoteDefaults);
    /*
     Admob related functions to be implemented:
     
    "is_interstitial_loaded", "is_rewarded_video_loaded","load_rewarded_video",
    "load_interstitial"
     
     TODO remove
     */
}
