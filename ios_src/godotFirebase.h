#ifndef GODOT_FIREBASE_H
#define GODOT_FIREBASE_H

#include "core/version_generated.gen.h"
#include "core/reference.h"

#ifdef __OBJC__

#import "Firebase.h"

@class GodotFirebaseInterstitialAd;
typedef GodotFirebaseInterstitialAd *interstitialAdPtr;

@class GodotFirebaseRewardedVideo;
typedef GodotFirebaseRewardedVideo *rewardedVideoPtr;

@class GodotFirebaseAnalytics;
typedef GodotFirebaseAnalytics *analyticsPtr;

@class GodotFirebaseNotifications;
typedef GodotFirebaseNotifications *notificationsPtr;

@class GodotFirebaseCrashlytics;
typedef GodotFirebaseCrashlytics *crashlyticsPtr;

@class GodotFirebaseRemoteConfig;
typedef GodotFirebaseRemoteConfig *remoteConfigPtr;

#else

typedef void *interstitialAdPtr;
typedef void *rewardedVideoPtr;
typedef void *analyticsPtr;
typedef void *notificationsPtr;
typedef void *crashlyticsPtr;
typedef void *remoteConfigPtr;

#endif


class GodotFirebase : public Reference {
    
#if VERSION_MAJOR == 3
    GDCLASS(GodotFirebase, Reference);
#else
    OBJ_TYPE(GodotFirebase, Reference);
#endif
    
    interstitialAdPtr interstitialAd;
    rewardedVideoPtr rewardedVideo;
    analyticsPtr analytics;
    notificationsPtr notifications = NULL;
    crashlyticsPtr crashlytics;
    remoteConfigPtr remoteConfig;
    
protected:
    static void _bind_methods();
    
public:
    void initWithJson(const String &json, const int script_id);
    
    void load_interstitial();
    void show_interstitial_ad();
    
    void load_rewarded_video();
    void show_rewarded_video();
    
    void setScreenName(const String &screen_name);
    void send_events(const String &event_name, const Dictionary& key_values);
    

    // Notifications ++
    // "notifyInSecsWithTag"
    // Notifications --

    // todo: other NotifyIn* variants
    
    String getToken();
    void notifyInSecsWithTag(const String &message, const int seconds, const String &tag);
    void notifyWithBadgeMM();
    void cancelNotificationWithTag(const String &tag);
    void cancelAllPendingNotificationRequests();

    String getRemoteValue(const String &key);
    void setRemoteDefaultsFile(const String &path);
    void setRemoteDefaults(const String &jsonData);

    void crash();
    void crash_set_string(const String &key, const String &value);
    void crash_set_bool(const String &key, const bool value);
    void crash_set_real(const String &key, const float value);
    void crash_set_int(const String &key, const int value);
    void crash_set_user_id(const String &id);
    void crash_log_exception(const String &message);
    void crash_log_error(const String &message);
    void crash_log_warning(const String &message);

    GodotFirebase();
    ~GodotFirebase();
};



#endif
