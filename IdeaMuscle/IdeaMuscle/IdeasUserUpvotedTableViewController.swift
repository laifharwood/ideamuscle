//
//  IdeasUserUpvotedTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/23/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI


class IdeasUserUpvotedTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var upvoteObjects = [PFObject(className: "Upvote")]
    var ideaObjects = [PFObject(className: "Idea")]
    var query = PFQuery(className: "Upvote")
    var hasUpvoted = [Bool](count: 1000, repeatedValue: false)
    var shouldReloadTable = false
    
    
    func queryForUpvoteObjects(){
        if let currentUser = PFUser.currentUser(){
            query.whereKey("userWhoUpvoted", equalTo: currentUser)
            query.includeKey("ideaUpvoted.topicPointer")
            query.includeKey("ideaUpvoted.owner")
            query.limit = 1000
            query.orderByAscending("createdAt")
            query.findObjectsInBackgroundWithTarget(self, selector: "upvoteSelector:error:")
        }
    }
    
    func queryIdeaObjects(){
        if let currentUser = PFUser.currentUser(){
            ideaObjects = []
            for object in upvoteObjects{
                var idea = PFObject(className: "Idea")
                if let idea = object["ideaUpvoted"] as? PFObject{
                    if idea.objectId != nil{
                        if let ideaOwner = idea["owner"] as? PFUser{
                            if ideaOwner != currentUser{
                                ideaObjects.append(idea)
                            }
                        }
                    }
                }
                
            }
            stopActivityIndicator()
        }
    }
    
    func upvoteSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            self.upvoteObjects = objects as! [PFObject]
            self.queryIdeaObjects()
        }else{
            println("Error: \(error.userInfo)")
        }
        //stopActivityIndicator()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if shouldReloadTable == true{
            tableView.reloadData()
            shouldReloadTable == false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ideas You've Upvoted"
        
        tableViewIdeaConfig(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        startActivityIndicator()
        queryForUpvoteObjects()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideaObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! IdeaTableViewCell
        
        //cell.frame = CGRectMake(0, 0, self.view.frame.width, 150)
        cellFrame(cell, self.view)
        
        //MARK: - Number Of Upvotes Button Config
        if ideaObjects[indexPath.row]["numberOfUpvotes"] != nil{
            let idea = ideaObjects[indexPath.row]
            hasUpvoted[indexPath.row] = getUpvotes(idea, cell.numberOfUpvotesButton, cell)
        }
        cell.numberOfUpvotesButton.tag = indexPath.row
        cell.numberOfUpvotesButton.addTarget(self, action: "upvote:", forControlEvents: .TouchUpInside)
        
        //MARK: - Topic Label Config
        var labelWidth = cell.frame.width - cell.numberOfUpvotesButton.frame.width - 25
        topicLabelGlobal(labelWidth, cell.topicLabel, ideaObjects, indexPath.row)
        
        
        //MARK: - Idea Label Config
        ideaLabelGlobal(labelWidth, cell.ideaLabel, ideaObjects, indexPath.row, cell.topicLabel)
        
        //MARK: - Profile Button
        profileButtonGlobal(ideaObjects, indexPath.row, cell.profileButton)
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.profileButton.addGestureRecognizer(gestureRec)
        
        //MARK: - Username Label Config
        usernameGlobal(cell.usernameLabel, indexPath.row, ideaObjects, cell.profileButton)
        
        //MARK: - TimeStamp
        timeStampGlobal(ideaObjects, cell.timeStamp, indexPath.row, cell.usernameLabel, cell)
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let ideaDetailVC = IdeaDetailViewController()
        shouldReloadTable = true
        if ideaObjects[indexPath.row]["topicPointer"] != nil{
            let passingIdea = ideaObjects[indexPath.row]
            let passingTopic = ideaObjects[indexPath.row]["topicPointer"] as! PFObject
            passingTopic.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                if error == nil{
                    ideaDetailVC.activeIdea = passingIdea
                    ideaDetailVC.activeTopic =  passingTopic
                    self.navigationController?.pushViewController(ideaDetailVC, animated: true)
                }
            })
        }
    }
    
    
    func upvote(sender: UIButton!){
        
        let ideaObject = ideaObjects[sender.tag]
        
        if hasUpvoted[sender.tag] == true{
            //Remove Upvote
            upvoteGlobal(ideaObject, false, sender)
            hasUpvoted[sender.tag] = false
        }else{
            //Add Upvote
            upvoteGlobal(ideaObject, true, sender)
            hasUpvoted[sender.tag] = true
        }
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
    
    func profileTapped(sender: AnyObject){
        let profileVC = ProfileViewController()
        if ideaObjects[sender.view!.tag]["owner"] != nil{
            profileVC.activeUser = ideaObjects[sender.view!.tag]["owner"] as! PFUser
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
