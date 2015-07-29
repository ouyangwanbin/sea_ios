//
//  LoginViewController.swift
//  seafood
//
//  Created by Wanbin Ouyang on 7/23/15.
//  Copyright (c) 2015 go2fish. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController{
    
    @IBOutlet weak var activityIDN: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.loginBtn.enabled = false
        self.activityIDN.hidden = true
    }
    
    @IBAction func emailEditChange(sender: UITextField) {
        self.checkTextField()
    }
    
    
    @IBAction func passwordEditChange(sender: UITextField) {
        self.checkTextField()
    }
    
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func login(sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
        let post = "email=\(email)&password=\(password)"
        let request:NSMutableURLRequest = Utility.generateRequestObject("POST", resource: "/api/login", postString: post)
        self.lockView()
        NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.releaseView()
            }
            if( error != nil ){
                //need to push to the mainQueue
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    Utility.showMyAlert(self,userMessage:"error in connection")
                    return
                }
            }
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("******response data=\(responseString)")
            
            var err:NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err) as?NSDictionary
            
            if let parseJson = json {
                var status = parseJson["status"] as? String
                if(status != "success"){
                    var msg = parseJson["msg"]as? String
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        Utility.showMyAlert(self,userMessage:msg!);
                    }
                }else{
                    
                    if let resultJsonData = parseJson["data"] as?NSDictionary{
                        if let userJsonData = resultJsonData["user"] as? NSDictionary{
                            //store user information
                            
                            NSUserDefaults.standardUserDefaults().setObject(userJsonData["_id"] as? String, forKey:"user_id")
                            NSUserDefaults.standardUserDefaults().setObject(userJsonData["email"] as? String, forKey:"email")
                        }
                        //store token
                        NSUserDefaults.standardUserDefaults().setObject(resultJsonData["token"] as? String, forKey:"token")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            let mainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("mainView") as! UITableViewController
                            self.navigationController?.pushViewController(mainViewController, animated: true)
                        }
                    }
                }
                
            }
            
        }.resume()
    }
    
    func lockView(){
        self.view.userInteractionEnabled = false
        self.emailTextField.enabled = false
        self.passwordTextField.enabled = false
        self.loginBtn.enabled = false
        self.activityIDN.startAnimating()
        self.activityIDN.hidden = false
    }
    
    func releaseView(){
        self.view.userInteractionEnabled = true
        self.emailTextField.enabled = true
        self.passwordTextField.enabled = true
        self.loginBtn.enabled = true
        self.activityIDN.hidden = true
        self.activityIDN.stopAnimating()
    }
    
    func checkTextField( ){
        let email = emailTextField.text
        let password = passwordTextField.text
        if( email.isEmpty || password.isEmpty ){
            self.loginBtn.enabled = false
        }else{
            self.loginBtn.enabled = true
        }
    }
}
