#include "core/dictionary.h"
#import "app_delegate.h"

@interface GodotFirebaseNotifications : NSObject {
}

- (void) initWithCallback: (void (^)()) callback;
- (NSString *) getToken;
- (void) notifyInSecondsWithMessage: (NSString *) message
                          withTitle: (NSString *) title
                        withSeconds: (int) seconds
                            withTag: (NSString *)  tag;
- (void) notifyWithBadge: (int) seconds;
- (void) clearNotifyBadge;
- (void) cancelNotificationWithTag: (NSString *) tag;
- (void) cancelAllPendingNotificationRequests;

@property NSString *token;

@end

