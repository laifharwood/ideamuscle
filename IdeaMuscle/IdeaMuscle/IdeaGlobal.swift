//
//  IdeaGlobal.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/29/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import Parse
import UIKit
import ParseUI


func ideaQueryGlobal(daysInPast: Int, query: PFQuery){
    
    query.orderByAscending("createdAt")
    query.orderByDescending("numberOfUpvotes")
    query.limit = 100
    query.whereKey("isPublic", equalTo: true)
    query.includeKey("owner")
    query.includeKey("usersWhoUpvoted")
    query.includeKey("topicPointer")

    if daysInPast < 0{
    let now = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let timeZone = NSTimeZone(abbreviation: "GMT")
    calendar.timeZone = timeZone!
    let components = NSDateComponents()
    components.day = daysInPast
    let dateInPast = calendar.dateByAddingComponents(components, toDate: now, options: nil)
    query.whereKey("createdAt", greaterThanOrEqualTo: dateInPast!)
    }
}

func tableViewIdeaConfig(tableView: UITableView){
    
    tableView.rowHeight = 150
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
    tableView.registerClass(IdeaTableViewCell.self, forCellReuseIdentifier: "Cell")
    
}

func cellFrame(cell: UITableViewCell, view: UIView){
    
    cell.frame = CGRectMake(0, 0, view.frame.width, 150)
}

func topicLabelGlobal(labelWidth: CGFloat, topicLabel: UILabel, ideaObjects: [PFObject], row: Int){
topicLabel.frame = CGRectMake(10, 5, labelWidth, 20)
topicLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
topicLabel.numberOfLines = 1
topicLabel.textColor = UIColor.blackColor()
    
    if ideaObjects[row]["topicPointer"] != nil{
        let topic = ideaObjects[row]["topicPointer"] as! PFObject
        if let text = topic["title"] as? String{
            topicLabel.text = text
        }
    }
    
topicLabel.tag = row
}

func ideaLabelGlobal(labelWidth: CGFloat, ideaLabel: UILabel, ideaObjects: [PFObject], row: Int, topicLabel: UILabel){
    ideaLabel.numberOfLines = 0
    ideaLabel.frame = CGRectMake(25, topicLabel.frame.maxY + 2, labelWidth - 15, 70)
    ideaLabel.font = UIFont(name: "Avenir-Light", size: 10)
    ideaLabel.textColor = oneFiftyGrayColor
    if ideaObjects[row]["content"] != nil{
        ideaLabel.text = (ideaObjects[row]["content"] as! String)
    }
}

func getUpvotes(idea: PFObject, button: UIButton, cell: UITableViewCell?) -> Bool{
    var numberOfUpvotes = Int()
    var hasUpvoted = Bool()
    numberOfUpvotes = idea["numberOfUpvotes"] as! Int
    let numberString = abbreviateNumber(numberOfUpvotes)
    button.setTitle(numberString as String, forState: .Normal)
    if let currentUser = PFUser.currentUser(){
        if idea.objectForKey("usersWhoUpvoted")?.containsObject(currentUser) == true{
            button.setTitleColor(redColor, forState: .Normal)
            button.tintColor = redColor
            hasUpvoted = true
        }else{
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.tintColor = UIColor.whiteColor()
            hasUpvoted = false
        }
        if cell != nil{
            button.frame =  CGRectMake(cell!.frame.maxX - (40) - 10, cell!.frame.height/2 - 30, 40, 60)
        }
        let image = UIImage(named: "upvoteArrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 10)
        button.setImage(image, forState: .Normal)
        let spacing = CGFloat(20)
        let imageSize = button.imageView!.image!.size
        let titleSize = button.titleLabel!.frame.size
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(-45, 0.0, 0.0, -titleSize.width)
        button.layer.cornerRadius = 3
        button.backgroundColor = oneFiftyGrayColor
        
    }else{
        button.setTitle("0", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    if hasUpvoted == true{
        return true
    }else{
        return false
    }
}

func profileButtonGlobal(ideaObjects: [PFObject], row: Int, profileButton: PFImageView){
    
    var pfUser = PFUser()
    if ideaObjects[row]["owner"] != nil{
        pfUser = ideaObjects[row]["owner"] as! PFUser
        if PFUser.currentUser() == pfUser{
            profileButton.layer.borderColor = redColor.CGColor
            profileButton.layer.borderWidth = 2
        }else{
            profileButton.layer.borderColor = UIColor.whiteColor().CGColor
            profileButton.layer.borderWidth = 0
        }
        
        getAvatar(pfUser, nil, profileButton)
        
    }
    profileButton.tag = row
    profileButton.userInteractionEnabled = true
    profileButton.frame = CGRectMake(10, 105, 40, 40)
    profileButton.layer.cornerRadius = 20
    profileButton.layer.masksToBounds = true
}

func usernameGlobal(usernameLabel: UILabel, row: Int, ideaObjects: [PFObject], profileButton: PFImageView){
    var usernameLabelWidth = CGFloat()
    usernameLabelWidth = 190
    usernameLabel.frame = CGRectMake(profileButton.frame.maxX + 2, profileButton.frame.maxY - profileButton.frame.height/2, usernameLabelWidth, 20)
    usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
    usernameLabel.textColor = twoHundredGrayColor
    if ideaObjects[row]["owner"] != nil{
        let user = ideaObjects[row]["owner"] as! PFUser
        let username = user["username"] as! String
        usernameLabel.text = username
    }
    usernameLabel.tag = row
}

func timeStampGlobal(ideaObjects: [PFObject], timeStamp: UILabel, row: Int, usernameLabel: UILabel, cell: UITableViewCell){
    var createdAt = NSDate()
    
    if ideaObjects[row].createdAt != nil{
        createdAt = ideaObjects[row].createdAt!
        timeStamp.text = createdAt.timeAgoSimple
    }
    timeStamp.frame = CGRectMake(cell.frame.maxX - 30, usernameLabel.frame.minY, 20, 20)
    timeStamp.font = UIFont(name: "Avenir", size: 10)
    timeStamp.textColor = oneFiftyGrayColor
    timeStamp.textAlignment = NSTextAlignment.Right
}

func startActivityGlobal(activityIndicatorContainer: UIView, activityIndicator: UIActivityIndicatorView, view: UIView){
    activityIndicatorContainer.frame = CGRectMake(0, 0, view.frame.width, 50)
    activityIndicatorContainer.backgroundColor = UIColor.whiteColor()
    activityIndicatorContainer.hidden = false
    view.addSubview(activityIndicatorContainer)
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    activityIndicator.hidesWhenStopped = true
    activityIndicator.frame = CGRectMake(0, 0, view.frame.width, 1000)
    activityIndicator.center = activityIndicatorContainer.center
    activityIndicatorContainer.addSubview(activityIndicator)
    activityIndicator.startAnimating()
}

func composeFromDetail(sender: AnyObject!, activeTopic: PFObject){
    
    if let user = PFUser.currentUser(){
        if let hasPosted = user["hasPosted"] as? Bool{
            if hasPosted == false{
               presentCompose(sender, activeTopic)
            }
        }else{
            presentCompose(sender, activeTopic)        }
        
        if let isPro = user["isPro"] as? Bool{
            if isPro{
                presentCompose(sender, activeTopic)
            }else{
                notProCheckIfCanPostFromDetail(user, sender, activeTopic)
            }
        }else{
            notProCheckIfCanPostFromDetail(user, sender, activeTopic)
        }
    }
}

func presentCompose(sender: AnyObject!, activeTopic: PFObject){
    let composeVC = ComposeViewController()
    composeVC.activeComposeTopicObject = activeTopic
    sender.presentViewController(composeVC, animated: true, completion: nil)
}

func notProCheckIfCanPostFromDetail(user: PFUser, sender: AnyObject!, activeTopic: PFObject){
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
                                    presentCompose(sender, activeTopic)
                                }else{
                                    //Prompt For Upgrade
                                    let upgradeAlert: UIAlertController = UIAlertController(title: "You must upgrade to do that.", message: "As a free user you are limited to composing once every two days. Upgrade to Pro to compose unlimited ideas and topics.", preferredStyle: .Alert)
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
