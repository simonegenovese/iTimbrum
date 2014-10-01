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
    KLGeofence *myGeofence = [KLGeofence createNewGeofenceWithLatitude:[latitudine floatValue] Longitude:[longitudine floatValue] PushRadius:20.0 Type:KL_GEOFENCE_TYPE_IN];
    [myGeofence setIDUser:@"Lavoro"];
    [KLLocation addGeofence:myGeofence];
}

- (void)geofencesIn:(NSArray*)arrGeofenceList {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GeoFencing"
                                                    message:@"In"
                                                   delegate:self
                                          cancelButtonTitle:@"Annulla"
                                          otherButtonTitles:@"Ok", nil];
    [alert show];

}

- (void)geofencesOut:(NSArray*)arrGeofenceList{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geofencing"
                                                    message:@"Out"
                                                   delegate:self
                                          cancelButtonTitle:@"Annulla"
                                          otherButtonTitles:@"Ok", nil];
    [alert show];

}
@end
