
#import "godotFirebaseNotifications.h"
#import <UserNotifications/UserNotifications.h>;
#import "Firebase.h"

UNUserNotificationCenter *center;
UNAuthorizationOptions options;
BOOL is_authorized;

@implementation GodotFirebaseNotifications

- (void) init:(NSDictionary*)config_: (int)script_id_; {
    center = [UNUserNotificationCenter currentNotificationCenter];
    options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    is_authorized = NO;
    NSLog(@"Calling init from analytics");
    // check if already authorized
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"Notifications already authorized.");
            is_authorized = YES;
            [self after_checked_authorization];
        }
        else {
            [center requestAuthorizationWithOptions:options
                                  completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                      is_authorized = granted;
                                      if (!granted) {
                                          NSLog(@"User did not allow notifications");}
                                      [self after_checked_authorization];
                                  }];
            
        }
    }];
    
}

- (void) after_checked_authorization; {
    
}

- (void) notifyInSecondsWithMessage: (NSString *) message
                          withTitle: (NSString *) title
                        withSeconds: (int) seconds
                            withTag: (NSString *)  tag; {
    if (!is_authorized) {
        NSLog(@"Trying to schedule a notification; not authorized");
    }
    else {
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.title = title;
        content.body = message;
        content.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval: seconds repeats: NO];
        UNNotificationRequest *request = [UNNotificationRequest
                                            requestWithIdentifier: tag
                                            content: content
                                            trigger: trigger];
        [center addNotificationRequest: request
                 withCompletionHandler:^(NSError * _Nullable error) {
                     if (error != nil) {
                         NSLog(@"Failed to schedule notification: %@",error);
                     }
                 }];
    }
}

- (void) cancelNotificationWithTag: (NSString *) tag; {
    NSLog(@"Cancelling notification with tag %@", tag);
    [center removePendingNotificationRequestWithIdentifiers: @[tag]];
}


@end
