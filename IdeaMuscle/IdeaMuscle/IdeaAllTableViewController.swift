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

class IdeaAllTableViewController: UITableViewController{
    
    var activityIndicator = UIActivityIndicatorView()
    var ideaObjects = [PFObject(className: "Idea")]
    let activityIndicatorContainer = UIView()
    let refreshTable = UIRefreshControl()
    var hasUpvoted = [Bool](count: 100, repeatedValue: false)
    var shouldReloadTable = false
    let reportViewContainer = UIView()
    let invisibleView = UIView()
    
    var tableSelection = UIView()
    var periodSelection = UIView()
    var hiddenHeight = CGFloat()
    var shownHeight = CGFloat()
    var pointNow = CGPoint()
    
    
    func queryForIdeaObjects(){
        let query = PFQuery(className: "Idea")
        ideaQueryGlobal(0, query: query)
        query.findObjectsInBackgroundWithTarget(self, selector: "ideaSelector:error:")
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
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
        
        if shouldReloadTable == true{
            tableView.reloadData()
            shouldReloadTable == false
        }
        
        hiddenHeight = self.view.frame.height + 50
        shownHeight = self.view.frame.height
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
        
        longPressToTableViewGlobal(self, tableView: tableView, reportViewContainer: reportViewContainer)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! IdeaTableViewCell
        
        //cell.frame = CGRectMake(0, 0, self.view.frame.width, 150)
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let ideaDetailVC = IdeaDetailViewController()
        shouldReloadTable = true
        if ideaObjects[indexPath.row]["topicPointer"] != nil{
            let passingIdea = ideaObjects[indexPath.row]
            let passingTopic = ideaObjects[indexPath.row]["topicPointer"] as! PFObject
            passingTopic.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                ideaDetailVC.activeIdea = passingIdea
                ideaDetailVC.activeTopic =  passingTopic
                self.navigationController?.pushViewController(ideaDetailVC, animated: true)
            })
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        hideFilterGlobal(scrollView, pointNow: pointNow, tableSelection: tableSelection, periodSelection: periodSelection, tableView: tableView, view: self.view, shownHeight: shownHeight, navigationController: self.navigationController!, hiddenHeight: hiddenHeight)
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
    
    func startActivityIndicator(){
        
        startActivityGlobal(activityIndicatorContainer, activityIndicator: activityIndicator, view: self.view)
        
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
