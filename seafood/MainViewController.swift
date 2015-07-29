//
//  MainViewController.swift
//  seafood
//
//  Created by Wanbin Ouyang on 7/27/15.
//  Copyright (c) 2015 go2fish. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    var productList = [Product]()
    var imageCache = [String:UIImage]()
    
    @IBOutlet weak var logoutBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true
        let request = Utility.generateRequestObject("GET", resource: "/api/products", postString: nil)
        NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
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
                    if let resultJsonData = parseJson["data"] as? NSDictionary {
                        if let productJsonDataArray = resultJsonData["products"] as? NSArray{
                            for productJsonData in productJsonDataArray {
                                    var product = Product()
                                    product.name = productJsonData["product_name"] as! String
                                    product.description = productJsonData["product_description"] as! String
                                    product.price = productJsonData["product_price"] as! Double
                                    product.unit = productJsonData["product_unit"] as! String
                                    product.image = productJsonData["product_image"] as! String
                                    product.quantity = productJsonData["product_quantity"] as! Int
                                    product.id = productJsonData["_id"] as! String
                                    self.productList.append(product)
                            }
                        }
                    }
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.tableView.reloadData()
                    }

                }
                
            }
            
        }.resume()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var productCell:ProductCustomUITableViewCell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! ProductCustomUITableViewCell
        
        
        var product = productList[indexPath.row]
        
        productCell.productNameLabel.text = product.name
        if( product.quantity > 0){
            productCell.productMark.textColor = UIColor.greenColor()
            productCell.productMark.text = "Available"
        }else{
            productCell.productMark.textColor = UIColor.redColor()
            productCell.productMark.text = "Temporary sold out"
        }
        productCell.productPriceLabel.text = String( format:"$%.2f",product.price )
        productCell.productUnitLabel.text = "/\(product.unit)"
        
        productCell.imageView?.image = UIImage(named: "Blank52.png")
        let urlString = "http://192.168.0.8:3000/images/container1/\(productList[indexPath.row].image)"
        println(urlString)
        let imgURL = NSURL(string: urlString)
        
        if let img = imageCache[urlString] {
            productCell.imageView?.image = img
        }else{
            let request: NSURLRequest = NSURLRequest(URL: imgURL!)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data)
                    // Store the image in to our cache
                    self.imageCache[urlString] = image
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        
        return productCell
    }
    
    @IBAction func logoutBtnTapped(sender: UIBarButtonItem) {
        let user_id = NSUserDefaults.standardUserDefaults().stringForKey("user_id")
        let email = NSUserDefaults.standardUserDefaults().stringForKey("email")
        
        let post = "user_id=\(user_id!)"
        let request:NSURLRequest = Utility.generateRequestObject("DELETE", resource: "/api/logout",postString:post)
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
                        self.logoutCb()
                    }
                }
                
            }
            
        }
        task.resume()
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func logoutCb(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_id")
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func lockView(){
        self.logoutBtn.enabled = false
    }
    
    func releaseView(){
        self.logoutBtn.enabled = true
    }
    
}
