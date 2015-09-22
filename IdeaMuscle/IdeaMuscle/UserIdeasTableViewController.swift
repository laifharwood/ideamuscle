//
//  UserIdeasTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/20/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UserIdeasTableViewController: UITableViewController {
    
    var topicsComposedForObjects = [PFObject(className: "TopicsComposedFor")]
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.title = "Topics You Have Ideas For"
        startActivityIndicator()
        topicsComposedForQuery()
    }
    
    func topicsComposedForQuery(){
        if let user = PFUser.currentUser(){
            let query = PFQuery(className: "TopicsComposedFor")
            query.whereKey("userPointer", equalTo: user)
            query.includeKey("topicPointer")
            query.limit = 1000
            query.orderByDescending("updatedAt")
            query.cachePolicy = PFCachePolicy.NetworkElseCache
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil{
                    
                    print("error equals nil")
                    self.topicsComposedForObjects = objects as! [PFObject]
                    
                    var encountered = Set<String>()
                    var result = [PFObject(className: "TopicsComposedFor")]
                    result = []
                    
                    for object in self.topicsComposedForObjects{
                        if let topic = object["topicPointer"] as? PFObject{
                            if let objectId = topic.objectId{
                                if encountered.contains(objectId){
                                    
                                }else{
                                    encountered.insert(objectId)
                                    result.append(object)
                                }
                            }
                        }
                    }
                    self.topicsComposedForObjects = []
                    self.topicsComposedForObjects = result
                }else{
                    print("\(error?.userInfo)")
                }
                self.stopActivityIndicator()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return topicsComposedForObjects.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        if let topic = topicsComposedForObjects[indexPath.row]["topicPointer"] as? PFObject{
            if let title = topic["title"] as? String{
                cell.textLabel!.text = title
                cell.textLabel!.textColor = UIColor.blackColor()
                cell.textLabel!.font = UIFont(name: "Avenir", size: 14)
                cell.textLabel!.frame = CGRectMake(5, 5, self.view.frame.width - 40 - 5, cell.frame.height - 10)
                cell.textLabel!.numberOfLines = 0
            }
        }
        
        

        return cell
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userIdeaDetailVC = UserIdeasDetailViewController()
        let topic = topicsComposedForObjects[indexPath.row]["topicPointer"] as! PFObject
        topic.fetchIfNeededInBackgroundWithBlock { (success, error) -> Void in
            userIdeaDetailVC.activeTopic = topic
            self.navigationController?.pushViewController(userIdeaDetailVC, animated: true)
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
}
