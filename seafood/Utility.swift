//
//  Utility.swift
//  seafood
//
//  Created by Wanbin Ouyang on 7/25/15.
//  Copyright (c) 2015 go2fish. All rights reserved.
//

import UIKit

class Utility {
   
    static let host="192.168.0.8"
    static let port="3005"
    
    class func generateRequestObject( method: String,resource: String,postString : String?=nil ) -> NSMutableURLRequest{
        let url = NSURL(string: "http://\(host):\(port)\(resource)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod=method
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(NSUserDefaults.standardUserDefaults().stringForKey("token"), forHTTPHeaderField: "token")
        request.HTTPBody = postString?.dataUsingEncoding(NSUTF8StringEncoding)!
        
        return request
    }
    
    class func showMyAlert( controller:UIViewController, userMessage:String,completion:(() -> Void)?=nil ){
        var myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil)
        myAlert.addAction(okAction)
        controller.presentViewController(myAlert, animated: true, completion: completion)
    }
    
    class func validateEmail(testStr:String) ->Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        var result = emailTest.evaluateWithObject(testStr)
        return result
    }
}
