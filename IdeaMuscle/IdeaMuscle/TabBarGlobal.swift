//
//  TabBarGlobal.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/14/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import Parse
import UIKit

func composeOriginalGlobal(sender: AnyObject!){
    
    if let user = PFUser.currentUser(){
        if let hasPosted = user["hasPosted"] as? Bool{
            if hasPosted == false{
                println("has not posted")
                let composeTopicVC = ComposeTopicViewController()
                sender.presentViewController(composeTopicVC, animated: true, completion: nil)
            }
        }else{
            println("has posted is nil")
            let composeTopicVC = ComposeTopicViewController()
            sender.presentViewController(composeTopicVC, animated: true, completion: nil)        }
        
        if let isPro = user["isPro"] as? Bool{
            if isPro{
                println("is Pro")
                let composeTopicVC = ComposeTopicViewController()
                sender.presentViewController(composeTopicVC, animated: true, completion: nil)
            }else{
                notProCheckIfCanPost(user, sender)
            }
        }else{
            notProCheckIfCanPost(user, sender)
        }
    }
}

func notProCheckIfCanPost(user: PFUser, sender: AnyObject!){
    let lastPostedQuery = PFQuery(className: "LastPosted")
    lastPostedQuery.whereKey("userPointer", equalTo: user)
    lastPostedQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
        if error == nil{
            var lastPostedDate = NSDate()
            let lastPostedObject = object as PFObject!
            lastPostedDate = lastPostedObject.updatedAt!
            let components = NSDateComponents()
            components.day = 1
            let calender = NSCalendar.currentCalendar()
            let canPostDate = calender.dateByAddingComponents(components, toDate: lastPostedDate, options: nil)
            let nowQuery = PFQuery(className: "TimeNow")
            nowQuery.getObjectInBackgroundWithId("yhUEKpyRSg", block: { (nowObject, error) -> Void in
                let nowDateObject = nowObject as PFObject!
                nowDateObject.incrementKey("update")
                nowDateObject.saveInBackgroundWithBlock({(success, error) -> Void in
                    if success{
                        nowDateObject.fetchInBackgroundWithBlock({(nowDateObject, error) -> Void in
                            if nowDateObject != nil{
                                var now = NSDate()
                                now = nowDateObject!.updatedAt!
                                if now.isGreaterThanDate(canPostDate!){
                                    let composeTopicVC = ComposeTopicViewController()
                                    sender.presentViewController(composeTopicVC, animated: true, completion: nil)
                                }else{
                                    //Prompt For Upgrade
                                    let upgradeAlert: UIAlertController = UIAlertController(title: "You must upgrade.", message: "As a free user you are limited to composing once every two days. Upgrade to Pro to compose unlimited ideas and topics.", preferredStyle: .Alert)
                                    //Create and add the Cancel action
                                    let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                                    }
                                    upgradeAlert.addAction(cancelAction)
                                    
                                    let goToStore: UIAlertAction = UIAlertAction(title: "Go To Store", style: .Default, handler: { (action) -> Void in
                                        let storeVC = StoreViewController()
                                        sender.navigationController!!.pushViewController(storeVC, animated: true)
                                        
                                    })
                                    
                                    upgradeAlert.addAction(goToStore)
                                    sender.presentViewController(upgradeAlert, animated: true, completion: nil)
                                }
                            }
                        })
                    }
                })
            })
        }
    })
}


