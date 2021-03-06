//
//  File.swift
//  Flare
//
//  Created by Thomas Williams on 14/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKCoreKit
import FirebaseDatabase

extension ProfileViewController {
    
    func logout() {
        let user = FIRAuth.auth()?.currentUser
        try! FIRAuth.auth()?.signOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let RootViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("rootView")
        self.presentViewController(RootViewController, animated: true, completion: nil)
    }
}