//
//  FeedViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/5/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var activityIndicator = UIActivityIndicatorView()
    var ideaObjects = [PFObject(className: "Idea")]
    let activityIndicatorContainer = UIView()
    let refreshTable = UIRefreshControl()
    var hasUpvoted = [Bool](count: 200, repeatedValue: false)
    var shouldReloadTable = false
    var tableView = UITableView()
    var followingObjects = [PFObject(className: "following")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startActivityIndicator()
        followingQuery()
        
        tableViewIdeaConfig(tableView)
        tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 64)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        startActivityIndicator()
        queryForIdeaObjects()
        refreshTable.attributedTitle = NSAttributedString(string: "")
        refreshTable.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshTable)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.title = "Feed"
        
        //Right Compose Button
        let composeOriginalButton = UIButton()
        let composeOriginalImage = UIImage(named: "ComposeWhite.png")
        composeOriginalButton.setImage(composeOriginalImage, forState: .Normal)
        composeOriginalButton.frame = CGRectMake(self.view.frame.width - 38, 25, 24.7, 25)
        composeOriginalButton.addTarget(self, action: "composeOriginal:", forControlEvents: .TouchUpInside)
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: composeOriginalButton)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false);
        
        //MARK: - Left Small Logo
        
        let leftLogoView = UIImageView(image: smallLogo)
        leftLogoView.frame = CGRectMake(10, 25, 35, 35)
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: leftLogoView)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        

    }
    
    override func viewWillAppear(animated: Bool) {
        if shouldReloadTable == true{
            tableView.reloadData()
            shouldReloadTable == false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return ideaObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! IdeaTableViewCell
        
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
    
    func startActivityIndicator(){
        
        startActivityGlobal(activityIndicatorContainer, activityIndicator, self.view)
        
    }
    
    func stopActivityIndicator(){
        
        activityIndicator.stopAnimating()
        activityIndicatorContainer.removeFromSuperview()
        tableView.hidden = false
        tableView.reloadData()
    }
    
    func followingQuery(){
        if let currentUser = PFUser.currentUser(){
            var relation = PFRelation()
            var query = PFQuery()
            query.includeKey("following")
            relation = currentUser.relationForKey("following")
            query = relation.query()!
            query.findObjectsInBackgroundWithTarget(self, selector: "followingSelector:error:")
        }
    }
    
    func followingSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            
            followingObjects = objects as! [PFObject]
            queryForIdeaObjects()
            
        }else{
            println("Error: \(error.userInfo)")
        }
    }
    
    func queryForIdeaObjects(){
        var query = PFQuery(className: "Idea")
        query.whereKey("isPublic", equalTo: true)
        
        for object in followingObjects{
            object.
            query.whereKey("owner", equalTo: user)
        }
        
        query.orderByDescending("createdAt")
        query.limit = 200
        query.findObjectsInBackgroundWithTarget(self, selector: "ideaSelector:error:")
    }
    
    func ideaSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            ideaObjects = objects as! [PFObject]
        }else{
            println("Error: \(error.userInfo)")
        }
        stopActivityIndicator()
        refreshTable.endRefreshing()
    }
    
    func refresh(sender:AnyObject)
    {
        queryForIdeaObjects()
    }
    
    

}
