//
//  NotificationSettingsTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/29/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class NotificationSettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Notif Settings"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 3
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = NotificationSettingsTableViewCell()
        cell.frame = CGRectMake(0, 0, tableView.frame.width, 44)
        
        cell.switchButton.frame = CGRectMake(cell.frame.maxX - 60, cell.frame.height/2 - 15, 40, 30)
        cell.switchButton.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)
        cell.switchButton.onTintColor = redColor
        cell.switchButton.tintColor = oneFiftyGrayColor
        cell.switchButton.tag = indexPath.row
        cell.switchButton.hidden = false
        
        cell.messageLabel.frame = CGRectMake(10, 0, cell.frame.width - cell.switchButton.frame.width - 20, cell.frame.height)
        cell.messageLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        
        if indexPath.row == 0{
            cell.messageLabel.text = "Someone Comments On My Ideas"
            if let currentUser = PFUser.currentUser(){
                if let getComment = currentUser["getCommentNotifications"] as? Bool{
                    if getComment{
                       cell.switchButton.on = true
                    }else{
                        cell.switchButton.on = false
                    }
                }else{
                    cell.switchButton.on = true
                }
            }
        }else if indexPath.row == 1{
            cell.messageLabel.text = "Someone Upvotes My Ideas"
            if let currentUser = PFUser.currentUser(){
                if let getUpvote = currentUser["getUpvoteNotifications"] as? Bool{
                    if getUpvote{
                        cell.switchButton.on = true
                    }else{
                        cell.switchButton.on = false
                    }
                }else{
                    cell.switchButton.on = true

                }
            }
        }else if indexPath.row == 2{
            cell.messageLabel.text = "Someone Submits An Idea For My Topic"
            if let currentUser = PFUser.currentUser(){
                if let getTopic = currentUser["getTopicNotifications"] as? Bool{
                    if getTopic{
                        cell.switchButton.on = true
                    }else{
                        cell.switchButton.on = false
                    }
                }else{
                    cell.switchButton.on = true
                    
                }
            }
        }
        return cell
    }
    
    func switchChanged(sender: UISwitch){
        if sender.tag == 0{
            if sender.on == false{
               changeNotification("getCommentNotifications", status: false)
            }else if sender.on == true{
                changeNotification("getCommentNotifications", status: true)
            }
        }else if sender.tag == 1{
            if sender.on == false{
                changeNotification("getUpvoteNotifications", status: false)
            }else if sender.on == true{
                changeNotification("getUpvoteNotifications", status: true)
            }
        }else if sender.tag == 2{
            if sender.on == false{
                changeNotification("getTopicNotifications", status: false)
            }else if sender.on == true{
                changeNotification("getTopicNotifications", status: true)
            }
        }
    }
    
    func changeNotification(notification: String, status: Bool){
        if let currentUser = PFUser.currentUser(){
            currentUser[notification] = status
            currentUser.saveEventually()
        }
    }
}
