
#import "godotFirebaseNotifications.h"
#import <UserNotifications/UserNotifications.h>;
#import "Firebase.h"

#define AppDelegate (YourAppDelegate *)[[UIApplication sharedApplication] delegate]

UNUserNotificationCenter *center;
UNAuthorizationOptions options;
BOOL is_authorized;

@implementation GodotFirebaseNotifications

- (void) initWithCallback: (void (^)()) callback; {
    center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge;
    is_authorized = NO;
    NSLog(@"Calling init from analytics");
    // check if already authorized
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"Notifications already authorized.");
            is_authorized = YES;
            callback();
        }
        else {
            [center requestAuthorizationWithOptions:options
                                  completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                      is_authorized = granted;
                                      if (!granted) {
                                          NSLog(@"User did not allow notifications");}
                                      callback();
                                  }];
            
        }
    }];
    
}

- (NSString*) getToken; {
    return self.token;
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
                     } else {
                         NSLog(@"Successfully scheduled notification to %d seconds from now", seconds);
                     }
                 }];
    }
}

- (void) notifyWithBadge; {
    if (!is_authorized) {
        NSLog(@"Trying to show badge; not authorized");
    }
    else {
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        NSNumber *badge_qty = [NSNumber numberWithInt:1];
        content.badge = badge_qty;
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval: 2 repeats: NO];
        UNNotificationRequest *request = [UNNotificationRequest
                                            requestWithIdentifier: @"notify_badge"
                                            content: content
                                            trigger: trigger];
        [center addNotificationRequest: request
                 withCompletionHandler:^(NSError * _Nullable error) {
                     if (error != nil) {
                         NSLog(@"Failed to show badge", error);
                     } else {
                         NSLog(@"Successfully show badge");
                     }
                 }];
    }
}

- (void) clearNotifyBadge; {
    if (!is_authorized) {
        NSLog(@"Trying to clear badge; not authorized");
    }
    else {
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        NSNumber *badge_qty = [NSNumber numberWithInt:0];
        content.badge = badge_qty;
        content.title = @"Mano";
        content.body = @"Caramba";
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval: 2 repeats: NO];
        UNNotificationRequest *request = [UNNotificationRequest
                                            requestWithIdentifier: @"clear_badge"
                                            content: content
                                            trigger: trigger];
        [center addNotificationRequest: request
                 withCompletionHandler:^(NSError * _Nullable error) {
                     if (error != nil) {
                         NSLog(@"Failed to clear badge", error);
                     } else {
                         NSLog(@"Successfully clear badge");
                     }
                 }];
    }
}

- (void) cancelNotificationWithTag: (NSString *) tag; {
    NSLog(@"Cancelling notification with tag %@", tag);
    [center removePendingNotificationRequestsWithIdentifiers: @[tag]];
}

- (void) cancelAllPendingNotificationRequests; {
    NSLog(@"Cancelling all pending notifications"); 
    [center removeAllPendingNotificationRequests];
}


//Called when a notification is delivered to a foreground app.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}


@end
