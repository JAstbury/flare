//
//  SwipeViewController.swift
//  Flare
//
//  Created by Jess Astbury on 10/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import FirebaseDatabase
import CoreLocation

extension FlareViewController: CLLocationManagerDelegate {
    
    
    func onSwipe() {
        
        let imageString = NSUUID().UUIDString
        
        if self.flareTitle.text != "" {
        saveFlareToDatabase(imageString)
        uploadImage(imageString)
            
        } else {
            self.displayAlertMessage("Please enter a title")
            return
        }
    }
    
    func uploadImage(imageString: String) {
        var data = NSData()
        data = UIImageJPEGRepresentation(self.tempImageView.image!, 0.8)!
        
        let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
        let imageRef = storageRef.child("images/flare\(imageString).jpg")
        let uploadTask = imageRef.putData(data, metadata: nil) { metadata, error in
            if (error != nil) {
                puts("Error")
            } else {
                let downloadURL = metadata!.downloadURL
            }
        }
    }
    
    func getFacebookID() {
        if let user = FIRAuth.auth()?.currentUser {
            for profile in user.providerData {
                self.uid = profile.uid;  // Provider-specific UID
            }
        }
    }
        
    func saveFlareToDatabase(imageString: String) {
        self.getFacebookID()
        let flareRef = ref.childByAppendingPath("flares")
        let timestamp = FIRServerValue.timestamp()
        
        let user = FIRAuth.auth()?.currentUser
        // Put a guard on the email code below:
        let flare1 = ["facebookID": self.uid! as String, "title": self.flareTitle.text!, "subtitle": user!.displayName! as String, "imageRef": "images/flare\(imageString).jpg", "latitude": self.flareLatitude! as String, "longitude": self.flareLongitude! as String, "timestamp": timestamp, "isPublic": self.isPublicFlare as Bool]
        let flare1Ref = flareRef.childByAutoId()
        flare1Ref.setValue(flare1)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.flareLatitude = String(location!.coordinate.latitude)
        self.flareLongitude = String(location!.coordinate.longitude)
    }
    
    func displayAlertMessage(message: String)
    {
        let myAlert = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    

    
    func getFbIDsFromDatabase(completion: (result: Array<Flare>) -> ()) {
        getTimeOneHourAgo()
        
        var facebookID = getFacebookID()
        var databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrderedByChild("facebookID").queryEqualToValue(self.uid).observeEventType(.Value, withBlock: { (snapshot) in
            
            var facebookIdItems = [Flare]()
            
            for item in snapshot.children {
//               if (item.value!["isPublic"] as! Bool) {
                    let flare = Flare(snapshot: item as! FIRDataSnapshot)
                    facebookIdItems.insert(flare, atIndex: 0)
                    print("***item**")
                    print(item)
                    print("***array**")
                    print(facebookIdItems)
                    print("***array count**")
                    print(facebookIdItems.count)
                }
//            }
            completion(result: facebookIdItems)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func getTimeOneHourAgo() {
        var currentTimeInMilliseconds = NSDate().timeIntervalSince1970 * 1000
        self.timeOneHourAgo = (currentTimeInMilliseconds - 3600000)
    }
    
}