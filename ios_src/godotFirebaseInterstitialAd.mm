#import "godotFirebaseInterstitialAd.h"
#include "core/reference.h"

@implementation GodotFirebaseInterstitialAd

- (void) init:(NSDictionary*)config_: (int)script_id_; {
    NSLog(@"Calling init from interstitial");
    
    ad_id = [[NSString alloc] initWithString: config_[@"Ads"][@"InterstitialAdId"]];
    script_id = script_id_;
}

- (void) load; {
    NSLog(@"Calling load from interstitial");
    interstitial = [[GADInterstitial alloc]
                                     initWithAdUnitID:ad_id];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
}


- (void) show; {
    NSLog(@"Calling show from interstitial");
    
    if (interstitial.isReady) {
        NSLog(@"Insterstitial show is ready");
        [interstitial presentFromRootViewController:((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController];
    } else {
        NSLog(@"Interstitial show IS NOT ready");
    }
}

@end
