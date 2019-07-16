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

#else

typedef void *interstitialAdPtr;
typedef void *rewardedVideoPtr;
typedef void *analyticsPtr;
typedef void *notificationsPtr;

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
    notificationsPtr notifications;
    
protected:
    // void do_ios_rate(const String &app_id); TODO remove
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
    void cancelNotificationWithTag(const String &tag);
    void cancelAllPendingNotificationRequests();

    void setRemoteDefaults(const String &jsonData);
    void crash_set_user_id(const String &id);

    GodotFirebase();
    ~GodotFirebase();
};



#endif
