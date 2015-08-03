//
//  DraftsTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/17/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class DraftsTableViewController: UITableViewController {
    
    var draftObjects = [PFObject(className: "Draft")]
    var shouldQuery = false
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.title = "Drafts"
        startActivityIndicator()
        draftsQuery()


    }
    
    override func viewWillAppear(animated: Bool) {
        if shouldQuery{
            startActivityIndicator()
            draftsQuery()
        }
    }
    
    func draftsQuery(){
        if let user = PFUser.currentUser(){
            let draftQuery = PFQuery(className: "Draft")
            draftQuery.whereKey("userPointer", equalTo: user)
            draftQuery.includeKey("topicPointer")
            draftQuery.includeKey("ideaArray")
            draftQuery.includeKey("isPublicArray")
            draftQuery.orderByDescending("createAt")
            draftQuery.findObjectsInBackgroundWithTarget(self, selector: "draftSelector:error:")
        }
    }
    
    func draftSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            
            draftObjects = objects as! [PFObject]
            stopActivityIndicator()
        
        }else{
            println("Error: \(error.userInfo)")
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

        return draftObjects.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        
        
        
        if let topicObject = draftObjects[indexPath.row]["topicPointer"] as? PFObject{
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if let topicTitle = topicObject["title"] as? String{
                cell.textLabel?.text = topicTitle
                cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
            }
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var draftObject = draftObjects[indexPath.row] as PFObject
            let composeVC =  ComposeViewController()
            if let topicObject = draftObject["topicPointer"] as? PFObject{
                if let ideaArrayToPass = draftObject["ideaArray"] as? [String]{
                    if let boolArrayToPass = draftObject["isPublicArray"] as? [Bool]{
                        composeVC.activeComposeTopicObject = topicObject
                        composeVC.textViewValues = ideaArrayToPass
                        composeVC.publicBoolArray = boolArrayToPass
                        composeVC.isADraft = true
                        composeVC.draftObject = draftObject
                        shouldQuery = true
                        self.presentViewController(composeVC, animated: true, completion: nil)
                    }
                }
            }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            
            var draftObject = draftObjects[indexPath.row] as PFObject
            draftObjects.removeAtIndex(indexPath.row)
            draftObject.deleteEventually()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
