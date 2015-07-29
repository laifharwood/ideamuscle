//
//  NotificationsTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/28/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class NotificationsTableViewController: UITableViewController {
    
    var notificationObjects = [PFObject(className: "Notification")]
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        startActivityIndicator()
        queryNotificationObjects()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(NotificationTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.title =  "Notifications"
        
        let settingsButton = UIButton()
        settingsButton.setTitle("Settings", forState: .Normal)
        settingsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        settingsButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        settingsButton.addTarget(self, action: "settings:", forControlEvents: .TouchUpInside)
        settingsButton.sizeToFit()
        let settingsBarItem = UIBarButtonItem(customView: settingsButton)
        self.navigationItem.rightBarButtonItem = settingsBarItem
        
    }
    override func viewWillAppear(animated: Bool) {
        if PFInstallation.currentInstallation().badge != 0{
            PFInstallation.currentInstallation().badge = 0
            PFInstallation.currentInstallation().saveEventually()
            
            if tabBarController != nil{
                self.tabBarController!.tabBar.hidden = true
                updateMoreBadge(tabBarController!)
            }
        }
    }
    
    func settings(sender: UIButton){
        let settingsVC = NotificationSettingsTableViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func queryNotificationObjects(){
        if let currentUser = PFUser.currentUser(){
            let query = PFQuery(className: "Notification")
            query.whereKey("toUser", equalTo: currentUser)
            query.limit = 100
            query.includeKey("ideaPointer")
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil{
                    self.notificationObjects = objects as! [PFObject]
                    self.stopActivityIndicator()
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return notificationObjects.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationTableViewCell
        
        
        
        if let message = notificationObjects[indexPath.row]["message"] as? String{
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.messageLabel.text = message
            cell.messageLabel.font = UIFont(name: "HelveticaNeue", size: 13)
            cell.messageLabel.frame = CGRectMake(10, 5, self.view.frame.width - 45, cell.frame.height - 10)
            cell.messageLabel.textColor = UIColor.blackColor()
            
            if let hasRead = notificationObjects[indexPath.row]["hasRead"] as? Bool{
                
                cell.hasReadView.frame = CGRectMake(0, 2, 8, cell.frame.height - 4)
                
                if hasRead{
                    cell.hasReadView.backgroundColor = UIColor.whiteColor()
                }else{
                    cell.hasReadView.backgroundColor = fiftyGrayColor
                }
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let idea = notificationObjects[indexPath.row]["ideaPointer"] as? PFObject{
            let ideaDetailVC = IdeaDetailViewController()
            ideaDetailVC.activeIdea = idea
            if let topic = idea["topicPointer"] as? PFObject{
                topic.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                    if error == nil{
                        ideaDetailVC.activeTopic = topic
                        
                        if let hasRead = self.notificationObjects[indexPath.row]["hasRead"] as? Bool{
                            if hasRead == false{
                                let notification = self.notificationObjects[indexPath.row] as PFObject
                                notification["hasRead"] = true
                                notification.saveEventually()
                                tableView.reloadData()
                            }
                        }
                        self.navigationController?.pushViewController(ideaDetailVC, animated: true)
                    }
                })
            }
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
    
//    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if cell.respondsToSelector("setSeparatorInset")
//    }
    

    

}
