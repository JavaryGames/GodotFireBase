#import "godotFirebaseRewardedVideo.h"
#import <GoogleMobileAds/GADRewardBasedVideoAd.h>
#import <GoogleMobileAds/GADAdReward.h>
#include "core/reference.h"

@implementation GodotFirebaseRewardedVideo

- (void) init:(NSDictionary*)config_: (int)script_id_; {
    NSLog(@"Calling init from rewarded video");
    
    ad_id = [[NSString alloc] initWithString: config_[@"Ads"][@"RewardedVideoAdId"]];
    script_id = script_id_;
}

- (void) load; {
    NSLog(@"Calling load from rewarded video");

    [[GADRewardBasedVideoAd sharedInstance] loadRequest: [GADRequest request] withAdUnitID:ad_id];
    
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
}


- (void) show; {
    NSLog(@"Calling show from rewarded video");
    
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        NSLog(@"rewarded video show is ready");
        
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController];
    } else {
        NSLog(@"rewarded video show IS NOT ready");
    }
}

-(void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"rewarded video received");
    
    Object *gdscript_object = ObjectDB::get_instance(script_id);
    Dictionary status;
    status[[@"unit_id" UTF8String]] = [ad_id UTF8String];
    status[[@"status" UTF8String]] = [@"loaded" UTF8String];
    gdscript_object->call_deferred("_receive_message", [@"FireBase" UTF8String], [@"AdMob" UTF8String], [@"AdMob_Video" UTF8String], status);
}

-(void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    NSLog(@"rewarded video failed to load");
    
    Object *gdscript_object = ObjectDB::get_instance(script_id);
    Dictionary status;
    status[[@"unit_id" UTF8String]] = [ad_id UTF8String];
    status[[@"status" UTF8String]] = [@"load_failed" UTF8String];
    gdscript_object->call_deferred("_receive_message", [@"FireBase" UTF8String], [@"AdMob" UTF8String], [@"AdMob_Video" UTF8String], status);
}

-(void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"rewarded video closed");
}

-(void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    NSLog(@"rewarded video received reward");
    
    Object *gdscript_object = ObjectDB::get_instance(script_id);
    Dictionary status;
    status[[@"unit_id" UTF8String]] = [ad_id UTF8String];
    status[[@"RewardType" UTF8String]] = [reward.type UTF8String];
    status[[@"RewardAmount" UTF8String]] = reward.amount.doubleValue;
    gdscript_object->call_deferred("_receive_message", [@"FireBase" UTF8String], [@"AdMob" UTF8String], [@"AdMobReward" UTF8String], status);
}


@end
