//
//  KitLocateDelegateClass.m
//  iTimbrum
//
//  Created by Simone Genovese on 23/09/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//

#import "KitLocateDelegateClass.h"

@implementation KitLocateDelegateClass

- (id)init{
    return self;
}

- (void) startLocation{
    [KitLocate setUniqueUserID:@"Simone"];
    [KLLocation registerGeofencing];
    NSLog(@"Starting region monitoring");
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * latitudine = [standardUserDefaults objectForKey:@"latitudine_preference"];
    NSNumber * longitudine = [standardUserDefaults objectForKey:@"longitudine_preference"];
    KLGeofence *inmyGeofence = [KLGeofence createNewGeofenceWithLatitude:[latitudine floatValue] Longitude:[longitudine floatValue] PushRadius:20.0 Type:KL_GEOFENCE_TYPE_IN];
    
    [inmyGeofence setIDUser:@"Lavoro"];
    [KLLocation addGeofence:inmyGeofence];
    
    KLGeofence *outmyGeofence = [KLGeofence createNewGeofenceWithLatitude:[latitudine floatValue] Longitude:[longitudine floatValue] PushRadius:20.0 Type:KL_GEOFENCE_TYPE_OUT];
    
    [outmyGeofence setIDUser:@"Lavoro"];
    [KLLocation addGeofence:outmyGeofence];
}

- (void)geofencesIn:(NSArray*)arrGeofenceList {
    UILocalNotification *scheduledAlert;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    scheduledAlert = [[UILocalNotification alloc] init];
    scheduledAlert.applicationIconBadgeNumber=1;
    scheduledAlert.fireDate = nil;
    scheduledAlert.timeZone = [NSTimeZone defaultTimeZone];
    scheduledAlert.alertBody = @"Ben arrivato a lavoro, ricorda di timbrare.";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:scheduledAlert];

}

- (void)geofencesOut:(NSArray*)arrGeofenceList{
    UILocalNotification *scheduledAlert;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    scheduledAlert = [[UILocalNotification alloc] init];
    scheduledAlert.applicationIconBadgeNumber=1;
    scheduledAlert.fireDate = nil;
    scheduledAlert.timeZone = [NSTimeZone defaultTimeZone];
    scheduledAlert.alertBody = @"Stai andando via? Ricorda di timbrare l'uscita";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:scheduledAlert];
}
@end
