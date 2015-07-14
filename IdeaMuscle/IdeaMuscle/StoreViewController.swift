//
//  StoreViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/10/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import StoreKit
import Parse

class StoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var tableView = UITableView()
    let productIdentifiers = Set(["Pro_One_Month", "Pro_Three_Month", "Pro_One_Year", "Pro_Lifetime"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    //var productsArray = [SKProduct?](count: 4, repeatedValue: nil)
    var restorePurchaseButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "IdeaMuscle Pro Store"
        
        //MARK: - Table View Setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(StoreTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.frame = CGRectMake(0, 5, self.view.frame.width, 250)
        tableView.scrollEnabled = false
        self.view.addSubview(tableView)
        
        //MARK: - Pro Description Label

        restorePurchaseButton.frame = CGRectMake(5, self.view.frame.maxY - 45, self.view.frame.width - 10, 40)
        restorePurchaseButton.setTitle("Restore Purchases", forState: .Normal)
        restorePurchaseButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        restorePurchaseButton.setTitleColor(redColor, forState: .Highlighted)
        restorePurchaseButton.backgroundColor = fiftyGrayColor
        restorePurchaseButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        restorePurchaseButton.addTarget(self, action: "restorePurchases:", forControlEvents: .TouchUpInside)
        if let user = PFUser.currentUser(){
            if let isProForever = user["isProForever"] as? Bool{
                if isProForever == true{
                    restorePurchaseButton.enabled = false
                    restorePurchaseButton.alpha = 0.1
                    restorePurchaseButton.setTitleColor(twoHundredGrayColor, forState: .Normal)
                    
                }
            }
        }
        self.view.addSubview(restorePurchaseButton)
        
        let labelHeight = self.view.frame.height - tableView.frame.height - restorePurchaseButton.frame.height - 20
        let proDescriptionLabel = UITextView(frame: CGRectMake(5, restorePurchaseButton.frame.minY - labelHeight - 5, self.view.frame.width - 10, labelHeight))
        proDescriptionLabel.text = "Build your idea muscle and your following with IdeaMuscle Pro! Here's what you get with Pro: \n \n -Ability to post unlimited ideas and topics. \n \n -Post unlimited public ideas. \n \n -Access to leaderboard to see your world rank and rank among friends.\n \n -Access to all the top idea/topic time period filters. \n \n -Ability to comment on ideas. \n \n -Ability to save drafts. \n \n -View other user's world rank."
        proDescriptionLabel.font = UIFont(name: "Avenir-Heavy", size: 13)
        proDescriptionLabel.layer.borderWidth = 1
        proDescriptionLabel.layer.borderColor = twoHundredGrayColor.CGColor
        proDescriptionLabel.layer.cornerRadius = 3
        self.view.addSubview(proDescriptionLabel)
        
        requestProductData()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        for transaction in transactions as! [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                println("Transaction Approved")
                println("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                println("Transaction Failed")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func deliverProduct(transaction: SKPaymentTransaction){
        if transaction.payment.productIdentifier == "Pro_One_Month"{
            processTransaction(1, transaction: transaction)
        }else if transaction.payment.productIdentifier == "Pro_Three_Month"{
            processTransaction(3, transaction: transaction)
        }else if transaction.payment.productIdentifier == "Pro_One_Year"{
            processTransaction(12, transaction: transaction)
        }else if transaction.payment.productIdentifier == "Pro_Lifetime"{
            if let user = PFUser.currentUser(){
                user.fetch()
                user["isPro"] = true
                user["isProForever"] = true
                let calendar = NSCalendar.currentCalendar()
                let components = NSDateComponents()
                components.year = 100
                let now = transaction.transactionDate
                let expiration = calendar.dateByAddingComponents(components, toDate: now, options: nil)
                user["proExpiration"] = expiration
                user.saveEventually()
                
                var transactionObject = PFObject(className: "Transaction")
                transactionObject["userPointer"] = user
                transactionObject["transactionDate"] = transaction.transactionDate
                transactionObject["transactionIdentifier"] = transaction.transactionIdentifier
                transactionObject["product"] = transaction.payment.productIdentifier
                transactionObject.saveEventually()
                
                
                tableView.reloadData()
                restorePurchaseButton.enabled = false
                restorePurchaseButton.alpha = 0.1
                restorePurchaseButton.setTitleColor(twoHundredGrayColor, forState: .Normal)
                
            }
            
        }
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        var products = response.products
        var unsortedArray = Array<SKProduct>()
        if products.count != 0 {
            for product in products{
                let productFinal = product as? SKProduct
                unsortedArray.append(productFinal!)
                
            }
        
            productsArray = unsortedArray.sorted({ (product1: SKProduct, product2: SKProduct) -> Bool in
                
                let price1 = product1.price.doubleValue
                let price2 = product2.price.doubleValue
                return price1 < price2
                
            })
            
            self.tableView.reloadData()
        } else {
            println("No products found")
        }
        
        products = response.invalidProductIdentifiers
        
        for product in products
        {
            println("Product not found: \(product)")
        }
        
    }
    
    func requestProductData(){
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                self.productIdentifiers as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            var alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func restorePurchases(sender: UIButton) {
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func paymentQueue(queue: SKPaymentQueue!, restoreCompletedTransactionsFailedWithError error: NSError!) {
        println("restore Failed")
        println(error.userInfo)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        
        println("restore successful")
                if let user = PFUser.currentUser(){
                    if let isPro = user["isPro"] as? Bool{
                        if isPro == true{
                            let expiration = user["proExpiration"] as! NSDate
                            let formatter = NSDateFormatter()
                            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
                            let formattedDate = formatter.stringFromDate(expiration)
                            var alert = UIAlertView(title: "Success!", message: "Your purchase was restored. Your Pro expiration date is " + formattedDate, delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }else{
                            let notLoggedInToRightAccount: UIAlertController = UIAlertController(title: "You are logged into a different account", message: "Please login to the account you made the purchase with to restore the purchase.", preferredStyle: .Alert)
                            //Create and add the Cancel action
                            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                            }
                            notLoggedInToRightAccount.addAction(cancelAction)
                            
                            let logoutAction: UIAlertAction = UIAlertAction(title: "Logout", style: .Default, handler: { (action) -> Void in
                                PFUser.logOut()
                                let loginVC = ViewController()
                                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.window?.rootViewController = loginVC
                            })
                            
                            notLoggedInToRightAccount.addAction(logoutAction)
                            
                            //Present the AlertController
                            self.presentViewController(notLoggedInToRightAccount, animated: true, completion: nil)
                            
                        }
                        
                    }else{
                        let notLoggedInToRightAccount: UIAlertController = UIAlertController(title: "You are logged into a different account", message: "Please login to the account you made the purchase with to restore the purchase.", preferredStyle: .Alert)
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                        }
                        notLoggedInToRightAccount.addAction(cancelAction)
                        
                        let logoutAction: UIAlertAction = UIAlertAction(title: "Logout", style: .Default, handler: { (action) -> Void in
                            PFUser.logOut()
                            let loginVC = ViewController()
                            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.window?.rootViewController = loginVC
                        })
                        
                        notLoggedInToRightAccount.addAction(logoutAction)
                        
                        //Present the AlertController
                        self.presentViewController(notLoggedInToRightAccount, animated: true, completion: nil)
                    }

                }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! StoreTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if productsArray[indexPath.row].price != nil{
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            
            let price = numberFormatter.stringFromNumber(productsArray[indexPath.row].price)
            let currencySymbol = numberFormatter.currencySymbol
            
            if productsArray[indexPath.row].productIdentifier == "Pro_Lifetime"{
                cell.textLabel!.text = "Lifetime" 
            }else if productsArray[indexPath.row].productIdentifier == "Pro_One_Month"{
                cell.textLabel!.text = "One Month"
            }else if productsArray[indexPath.row].productIdentifier == "Pro_One_Year"{
                cell.textLabel!.text = "One Year"
            }else if productsArray[indexPath.row].productIdentifier == "Pro_Three_Month"{
                cell.textLabel!.text = "Three Months"
            }
            
            cell.textLabel!.font = UIFont(name: "HelveticaNeue", size: 14)
            
            
            if let user = PFUser.currentUser(){
            if let isProForever = user["isProForever"] as? Bool{
                if isProForever == false{
                    cell.buyButton.backgroundColor = redColor
                    cell.buyButton.setTitle("Buy", forState: .Normal)
                    cell.buyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    cell.buyButton.setTitleColor(fiftyGrayColor, forState: .Highlighted)
                    cell.buyButton.frame = CGRectMake(cell.frame.maxX - 65, 5, 60, cell.frame.height - 10)
                    cell.buyButton.addTarget(self, action: "buy:", forControlEvents: .TouchUpInside)
                    cell.buyButton.tag = indexPath.row
                }else{
                    cell.buyButton.backgroundColor = twoHundredGrayColor
                    cell.buyButton.enabled = false
                    cell.buyButton.setTitle("Already Pro", forState: .Normal)
                    cell.buyButton.frame = CGRectMake(cell.frame.maxX - 125, 5, 120, cell.frame.height - 10)
                }
            }else{
                cell.buyButton.backgroundColor = redColor
                cell.buyButton.setTitle("Buy", forState: .Normal)
                cell.buyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                cell.buyButton.setTitleColor(fiftyGrayColor, forState: .Highlighted)
                cell.buyButton.frame = CGRectMake(cell.frame.maxX - 65, 5, 60, cell.frame.height - 10)
                cell.buyButton.addTarget(self, action: "buy:", forControlEvents: .TouchUpInside)
                cell.buyButton.tag = indexPath.row
            }
            }
            
            
            
            cell.priceLabel.frame = CGRectMake(cell.buyButton.frame.minX - 60, cell.frame.height/2 - 15, 60, 30)
            cell.priceLabel.text = currencySymbol! + price!
            cell.priceLabel.font = UIFont(name: "HelveticaNeue", size: 14)
            
        }
        
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func processTransaction(numberOfMonths: Int, transaction: SKPaymentTransaction){
        if let user = PFUser.currentUser(){
            user.fetch()
            user["isPro"] = true
            let calendar = NSCalendar.currentCalendar()
            let components = NSDateComponents()
            components.month = numberOfMonths
            let transDate = transaction.transactionDate
            if user["proExpiration"] == nil{
                let expiration = calendar.dateByAddingComponents(components, toDate: transDate, options: nil)
                user["proExpiration"] = expiration
                user.saveEventually()
            }else{
                let currentExpiration = user["proExpiration"] as! NSDate
                if currentExpiration.isGreaterThanDate(transaction.transactionDate){
                    let expiration = calendar.dateByAddingComponents(components, toDate: currentExpiration, options: nil)
                    user["proExpiration"] = expiration
                    user.saveEventually()
                }else{
                    let expiration = calendar.dateByAddingComponents(components, toDate: transaction.transactionDate, options: nil)
                    user["proExpiration"] = expiration
                    user.saveEventually()
                }
            }
            
            var transactionObject = PFObject(className: "Transaction")
            transactionObject["userPointer"] = user
            transactionObject["transactionDate"] = transaction.transactionDate
            transactionObject["transactionIdentifier"] = transaction.transactionIdentifier
            transactionObject["product"] = transaction.payment.productIdentifier
            transactionObject.saveEventually()
        }
    }
    
    func buy(sender: UIButton!){
        if PFUser.currentUser() != nil{
            let payment = SKPayment(product: productsArray[sender.tag])
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }else{
            println("You Must Login To Buy")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    



}
