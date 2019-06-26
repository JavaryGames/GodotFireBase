
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

GodotFirebase::GodotFirebase() {
}

GodotFirebase::~GodotFirebase() {
}

void GodotFirebase::initWithJson(const String &json, const int script_id) {
    NSLog(@"Initializing firebase from objective-C...");
    NSLog(@"json = %@", [NSString stringWithCString:json.utf8().get_data() encoding: NSUTF8StringEncoding]);
    
    [FIRApp configure];
    
    config = [NSJSONSerialization JSONObjectWithData:[[NSString stringWithCString:json.utf8().get_data() encoding: NSUTF8StringEncoding]  dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                                                      
    interstitialAd = [GodotFirebaseInterstitialAd alloc];
    [interstitialAd init: config: script_id];
    
    rewardedVideo = [GodotFirebaseRewardedVideo alloc];
    [rewardedVideo init: config: script_id];
    
    analytics = [GodotFirebaseAnalytics alloc];
    [analytics init];
    
    notifications = [GodotFirebaseNotifications alloc];
    [notifications init];
    
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

NSString *ns_string_from_gd_string(String string) {
    return [NSString stringWithCString: string.utf8().get_data() encoding:NSUTF8StringEncoding];
}

void GodotFirebase::notifyInSecsWithTag(const String &message, const int seconds, const String &tag) {
    NSString *title = ns_string_from_gd_string(String(ProjectSettings::get_singleton()->get_setting(String("application/config/name"))));
    [notifications notifyInSecsWithMessage: ns_string_from_gd_string(message)
                                 withTitle: title
                               withSeconds: seconds
                                   withTag: ns_string_from_gd_string(tag)];
}

void GodotFirebase::cancelNotificationWithTag(const String &tag) {
    [notifications cancelNotificationWithTag: ns_string_from_gd_string(tag)];
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
    /*
     Admob related functions to be implemented:
     
    "is_interstitial_loaded", "is_rewarded_video_loaded","load_rewarded_video",
    "load_interstitial"
     
     TODO remove
     */
}
