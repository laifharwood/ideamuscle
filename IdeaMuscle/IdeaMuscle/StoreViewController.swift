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
    let productIdentifiers = Set(["Pro_One_Month"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(StoreTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(tableView)
        
        requestProductData()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        

       
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
            
            if let user = PFUser.currentUser(){
                user.fetch()
                user["isPro"] = true
                let calendar = NSCalendar.currentCalendar()
                let components = NSDateComponents()
                components.month = 1
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
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        var products = response.products
        
        if products.count != 0 {
            for product in products{
                let productFinal = product as? SKProduct
                productsArray.append(productFinal!)
            }
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
    
    func requestProductData()
    {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! StoreTableViewCell
        
        if productsArray[indexPath.row].localizedTitle != nil{
            
            cell.textLabel!.text = productsArray[indexPath.row].localizedTitle
            
            cell.buyButton.backgroundColor = redColor
            cell.buyButton.setTitle("Buy", forState: .Normal)
            cell.buyButton.frame = CGRectMake(cell.frame.maxX - 65, 5, 60, cell.frame.height - 10)
            cell.buyButton.addTarget(self, action: "buy:", forControlEvents: .TouchUpInside)
            cell.buyButton.tag = indexPath.row
            
        }

        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func buy(sender: UIButton!){
        if PFUser.currentUser() != nil{
            let payment = SKPayment(product: productsArray[sender.tag])
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }else{
            println("You Must Login To Buy")
        }
    }
    


}
