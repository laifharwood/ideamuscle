//
//  TopicGlobal.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/29/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI


func topicQueryGlobal(daysInPast: Int, query: PFQuery){
    query.orderByAscending("createdAt")
    query.orderByDescending("numberOfIdeas")
    query.limit = 100
    query.whereKey("isPublic", equalTo: true)
    query.includeKey("creator")
    getTopicToHideGlobal(query)
    if daysInPast < 0{
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let timeZone = NSTimeZone(abbreviation: "GMT")
        calendar.timeZone = timeZone!
        let components = NSDateComponents()
        components.day = daysInPast
        let oneDayAgo = calendar.dateByAddingComponents(components, toDate: now, options: nil)
        query.whereKey("createdAt", greaterThanOrEqualTo: oneDayAgo!)
    }
}

func getTopicToHideGlobal(query: PFQuery){
    if let currentUser = PFUser.currentUser(){
        if let topicsToHideId = currentUser["topicsToHideId"] as? [String]{
            query.whereKey("objectId", notContainedIn: topicsToHideId)
        }
    }
}

func hideAndReportTopicGlobal(topicObjects: [PFObject], sender: UIButton, senderSelf: AnyObject, hideTopic: (UIButton) -> ()){
    let reportVC = ReportAbuseViewController()
    reportVC.activeTopic = topicObjects[sender.tag]
    reportVC.isFromTopic == true
    senderSelf.navigationController?!.pushViewController(reportVC, animated: true)
    hideTopic(sender)
}

func tableViewTopicConfig(tableView: UITableView){
    tableView.rowHeight = 100
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
    tableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: "Cell")
}

func cellFrameTopic(cell: UITableViewCell, view: UIView){
    
    cell.frame = CGRectMake(0, 0, view.frame.width, 100)
    
}

func numberOfIdeasGlobal(topicObjects: [PFObject], indexPath: NSIndexPath, ideaTotalButton: UIButton, cell: UITableViewCell){
    var numberOfIdeas = Int()
    
    if let numberOfIdeas = topicObjects[indexPath.row]["numberOfIdeas"] as? Int{
        let abbreviatedNumber = abbreviateNumber(numberOfIdeas) as String
        ideaTotalButton.setTitle(abbreviatedNumber, forState: .Normal)
    }else{
        ideaTotalButton.setTitle("0", forState: .Normal)
    }
    
    if let id = topicObjects[indexPath.row].objectId{
    
        ideaTotalButton.frame =  CGRectMake(cell.frame.maxX - (40 + 10), 20, 40, cell.frame.height - 40)
        ideaTotalButton.layer.cornerRadius = 3.0
        ideaTotalButton.layer.borderColor = oneFiftyGrayColor.CGColor
        ideaTotalButton.backgroundColor = oneFiftyGrayColor
        ideaTotalButton.layer.borderWidth = 1
        ideaTotalButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        ideaTotalButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        ideaTotalButton.tag = indexPath.row
    }
}

func ideaTitleLabelGlobal(ideaTitleLabel: UILabel, ideaTotalButton: UIButton){
    ideaTitleLabel.frame = CGRectMake(ideaTotalButton.frame.minX + 2, ideaTotalButton.frame.maxY - 20, 38, 15)
    ideaTitleLabel.text = "Ideas"
    ideaTitleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)
    ideaTitleLabel.textColor = UIColor.whiteColor()
    ideaTitleLabel.textAlignment = .Center
}

func topicLabelForTopic(topicObjects: [PFObject], cell: UITableViewCell, ideaTotalButton: UIButton, topicLabel: UILabel, indexPath: NSIndexPath){
    var labelWidth = cell.frame.width - ideaTotalButton.frame.width - 25
    topicLabel.frame = CGRectMake(10, 10, labelWidth, 40)
    topicLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
    topicLabel.numberOfLines = 2
    topicLabel.textColor = UIColor.blackColor()
    
    if topicObjects[indexPath.row]["title"] != nil{
        
        topicLabel.text = topicObjects[indexPath.row]["title"] as? String
    
    }
    
    topicLabel.tag = indexPath.row
}

func profileButtonTopicGlobal(topicObjects: [PFObject], indexPath: NSIndexPath, profileButton: PFImageView){
    
    var pfUser = PFUser()
    if topicObjects[indexPath.row]["creator"] != nil{
        pfUser = topicObjects[indexPath.row]["creator"] as! PFUser
        if PFUser.currentUser() == pfUser{
            profileButton.layer.borderColor = redColor.CGColor
            profileButton.layer.borderWidth = 2
        }else{
            profileButton.layer.borderColor = UIColor.whiteColor().CGColor
            profileButton.layer.borderWidth = 0
        }
        
        getAvatar(pfUser, nil, profileButton)
        
    }
    profileButton.tag = indexPath.row
    profileButton.userInteractionEnabled = true
    profileButton.frame = CGRectMake(10, 55, 40, 40)
    profileButton.layer.cornerRadius = 20
    profileButton.layer.masksToBounds = true
}

func usernameTopicGlobal(usernameLabel: UILabel, indexPath: NSIndexPath, topicObjects: [PFObject], profileButton: PFImageView){
    var usernameLabelWidth = CGFloat()
    usernameLabelWidth = 190
    usernameLabel.frame = CGRectMake(profileButton.frame.maxX + 2, profileButton.frame.maxY - profileButton.frame.height/2, usernameLabelWidth, 20)
    usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
    usernameLabel.textColor = twoHundredGrayColor
    if topicObjects[indexPath.row]["creator"] != nil{
        let pfUser = topicObjects[indexPath.row]["creator"] as! PFUser
        let username = pfUser["username"] as! String
        usernameLabel.text = username
    }
    usernameLabel.tag = indexPath.row
}

func timeStampTopicGlobal(topicObjects: [PFObject], timeStamp: UILabel, ideaTotalButton: UIButton, indexPath: NSIndexPath, cell: UITableViewCell){
    var createdAt = NSDate()
    
    if topicObjects[indexPath.row].createdAt != nil{
        createdAt = topicObjects[indexPath.row].createdAt!
        timeStamp.text = createdAt.timeAgoSimple
    }
    timeStamp.frame = CGRectMake(cell.frame.maxX - 60, ideaTotalButton.frame.maxY + 3, 50, 20)
    timeStamp.font = UIFont(name: "Avenir", size: 10)
    timeStamp.textColor = oneFiftyGrayColor
    timeStamp.textAlignment = NSTextAlignment.Right

}

