#include "core/dictionary.h"
#import "app_delegate.h"

@interface GodotFirebaseNotifications : NSObject {
}

- (void) init;
- (void) notifyInSecondsWithMessage: (NSString *) message
                          withTitle: (NSString *) title
                        withSeconds: (int) seconds
                            withTag: (NSString *)  tag;
- (void) cancelNotificationWithTag: (NSString *) tag;

@property NSString *token;

@end

