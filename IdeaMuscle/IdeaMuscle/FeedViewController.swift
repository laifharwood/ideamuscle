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
    var followingObjects = [PFObject(className: "following")]
    let activityIndicatorContainer = UIView()
    let refreshTable = UIRefreshControl()
    var hasUpvoted = [Bool](count: 200, repeatedValue: false)
    var shouldReloadTable = false
    var tableView = UITableView()
    var query = PFQuery()
    let reportViewContainer = UIView()
    let invisibleView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startActivityIndicator()
        followingQuery()
        
        tableViewIdeaConfig(tableView)
        tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - tabBarController!.tabBar.frame.height)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        startActivityIndicator()
        queryForIdeaObjects()
        refreshTable.attributedTitle = NSAttributedString(string: "")
        refreshTable.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshTable)
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.title = "Feed"
        
        //Right Compose Button
        let composeOriginalButton = UIButton()
        let composeOriginalImage = UIImage(named: "compose")
        composeOriginalButton.setImage(composeOriginalImage, forState: .Normal)
        composeOriginalButton.frame = CGRectMake(self.view.frame.width - 38, 25, 25, 25)
        composeOriginalButton.addTarget(self, action: "composeOriginal:", forControlEvents: .TouchUpInside)
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: composeOriginalButton)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false);
        
        //MARK: - Left Small Logo
        let leftLogoView = UIImageView(image: smallLogo)
        leftLogoView.frame = CGRectMake(10, 25, 35, 35)
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: leftLogoView)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        
        longPressToTableViewGlobal(self, tableView: tableView, reportViewContainer: reportViewContainer)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if self.tabBarController != nil{
            self.tabBarController!.tabBar.hidden = false
            updateMoreBadge(self.tabBarController!)
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! IdeaTableViewCell
        
        cellFrame(cell, view: self.view)
        
        //MARK: - Number Of Upvotes Button Config
        if ideaObjects[indexPath.row]["numberOfUpvotes"] != nil{
            let idea = ideaObjects[indexPath.row]
            hasUpvoted[indexPath.row] = getUpvotes(idea, button: cell.numberOfUpvotesButton, cell: cell)
        }
        cell.numberOfUpvotesButton.tag = indexPath.row
        cell.numberOfUpvotesButton.addTarget(self, action: "upvote:", forControlEvents: .TouchUpInside)
        
        //MARK: - Topic Label Config
        let labelWidth = cell.frame.width - cell.numberOfUpvotesButton.frame.width - 25
        topicLabelGlobal(labelWidth, topicLabel: cell.topicLabel, ideaObjects: ideaObjects, row: indexPath.row)
        
        
        
        //MARK: - Idea Label Config
        ideaLabelGlobal(labelWidth, ideaLabel: cell.ideaLabel, ideaObjects: ideaObjects, row: indexPath.row, topicLabel: cell.topicLabel)
        
        //MARK: - Profile Button
        profileButtonGlobal(ideaObjects, row: indexPath.row, profileButton: cell.profileButton)
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.profileButton.addGestureRecognizer(gestureRec)
        
        
        
        //MARK: - Username Label Config
        usernameGlobal(cell.usernameLabel, row: indexPath.row, ideaObjects: ideaObjects, profileButton: cell.profileButton)
        
        //MARK: - TimeStamp
        timeStampGlobal(ideaObjects, timeStamp: cell.timeStamp, row: indexPath.row, usernameLabel: cell.usernameLabel, cell: cell)
        
        
        
        return cell
    }
    
    func cellLongPress(sender: UILongPressGestureRecognizer){
        cellLongPressGlobal(sender, tableView: tableView, senderSelf: self, reportViewContainer: self.reportViewContainer, invisibleView: self.invisibleView)
    }
    
    func hideIdea(sender: UIButton){
        
        let row = sender.tag
        if let currentUser = PFUser.currentUser(){
            let idea = ideaObjects[row]
            currentUser.addObject(idea.objectId!, forKey: "ideasToHideId")
            currentUser.saveEventually()
        }
        
        hideInvisibleAndReportView(invisibleView, sender: self, reportViewContainer: reportViewContainer)
        ideaObjects.removeAtIndex(row)
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        let pathArray = [indexPath]
        tableView.deleteRowsAtIndexPaths(pathArray, withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
    func hideAndReport(sender: UIButton){
        hideAndReportGlobal(ideaObjects, sender: sender, senderSelf: self, hideIdea: self.hideIdea)
    }
    
    func cancelHide(sender: UIButton){
        
        hideInvisibleAndReportView(invisibleView, sender: self, reportViewContainer: reportViewContainer)
    }

    
    func startActivityIndicator(){
        
        activityIndicatorContainer.frame = CGRectMake(0, 75, self.view.frame.width, 1000)
        activityIndicatorContainer.backgroundColor = UIColor.whiteColor()
        activityIndicatorContainer.hidden = false
        self.view.addSubview(activityIndicatorContainer)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRectMake(0, 0, view.frame.width, 50)
        //activityIndicator.center = activityIndicatorContainer.center
        activityIndicatorContainer.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
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
            print("Error: \(error.userInfo)")
        }
    }
    
    func queryForIdeaObjects(){
        
        let ideaQuery = PFQuery(className: "Idea")
        ideaQuery.whereKey("isPublic", equalTo: true)
        ideaQuery.whereKey("owner", matchesQuery: query)
        ideaQuery.orderByDescending("createdAt")
        ideaQuery.limit = 200
        ideaQuery.cachePolicy = PFCachePolicy.NetworkElseCache
        ideaQuery.includeKey("owner")
        ideaQuery.includeKey("topicPointer")
        getIdeasToHideGlobal(ideaQuery)
        ideaQuery.findObjectsInBackgroundWithTarget(self, selector: "ideaSelector:error:")

    }
    
    func ideaSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            ideaObjects = objects as! [PFObject]
        }else{
            print("Error: \(error.userInfo)")
        }
        stopActivityIndicator()
        refreshTable.endRefreshing()
    }
    
    func refresh(sender:AnyObject)
    {
        queryForIdeaObjects()
    }
    
    func upvote(sender: UIButton!){
        
        let ideaObject = ideaObjects[sender.tag]
        
        if hasUpvoted[sender.tag] == true{
            //Remove Upvote
            upvoteGlobal(ideaObject, shouldUpvote: false, button: sender)
            hasUpvoted[sender.tag] = false
        }else{
            //Add Upvote
            upvoteGlobal(ideaObject, shouldUpvote: true, button: sender)
            hasUpvoted[sender.tag] = true
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    func profileTapped(sender: AnyObject){
        let profileVC = ProfileViewController()
        if ideaObjects[sender.view!.tag]["owner"] != nil{
            profileVC.activeUser = ideaObjects[sender.view!.tag]["owner"] as! PFUser
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func composeOriginal(sender: UIButton!){
        
        //composeOriginalGlobal(self)
        composeFromDetail(self, activeTopic: nil, isNewTopic: true)
    }
    
    

}
