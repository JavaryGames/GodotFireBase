
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
    //NSLog(@"json = %@", [NSString stringWithCString:json.utf8().get_data() encoding: NSUTF8StringEncoding]);
    
    godot_script_id = script_id;

    [FIRApp configure];

    config = [NSJSONSerialization JSONObjectWithData:[[NSString stringWithCString:json.utf8().get_data() encoding: NSUTF8StringEncoding]  dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

    //NSLog(@"config = %@", config); 

    crashlytics = [GodotFirebaseCrashlytics alloc];
    [crashlytics init: config: script_id];

    analytics = [GodotFirebaseAnalytics alloc];
    [analytics init];

    remoteConfig = [GodotFirebaseRemoteConfig alloc];
    [remoteConfig init: config: script_id];

    interstitialAd = [GodotFirebaseInterstitialAd alloc];
    [interstitialAd init: config: script_id];
    
    rewardedVideo = [GodotFirebaseRewardedVideo alloc];
    [rewardedVideo init: config: script_id];

    if ([[config valueForKey:@"Notification"] boolValue]) {
        notifications = [GodotFirebaseNotifications alloc];
        [notifications initWithCallback: ^(){
            NSLog(@"FireBase notifications initialized.");
        }];
    }

    NSLog(@"FireBase initialized. Calling _on_firebase_initialized on GDScript.");
    Object *obj = ObjectDB::get_instance(script_id);
    Array params = Array();
    params.push_back(String("FireBase successfully initialized."));
    obj->call_deferred(String("_on_firebase_initialized"), params);
    
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

//Notifications++

NSString *ns_string_from_gd_string(const String &string) {
    NSString * rv = [NSString stringWithCString: string.utf8().get_data() encoding: NSUTF8StringEncoding];
    // NSLog(@"Converted GDString into %@", rv);
    return rv;
}

String GodotFirebase::getToken(){
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"Remote instance ID token: %@", result.token);
            Object *gdscript_object = ObjectDB::get_instance(godot_script_id);
            gdscript_object->call_deferred("_on_receive_token", [@"FireBase" UTF8String]);
        }
    }];
    return "Please check the token on the callback...";
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

void GodotFirebase::notifyWithBadgeMM() {
    NSLog(@"godotFirebase.mm::notifyWithBadge");
    [notifications notifyWithBadge];
}

void GodotFirebase::clearNotifyBadgeMM() {
    NSLog(@"godotFirebase.mm::clearNotifyBadge");
    [notifications clearNotifyBadge];
}

void GodotFirebase::cancelNotificationWithTag(const String &tag) {
    [notifications cancelNotificationWithTag: ns_string_from_gd_string(tag)];
}

void GodotFirebase::cancelAllPendingNotificationRequests() {
    [notifications cancelAllPendingNotificationRequests];
}

//Notifications--

//RemoteConfig++

String GodotFirebase::getRemoteValue(const String &key) {
    NSLog(@"godotFirebase.mm::getRemoteValue: Implementing");
    if (key.length() <= 0) {
        NSLog(@"getting remote config: key not provided, returning null");
        return "NULL";
    }
    return [[remoteConfig getRemoteValue: [NSString stringWithCString: key.utf8().get_data()]] UTF8String];
}

void GodotFirebase::setRemoteDefaultsFile(const String &path) {
    NSLog(@"godotFirebase.mm::setRemoteDefaultsFile: Implementing");
    if (path.length() <= 0) {
        NSLog(@"File not provided for remote config");
        return;
    }
    [remoteConfig setRemoteDefaultsFile: [NSString stringWithCString: path.utf8().get_data()]];
}

void GodotFirebase::setRemoteDefaults(const String &jsonData) {
    NSLog(@"godotFirebase.mm::setRemoteDefaults: Implementing");
    if (jsonData.length() <= 0) {
        NSLog(@"No defaults were provided.");
        return;
    }
    [remoteConfig setRemoteDefaults: [NSString stringWithCString: jsonData.utf8().get_data()]];
}

//RemoteConfig--

//Crashlytics++

void GodotFirebase::crash() {
    NSLog(@"godotFirebase.mm::crash: Testing");//<--
    [crashlytics crash];
}

void GodotFirebase::crash_set_string(const String &key, const String &value) {
    NSLog(@"godotFirebase.mm::crash_set_string: Testing");//<--
    NSString* ns_key = [NSString stringWithCString: key.utf8().get_data()];
    NSString* ns_value = [NSString stringWithCString: value.utf8().get_data()];
    [crashlytics crashSetString: ns_value: ns_key];
}

void GodotFirebase::crash_set_bool(const String &key, const bool value) {
    NSLog(@"godotFirebase.mm::crash_set_bool: Testing");//<--
    NSString* ns_key = [NSString stringWithCString: key.utf8().get_data()];
    BOOL ns_value = value ? YES : NO;
    [crashlytics crashSetBool: ns_value: ns_key];
}

void GodotFirebase::crash_set_real(const String &key, const float value) {
    NSLog(@"godotFirebase.mm::crash_set_real: Testing");//<--
    NSString* ns_key = [NSString stringWithCString: key.utf8().get_data()];
    [crashlytics crashSetReal: value: ns_key];
}

void GodotFirebase::crash_set_int(const String &key, const int value) {
    NSLog(@"godotFirebase.mm::crash_set_int: Testing");//<--
    NSString* ns_key = [NSString stringWithCString: key.utf8().get_data()];
    [crashlytics crashSetInt: value: ns_key];
}

void GodotFirebase::crash_set_user_id(const String &id) {
    NSLog(@"godotFirebase.mm::crash_set_user_id: Testing");//<--
    NSString* ns_id = [NSString stringWithCString: id.utf8().get_data()];
    [crashlytics setUserId: ns_id];
}

void GodotFirebase::crash_log_exception(const String &message) {
    NSLog(@"godotFirebase.mm::crash_log_exception: Testing");//<--
    NSString* ns_message = [NSString stringWithCString: message.utf8().get_data()];
    [crashlytics crashLogException: ns_message];
}

void GodotFirebase::crash_log_error(const String &message) {
    NSLog(@"godotFirebase.mm::crash_log_error: Testing");//<--
    NSString* ns_message = [NSString stringWithCString: message.utf8().get_data()];
    [crashlytics crashLogError: ns_message];
}

void GodotFirebase::crash_log_warning(const String &message) {
    NSLog(@"godotFirebase.mm::crash_log_warning: Testing");//<--
    NSString* ns_message = [NSString stringWithCString: message.utf8().get_data()];
    [crashlytics crashLogWarning: ns_message];
}

//Crashlytics--

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
    CLASS_DB::bind_method("notify_with_badge", &GodotFirebase::notifyWithBadgeMM);
    CLASS_DB::bind_method("clear_notify_badge", &GodotFirebase::clearNotifyBadgeMM);
    CLASS_DB::bind_method("cancel_notification_with_tag", &GodotFirebase::cancelNotificationWithTag);
    CLASS_DB::bind_method("cancel_all_pending_notification_requests", &GodotFirebase::cancelAllPendingNotificationRequests);
    CLASS_DB::bind_method("getToken", &GodotFirebase::getToken);
    // Crashlytics
    CLASS_DB::bind_method("crash", &GodotFirebase::crash);
    CLASS_DB::bind_method("crash_set_string", &GodotFirebase::crash_set_string);
    CLASS_DB::bind_method("crash_set_bool", &GodotFirebase::crash_set_bool);
    CLASS_DB::bind_method("crash_set_real", &GodotFirebase::crash_set_real);
    CLASS_DB::bind_method("crash_set_int", &GodotFirebase::crash_set_int);
    CLASS_DB::bind_method("crash_set_user_id", &GodotFirebase::crash_set_user_id);
    CLASS_DB::bind_method("crash_log_exception", &GodotFirebase::crash_log_exception);
    CLASS_DB::bind_method("crash_log_error", &GodotFirebase::crash_log_error);
    CLASS_DB::bind_method("crash_log_warning", &GodotFirebase::crash_log_warning);
    // Remote config
    CLASS_DB::bind_method("getRemoteValue", &GodotFirebase::getRemoteValue);
    CLASS_DB::bind_method("setRemoteDefaultsFile", &GodotFirebase::setRemoteDefaultsFile);
    CLASS_DB::bind_method("setRemoteDefaults", &GodotFirebase::setRemoteDefaults);
    /*
     Admob related functions to be implemented:
     
    "is_interstitial_loaded", "is_rewarded_video_loaded","load_rewarded_video",
    "load_interstitial"
     
     TODO remove
     */
}
