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

class TopicAllTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var topicObjects = [PFObject(className: "Topic")]
    let activityIndicatorContainer = UIView()
    let refreshTable = UIRefreshControl()
    let reportViewContainer = UIView()
    let invisibleView = UIView()
    
    
    func queryForTopicObjects(){
        var query = PFQuery(className: "Topic")
        topicQueryGlobal(0, query)
        query.findObjectsInBackgroundWithTarget(self, selector: "topicSelector:error:")
    }
    
    func topicSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            //topicObjects = []
            topicObjects = objects as! [PFObject]
        }else{
            println("Error: \(error.userInfo)")
        }
        stopActivityIndicator()
        refreshTable.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController!.tabBar.hidden = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewTopicConfig(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        startActivityIndicator()
        queryForTopicObjects()
        
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
        return topicObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TopicTableViewCell
        
        cellFrameTopic(cell, self.view)
        
        //MARK: - Idea Total Button Config
        numberOfIdeasGlobal(topicObjects, indexPath, cell.ideaTotalButton, cell)
        cell.ideaTotalButton.addTarget(self, action: "viewIdeas:", forControlEvents: .TouchUpInside)
        
        //MARK: - Idea Title Label
        ideaTitleLabelGlobal(cell.ideaTitleLabel, cell.ideaTotalButton)
        
        //MARK: - Topic Label Config
        topicLabelForTopic(topicObjects, cell, cell.ideaTotalButton, cell.topicLabel, indexPath)
        
        //MARK: - Profile Button
        profileButtonTopicGlobal(topicObjects, indexPath, cell.profileButton)
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.profileButton.addGestureRecognizer(gestureRec)
        
        //MARK: - Username Label Config
        usernameTopicGlobal(cell.usernameLabel, indexPath, topicObjects, cell.profileButton)
        
        //MARK: - Time Stamp
        timeStampTopicGlobal(topicObjects, cell.timeStamp, cell.ideaTotalButton, indexPath, cell)
        
        return cell
        
    }
    
    func cellLongPress(sender: UILongPressGestureRecognizer){
        cellLongPressGlobal(sender, tableView, self, self.reportViewContainer, self.invisibleView)
    }
    
    func hideIdea(sender: UIButton){
        //Is really hide topic in this case but used hideIdea cuz it was already created for ideas
        let row = sender.tag
        if let currentUser = PFUser.currentUser(){
            let topic = topicObjects[row]
            currentUser.addObject(topic.objectId!, forKey: "topicsToHideId")
            currentUser.addObject(topic, forKey: "topicsToHide")
            currentUser.saveEventually()
        }
        
        hideInvisibleAndReportView(invisibleView, self, reportViewContainer)
        topicObjects.removeAtIndex(row)
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        let pathArray = [indexPath]
        tableView.deleteRowsAtIndexPaths(pathArray, withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
    func hideAndReport(sender: UIButton){
        hideAndReportTopicGlobal(topicObjects, sender, self, self.hideIdea)
    }
    
    func cancelHide(sender: UIButton){
        
        hideInvisibleAndReportView(invisibleView, self, reportViewContainer)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let topicDetailVC = TopicsDetailViewController()
        topicDetailVC.activeTopic = topicObjects[indexPath.row]
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
        
    }
    
    
    func viewIdeas(sender: UIButton!){
        let topicDetailVC = TopicsDetailViewController()
        topicDetailVC.activeTopic = topicObjects[sender.tag]
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
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
        if topicObjects[sender.view!.tag]["creator"] != nil{
            profileVC.activeUser = topicObjects[sender.view!.tag]["creator"] as! PFUser
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func refresh(sender:AnyObject)
    {
        queryForTopicObjects()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
