//
//  TopicTodayTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/16/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class IdeaAllTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var ideaObjects = [PFObject(className: "Idea")]
    let activityIndicatorContainer = UIView()
    let refreshTable = UIRefreshControl()
    var hasUpvoted = [Bool](count: 100, repeatedValue: false)
    var shouldReloadTable = false
    let reportViewContainer = UIView()
    let invisibleView = UIView()
    
    
    func queryForIdeaObjects(){
        var query = PFQuery(className: "Idea")
        ideaQueryGlobal(0, query)
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
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
        
        if shouldReloadTable == true{
            tableView.reloadData()
            shouldReloadTable == false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewIdeaConfig(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        startActivityIndicator()
        queryForIdeaObjects()
        refreshTable.attributedTitle = NSAttributedString(string: "")
        refreshTable.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshTable)
        
        longPressToTableViewGlobal(self, tableView, reportViewContainer)
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
    
    func cellLongPress(sender: UILongPressGestureRecognizer){
        cellLongPressGlobal(sender, tableView, self, self.reportViewContainer, self.invisibleView)
    }
    
    func hideIdea(sender: UIButton){
        
        let row = sender.tag
        if let currentUser = PFUser.currentUser(){
            let idea = ideaObjects[row]
            currentUser.addObject(idea.objectId!, forKey: "ideasToHideId")
            currentUser.saveEventually()
        }
        
        hideInvisibleAndReportView(invisibleView, self, reportViewContainer)
        ideaObjects.removeAtIndex(row)
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        let pathArray = [indexPath]
        tableView.deleteRowsAtIndexPaths(pathArray, withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
    func hideAndReport(sender: UIButton){
        hideAndReportGlobal(ideaObjects, sender, self, self.hideIdea)
    }
    
    func cancelHide(sender: UIButton){
        
        hideInvisibleAndReportView(invisibleView, self, reportViewContainer)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let ideaDetailVC = IdeaDetailViewController()
        if ideaObjects[indexPath.row]["topicPointer"] != nil{
            let passingIdea = ideaObjects[indexPath.row]
            let passingTopic = ideaObjects[indexPath.row]["topicPointer"] as! PFObject
            ideaDetailVC.activeIdea = passingIdea
            ideaDetailVC.activeTopic =  passingTopic
            shouldReloadTable = true
            self.navigationController?.pushViewController(ideaDetailVC, animated: true)
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
        
        startActivityGlobal(activityIndicatorContainer, activityIndicator, self.view)
        
    }
    
    func stopActivityIndicator(){
        
        activityIndicator.stopAnimating()
        activityIndicatorContainer.removeFromSuperview()
        tableView.hidden = false
        tableView.reloadData()
    }
    
    func profileTapped(sender: AnyObject){
        let profileVC = ProfileViewController()
        if ideaObjects[sender.view!.tag]["owner"] != nil{
            profileVC.activeUser = ideaObjects[sender.view!.tag]["owner"] as! PFUser
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func refresh(sender:AnyObject)
    {
        queryForIdeaObjects()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
