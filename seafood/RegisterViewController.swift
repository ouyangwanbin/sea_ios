//
//  RegisterViewController.swift
//  seafood
//
//  Created by Wanbin Ouyang on 7/23/15.
//  Copyright (c) 2015 go2fish. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIND: UIActivityIndicatorView!
    @IBOutlet weak var emailValidateLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.btnRegister.enabled = false
        self.emailValidateLabel.text = nil
        self.activityIND.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if( textField.tag == 1 ){
            //when user begin edit email text , error should be removed
            self.emailValidateLabel.text = nil
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let email = textField.text
        if( textField.tag == 1 ){
            //validate email format
            if(!Utility.validateEmail(email)){
                self.emailValidateLabel.text="invalid email format"
                return
            }
            let request:NSMutableURLRequest = Utility.generateRequestObject("GET", resource: "/api/search-user/\(email)")
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
                data, response, error in
                if( error != nil ){
                    return
                }
                
                let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("******response data=\(responseString)")
                
                var err:NSError?
                var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err) as?NSDictionary
                
                if let parseJson = json {
                    var status = parseJson["status"] as? String
                    if(status != "success"){
                        return
                    }else{
                        var json = parseJson["data"] as? NSDictionary
                        if let resultDataJson = json {
                            var count = resultDataJson["count"] as? Int
                            if( count > 0){
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                   self.emailValidateLabel.text="email address exists"
                                }
                            }
                        }
                    }
                    
                }
                
            }
            task.resume()
        }
    }
    

    @IBAction func emailEditChange(sender: UITextField) {
        self.checkTextField()
    }
    
    @IBAction func passwordEditChange(sender: UITextField) {
        self.checkTextField()
    }
    @IBAction func confirmPasswordEditChange(sender: UITextField) {
        self.checkTextField()
    }
    @IBAction func btnRegister(sender: UIButton) {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        let confirmPassword = confirmPasswordTextField.text
        
        
        //check password match
        if( password != confirmPassword ){
            Utility.showMyAlert(self,userMessage:"passwords do not match")
            return
        }
        //save register information
        //post http://www.go2fish.com/api/users
        let post="email=\(email)&password=\(password)"
        
        let request:NSMutableURLRequest = Utility.generateRequestObject("POST", resource: "/api/users", postString: post)
        
        self.lockView()
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
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

                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        Utility.showMyAlert(self,userMessage:"Register Success")
                    }
                }
                
            }
            
        }
        
        task.resume()
    }
    
    //disabled all the interaction
    func lockView(){
        self.view.userInteractionEnabled = false
        self.emailTextField.enabled = false
        self.passwordTextField.enabled = false
        self.confirmPasswordTextField.enabled = false
        self.btnRegister.enabled = false
        self.activityIND.hidden = false
        self.activityIND.startAnimating()
    }
    
    //enbaled all the interaction
    func releaseView(){
        self.view.userInteractionEnabled = true
        self.emailTextField.enabled = true
        self.passwordTextField.enabled = true
        self.confirmPasswordTextField.enabled = true
        self.btnRegister.enabled = true
        self.activityIND.hidden = true
        self.activityIND.stopAnimating()
    }
    
    func checkTextField(){
        let email = emailTextField.text
        let password = passwordTextField.text
        let confirmPassword = confirmPasswordTextField.text
        if ( email.isEmpty || password.isEmpty || confirmPassword.isEmpty ){
            btnRegister.enabled = false
        }else{
            btnRegister.enabled = true
        }

    }
}
