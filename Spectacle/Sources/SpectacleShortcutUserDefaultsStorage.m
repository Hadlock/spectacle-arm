#import "SpectacleShortcutUserDefaultsStorage.h"

@implementation SpectacleShortcutUserDefaultsStorage

+ (void)initialize
{
  [NSKeyedUnarchiver setClass:[SpectacleShortcut class] forClassName:@"SpectacleHotKey"];
  [NSKeyedUnarchiver setClass:[SpectacleShortcut class] forClassName:@"ZeroKitHotKey"];
  [NSKeyedUnarchiver setClass:[SpectacleShortcut class] forClassName:@"ZKHotKey"];
}

- (NSArray<SpectacleShortcut *> *)loadShortcutsWithAction:(SpectacleShortcutAction)action
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary<NSString *, NSData *> *shortcutsFromUserDefaults = [NSMutableDictionary new];
  for (NSString *shortcutName in [self shortcutNames]) {
    shortcutsFromUserDefaults[shortcutName] = [userDefaults dataForKey:shortcutName];
  }
  return [self shortcutsFromDictionary:shortcutsFromUserDefaults action:action];
}

- (void)storeShortcuts:(NSArray<SpectacleShortcut *> *)shortcuts
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  for (SpectacleShortcut *shortcut in shortcuts) {
    NSError *error = nil;
    NSData *shortcutData = [NSKeyedArchiver archivedDataWithRootObject:shortcut requiringSecureCoding:YES error:&error];

    if (error) {
      // Handle the error
      NSLog(@"Error archiving data: %@", error);
    }    NSString *shortcutName = shortcut.shortcutName;
    if (![shortcutData isEqualToData:[userDefaults dataForKey:shortcutName]]) {
      [userDefaults setObject:shortcutData forKey:shortcutName];
    }
  }
}

- (BOOL)isMigrationNeeded
{
  return NO;
}

- (NSArray<NSString *> *)shortcutNames
{
  return @[
           @"MoveToCenter",
           @"MoveToFullscreen",
           @"MoveToLeftHalf",
           @"MoveToRightHalf",
           @"MoveToTopHalf",
           @"MoveToBottomHalf",
           @"MoveToUpperLeft",
           @"MoveToLowerLeft",
           @"MoveToUpperRight",
           @"MoveToLowerRight",
           @"MoveToNextDisplay",
           @"MoveToPreviousDisplay",
           @"MoveToNextThird",
           @"MoveToPreviousThird",
           @"MakeLarger",
           @"MakeSmaller",
           @"UndoLastMove",
           @"RedoLastMove",
           ];
}

- (NSArray<SpectacleShortcut *> *)shortcutsFromDictionary:(NSDictionary<NSString *, NSData *> *)dictionary
                                                   action:(SpectacleShortcutAction)action
{
  NSMutableArray<SpectacleShortcut *> *shortcuts = [NSMutableArray new];
  for (NSData *shortcutData in dictionary.allValues) {
    NSError *error = nil;
    SpectacleShortcut *shortcut = [NSKeyedUnarchiver unarchivedObjectOfClass:[SpectacleShortcut class] fromData:shortcutData error:&error];

    if (error) {
      // Handle the error
      NSLog(@"Error unarchiving data: %@", error);
    }
    [shortcuts addObject:[shortcut copyWithShortcutAction:action]];
  }
  return shortcuts;
}

@end
