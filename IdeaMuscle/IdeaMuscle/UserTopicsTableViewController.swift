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
            query.orderByAscending("createdAt")
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
        
        //MARK: - Idea Total Button Config
        numberOfIdeasGlobal(topicObjects, indexPath, cell.ideaTotalButton, cell)
        cell.ideaTotalButton.addTarget(self, action: "viewIdeas:", forControlEvents: .TouchUpInside)
        
        //MARK: - Idea Title Label
        ideaTitleLabelGlobal(cell.ideaTitleLabel, cell.ideaTotalButton)
        
        //MARK: - Topic Label Config
        topicLabelForTopic(topicObjects, cell, cell.ideaTotalButton, cell.topicLabel, indexPath)
        
        //MARK: - Time Stamp
        timeStampTopicGlobal(topicObjects, cell.timeStamp, cell.ideaTotalButton, indexPath, cell)
        
        return cell
        
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
