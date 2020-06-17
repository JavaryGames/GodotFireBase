
#import "godotFirebaseNotifications.h"
#import <UserNotifications/UserNotifications.h>;
#import "Firebase.h"

UNUserNotificationCenter *center;
UNAuthorizationOptions options;
BOOL is_authorized;

@implementation GodotFirebaseNotifications

- (void) initWithCallback: (void (^)()) callback; {
    center = [UNUserNotificationCenter currentNotificationCenter];
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
        //content.badge = [NSNumber numberWithInt: 1];

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
        NSLog(@"MATEUS, COMECEI O ELSE");
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.badge = [NSNumber numberWithInt: 1];
        NSLog(@"MATEUS, ATE AGRA OK");
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval: 1 repeats: NO];
        UNNotificationRequest *request = [UNNotificationRequest
                                            requestWithIdentifier: @"soon"
                                            content: content
                                            trigger: trigger];
        NSLog(@"MATEUS, ESTAMOS INDO BEM");
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

- (void) cancelNotificationWithTag: (NSString *) tag; {
    NSLog(@"Cancelling notification with tag %@", tag);
    [center removePendingNotificationRequestsWithIdentifiers: @[tag]];
}

- (void) cancelAllPendingNotificationRequests; {
    NSLog(@"Cancelling all pending notifications"); 
    [center removeAllPendingNotificationRequests];
}


@end
