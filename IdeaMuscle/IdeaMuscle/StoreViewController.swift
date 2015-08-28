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
    var descriptionTable = UITableView()
    var activityIndicator = UIActivityIndicatorView()
    var buyActivityIndicator = UIActivityIndicatorView()
    var isPurchasing = false
    
    override func viewDidLayoutSubviews() {
        descriptionTable.flashScrollIndicators()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "IdeaMuscle Pro Store"
        
        startActivityIndicator()
        requestProductData()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        
        
        
        let vcs = self.navigationController?.viewControllers
        if self === vcs?.first{
            let cancelButton = UIButton()
            cancelButton.setTitle("Close", forState: .Normal)
            cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            cancelButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
            cancelButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
            cancelButton.sizeToFit()
            let cancelBarItem = UIBarButtonItem(customView: cancelButton)
            self.navigationItem.leftBarButtonItem = cancelBarItem
        }
        
        //MARK: - Table View Setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(StoreTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.frame = CGRectMake(0, 5, self.view.frame.width, 250)
        tableView.scrollEnabled = false
        self.view.addSubview(tableView)
        
        //MARK: - Title Label
        let titleLabel = UILabel()
        titleLabel.frame = CGRectMake(5, tableView.frame.maxY + 5, self.view.frame.width - 10, 30)
        titleLabel.text = "Here's what you get with IdeaMuscle Pro"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        titleLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(titleLabel)
        

        
        //MARK: - Restore Purchase Button

        restorePurchaseButton.frame = CGRectMake(5, self.view.frame.maxY - 45, self.view.frame.width - 10, 40)
        restorePurchaseButton.setTitle("Restore Purchases", forState: .Normal)
        restorePurchaseButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        restorePurchaseButton.setTitleColor(redColor, forState: .Highlighted)
        restorePurchaseButton.backgroundColor = fiftyGrayColor
        restorePurchaseButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        restorePurchaseButton.layer.cornerRadius = 3
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
        
        //MARK: - Description Table
        
        descriptionTable.dataSource = self
        descriptionTable.delegate = self
        //descriptionTable.registerClass(StoreTableViewCell.self, forCellReuseIdentifier: "Cell")
        let labelHeight = self.view.frame.height - tableView.frame.height - restorePurchaseButton.frame.height - titleLabel.frame.height - 30
        descriptionTable.frame = CGRectMake(3, titleLabel.frame.maxY + 3, self.view.frame.width - 6, labelHeight)
        //descriptionTable.separatorStyle = UITableViewCellSeparatorStyle.None
        descriptionTable.rowHeight = 75
        descriptionTable.layer.borderWidth = 1
        descriptionTable.layer.borderColor = oneFiftyGrayColor.CGColor
        descriptionTable.layer.cornerRadius = 3
        
        self.view.addSubview(descriptionTable)
        
    }
    
    func applicationDidBecomeActive()
    {
        if isPurchasing{
            startBuyActivityIndicator()
        }
    }
    
    func applicationWillResignActive()
    {
        stopBuyActivityIndicator()
    }
    
    func dismiss(sender: UIButton){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.tabBarController != nil{
            self.tabBarController!.tabBar.hidden = true
        }
        
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        isPurchasing = false
        
        for transaction in transactions as! [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                println("Transaction Approved")
                println("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                
                println("Transaction Failed")
                let purchaseFailedAlert: UIAlertController = UIAlertController(title: "Purchase Failed", message: "Purchase failed or was canceled.", preferredStyle: .Alert)
                isPurchasing = false
                purchaseFailedAlert.view.tintColor = redColor
                purchaseFailedAlert.view.backgroundColor = oneFiftyGrayColor
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel) { action -> Void in
                }
                purchaseFailedAlert.addAction(cancelAction)
                
                self.presentViewController(purchaseFailedAlert, animated: true, completion: nil)
                
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
        isPurchasing = false
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
                components.year = 1000
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
            
            //self.tableView.reloadData()
        } else {
            println("No products found")
        }
        
        products = response.invalidProductIdentifiers
        
        for product in products
        {
            println("Product not found: \(product)")
        }
        stopActivityIndicator()
    }
    
    func requestProductData(){
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                self.productIdentifiers as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            var alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.view.tintColor = redColor
            alert.view.backgroundColor = oneFiftyGrayColor
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
        isPurchasing = false
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
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
                    notLoggedIntoRightAccount()
                }
            }else{
                notLoggedIntoRightAccount()
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
        isPurchasing = false
        stopBuyActivityIndicator()
    }
    
    func notLoggedIntoRightAccount(){
        let notLoggedInToRightAccount: UIAlertController = UIAlertController(title: "You are logged into a different account", message: "Please login to the account you made purchases with to restore purchases. If you think you shouldn't be seeing this message email us at support@ideamuscle.me", preferredStyle: .Alert)
        notLoggedInToRightAccount.view.tintColor = redColor
        notLoggedInToRightAccount.view.backgroundColor = oneFiftyGrayColor
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        notLoggedInToRightAccount.addAction(cancelAction)
        
        let logoutAction: UIAlertAction = UIAlertAction(title: "Logout", style: .Default, handler: { (action) -> Void in
            logout()
        })
        
        notLoggedInToRightAccount.addAction(logoutAction)
        self.presentViewController(notLoggedInToRightAccount, animated: true, completion: nil)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = StoreTableViewCell()
        var cellTitle = StoreTableViewCell()
        var cellUnlimited = StoreTableViewCell()
        var cellCrownStore = StoreTableViewCell()
        var cellFilter = StoreTableViewCell()
        var cellComment = StoreTableViewCell()
        var cellDocument = StoreTableViewCell()
        
        if tableView == self.tableView{
            
            cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! StoreTableViewCell
            cell = StoreTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.frame = CGRectMake(0, 0, tableView.frame.width, 44)
        
            if productsArray[indexPath.row].price != nil{
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                
                let price = numberFormatter.stringFromNumber(productsArray[indexPath.row].price)
                let currencySymbol = numberFormatter.currencySymbol
                
                if productsArray[indexPath.row].productIdentifier == "Pro_Lifetime"{
                    cell.textLabel!.text = "Pro Lifetime"
                }else if productsArray[indexPath.row].productIdentifier == "Pro_One_Month"{
                    cell.textLabel!.text = "Pro One Month"
                    cell.detailTextLabel!.text = "(Does not auto-renew)"
                }else if productsArray[indexPath.row].productIdentifier == "Pro_One_Year"{
                    cell.textLabel!.text = "Pro One Year"
                    cell.detailTextLabel!.text = "(Does not auto-renew)"
                }else if productsArray[indexPath.row].productIdentifier == "Pro_Three_Month"{
                    cell.textLabel!.text = "Pro Three Months"
                    cell.detailTextLabel!.text = "(Does not auto-renew)"
                }
                
                cell.textLabel!.font = UIFont(name: "HelveticaNeue", size: 14)
                
                if let user = PFUser.currentUser(){
                        cell.buyButton.layer.cornerRadius = 3
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
            
        }else if tableView == self.descriptionTable{
            
            cell.frame = CGRectMake(0, 0, tableView.frame.width, 75)
            
            if indexPath.row == 0{
                cellUnlimited.iconImage.frame = CGRectMake(5, 27.5, 45, 20)
                cellUnlimited.iconImage.image = UIImage(named: "unlimited")
                cellUnlimited.selectionStyle = UITableViewCellSelectionStyle.None
                cellUnlimited.featureDescriptionLabel.frame = CGRectMake(55, 5, cellUnlimited.frame.width - 65, 75)
                cellUnlimited.featureDescriptionLabel.text = "Compose unlimited public or private ideas & topics."
                cellUnlimited.featureDescriptionLabel.font = UIFont(name: "Avenir", size: 13)
                cellUnlimited.featureDescriptionLabel.numberOfLines = 0
                return cellUnlimited
            }
            else if indexPath.row == 1{
                cellCrownStore.iconImage.frame = CGRectMake(5, 15.75, 45, 43.5)
                cellCrownStore.iconImage.image = UIImage(named: "crownStore")
                cellCrownStore.selectionStyle = UITableViewCellSelectionStyle.None
                cellCrownStore.featureDescriptionLabel.frame = CGRectMake(55, 5, cellUnlimited.frame.width - 65, 75)
                cellCrownStore.featureDescriptionLabel.text = "Access to the leaderboard where you can view your world rank, your friend ranking, and other user's rankings."
                cellCrownStore.featureDescriptionLabel.font = UIFont(name: "Avenir", size: 13)
                cellCrownStore.featureDescriptionLabel.numberOfLines = 0
                return cellCrownStore
            }
            else if indexPath.row == 2{
                cellFilter.iconImage.frame = CGRectMake(5, 12.75, 45, 49.5)
                cellFilter.iconImage.image = UIImage(named: "filter")
                cellFilter.selectionStyle = UITableViewCellSelectionStyle.None
                cellFilter.featureDescriptionLabel.frame = CGRectMake(55, 5, cellUnlimited.frame.width - 65, 75)
                cellFilter.featureDescriptionLabel.text = "Ability to use the different time period filters for top ideas and topics."
                cellFilter.featureDescriptionLabel.font = UIFont(name: "Avenir", size: 13)
                cellFilter.featureDescriptionLabel.numberOfLines = 0
                return cellFilter
            }
            else if indexPath.row == 3{
                cellComment.iconImage.frame = CGRectMake(5, 16.75, 45, 41.5)
                cellComment.iconImage.image = UIImage(named: "comment")
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cellComment.featureDescriptionLabel.frame = CGRectMake(55, 5, cellUnlimited.frame.width - 65, 75)
                cellComment.featureDescriptionLabel.text = "You can join the conversation and comment on ideas."
                cellComment.featureDescriptionLabel.font = UIFont(name: "Avenir", size: 13)
                cellComment.featureDescriptionLabel.numberOfLines = 0
                return cellComment
            }
            else if indexPath.row == 4{
                cellDocument.iconImage.frame = CGRectMake(5, 9, 45, 57)
                cellDocument.iconImage.image = UIImage(named: "document")
                cellDocument.selectionStyle = UITableViewCellSelectionStyle.None
                cellDocument.featureDescriptionLabel.frame = CGRectMake(55, 5, cellUnlimited.frame.width - 65, 75)
                cellDocument.featureDescriptionLabel.text = "Save drafts so you don't lose unsaved ideas."
                cellDocument.featureDescriptionLabel.font = UIFont(name: "Avenir", size: 13)
                cellDocument.featureDescriptionLabel.numberOfLines = 0
                return cellDocument
            }else{
                return cell
            }
            
        }else{
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return productsArray.count
        }else if tableView == self.descriptionTable{
            return 5
        }else{
            return 0
        }
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
            isPurchasing = true
        }else{
            println("You Must Login To Buy")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func startActivityIndicator(){
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRectMake(self.view.frame.width/2 - 25, tableView.frame.minY - 15, 50, 50)
        tableView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator(){
        
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func startBuyActivityIndicator(){
        buyActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        buyActivityIndicator.hidesWhenStopped = true
        buyActivityIndicator.backgroundColor = fiftyGrayColor
        buyActivityIndicator.layer.cornerRadius = 5
        buyActivityIndicator.frame = CGRectMake(self.view.frame.width/2 - 75, self.view.frame.height/2 - 75, 150, 150)
        self.view.addSubview(buyActivityIndicator)
        buyActivityIndicator.startAnimating()
    }
    
    func stopBuyActivityIndicator(){
        buyActivityIndicator.stopAnimating()
    }
}
