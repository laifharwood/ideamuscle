//
//  UserTopicsTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/21/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class UserTopicsTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var topicObjects = [PFObject(className: "Topic")]
    let activityIndicatorContainer = UIView()
    
    
    func queryForTopicObjects(){
        if let user = PFUser.currentUser(){
            var query = PFQuery(className: "Topic")
            query.whereKey("creator", equalTo: user)
            query.orderByDescending("createdAt")
            query.limit = 1000
            query.findObjectsInBackgroundWithTarget(self, selector: "topicSelector:error:")
        }
    }
    
    func topicSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            //topicObjects = []
            topicObjects = objects as! [PFObject]
        }else{
            println("Error: \(error.userInfo)")
        }
        stopActivityIndicator()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewTopicConfig(tableView)
        self.title = "Your Topics"
        
        tableView.dataSource = self
        tableView.delegate = self
        startActivityIndicator()
        queryForTopicObjects()
    
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TopicTableViewCell
        
        cellFrameTopic(cell, self.view)
        
        
        let topic = topicObjects[indexPath.row]
        
        if let isPublic = topic["isPublic"] as? Bool{
            if isPublic{
                topicIsPublicK(topic, cell: cell, topicObjects: topicObjects, indexPath: indexPath)
            }else{
                topicIsNotPublicK(cell)
            }
        }else{
            //topicIsNotPublicK(cell)
        }
        
        
        
        //MARK: - Idea Total Button Config
        cell.ideaTotalButton.addTarget(self, action: "viewIdeas:", forControlEvents: .TouchUpInside)
        cell.ideaTotalButton.frame =  CGRectMake(cell.frame.maxX - (40 + 10), 20, 40, cell.frame.height - 40)
        cell.ideaTotalButton.layer.cornerRadius = 3.0
        cell.ideaTotalButton.layer.borderColor = oneFiftyGrayColor.CGColor
        cell.ideaTotalButton.backgroundColor = oneFiftyGrayColor
        cell.ideaTotalButton.layer.borderWidth = 1
        cell.ideaTotalButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cell.ideaTotalButton.tag = indexPath.row
            
        
        
        
        //MARK: - Idea Title Label
        cell.ideaTitleLabel.frame = CGRectMake(cell.ideaTotalButton.frame.minX + 2, cell.ideaTotalButton.frame.maxY - 20, 38, 15)
        cell.ideaTitleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)
        cell.ideaTitleLabel.textColor = UIColor.whiteColor()
        cell.ideaTitleLabel.textAlignment = .Center
        cell.ideaTitleLabel.text = "Ideas"
        
        
        //MARK: - Topic Label Config
        topicLabelForTopic(topicObjects, cell, cell.ideaTotalButton, cell.topicLabel, indexPath)
        var labelWidth = cell.frame.width - cell.ideaTotalButton.frame.width - 25
        cell.topicLabel.frame = CGRectMake(10, 5, labelWidth, cell.frame.height - 10)
        cell.topicLabel.numberOfLines = 0
        
        //MARK: - Time Stamp
        timeStampTopicGlobal(topicObjects, cell.timeStamp, cell.ideaTotalButton, indexPath, cell)
        
        return cell
        
    }
    
    func topicIsPublicK(topic: PFObject, cell: TopicTableViewCell, topicObjects: [PFObject], indexPath: NSIndexPath){
        var numberOfIdeas = Int()
        if topic["numberOfIdeas"] != nil{
            numberOfIdeas = topicObjects[indexPath.row]["numberOfIdeas"] as! Int
            let abbreviatedNumber = abbreviateNumber(numberOfIdeas) as String
            cell.ideaTotalButton.setTitle(abbreviatedNumber, forState: .Normal)
        }else{
            cell.ideaTotalButton.setTitle("0", forState: .Normal)
        }
        cell.ideaTotalButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        cell.ideaTitleLabel.hidden = false
    }
    
    func topicIsNotPublicK(cell: TopicTableViewCell){
        cell.ideaTotalButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        cell.ideaTotalButton.setTitle("Make Public", forState: .Normal)
        cell.ideaTotalButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.ideaTotalButton.titleLabel?.textAlignment = NSTextAlignment.Center
        cell.ideaTitleLabel.hidden = true
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let topicDetailVC = TopicsDetailViewController()
        topicDetailVC.activeTopic = topicObjects[indexPath.row]
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
        
    }
    
    
    func viewIdeas(sender: UIButton!){
        
        let topic = topicObjects[sender.tag]
        if let isPublic = topic["isPublic"] as? Bool{
            if isPublic{
                let topicDetailVC = TopicsDetailViewController()
                topicDetailVC.activeTopic = topic
                self.navigationController?.pushViewController(topicDetailVC, animated: true)
            }else{
                makePublic(topic, sender: sender)
            }
        }else{
            makePublic(topic, sender: sender)
        }
    }
    
    func makePublic(topic: PFObject, sender: UIButton){
        if let user = PFUser.currentUser(){
            if let isPro = user["isPro"] as? Bool{
                if isPro{
                    topic.ACL?.setPublicWriteAccess(true)
                    topic.ACL?.setPublicReadAccess(true)
                    topic["isPublic"] = true
//                    sender.setTitle("0", forState: .Normal)
//                    sender.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 15)
                    tableView.reloadData()
                    topic.saveEventually()
                }else{
                    upgradeAlert()
                }
            }else{
                upgradeAlert()
            }
        }
    }
    
    func upgradeAlert(){
        let upgradeAlert: UIAlertController = UIAlertController(title: "Upgrade Required", message: "You must upgrade to Pro to make Topics public after posting.", preferredStyle: .Alert)
        upgradeAlert.view.tintColor = redColor
        upgradeAlert.view.backgroundColor = oneFiftyGrayColor
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        upgradeAlert.addAction(cancelAction)
        
        let goToStore: UIAlertAction = UIAlertAction(title: "Go To Store", style: .Default, handler: { (action) -> Void in
            let storeVC = StoreViewController()
            let navVC = UINavigationController(rootViewController: storeVC)
            self.presentViewController(navVC, animated: true, completion: nil)
            
        })
        
        upgradeAlert.addAction(goToStore)
        self.presentViewController(upgradeAlert, animated: true, completion: nil)
    }
    
    func startActivityIndicator(){
        
        startActivityGlobal(activityIndicatorContainer, activityIndicator, self.view)
        
    }
    
    func stopActivityIndicator(){
        
        activityIndicator.stopAnimating()
        activityIndicatorContainer.removeFromSuperview()
        tableView.hidden = false
        tableView.reloadData()
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
