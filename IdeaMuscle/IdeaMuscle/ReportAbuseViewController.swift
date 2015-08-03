//
//  ReportAbuseViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/30/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ReportAbuseViewController: UIViewController, UITextViewDelegate {
    
    var activeIdea = PFObject?()
    var activeTopic = PFObject(className: "Topic")
    var reportIdeaButton = UIButton()
    var reportTopicButton = UIButton()
    var reportBothButton = UIButton()
    var selectedButton = 1
    var commentsTextView = UITextView()
    var container = UIView()
    let selectionView = UIView()
    var isFromTopic = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Report Abuse"
        self.view.backgroundColor = UIColor.whiteColor()
        if self.tabBarController != nil{
            self.tabBarController!.tabBar.hidden = true
        }
        
        container.frame = CGRectMake(0, self.navigationController!.navigationBar.frame.maxY, self.view.frame.width, 5)
        
        if let idea = activeIdea{
            container.frame = CGRectMake(0, self.navigationController!.navigationBar.frame.maxY, self.view.frame.width, 130)
            container.backgroundColor = twoThirtyGrayColor
            self.view.addSubview(container)
            
            reportIdeaButton.frame = CGRectMake(50, 10, 30, 30)
            reportTopicButton.frame = CGRectMake(50, reportIdeaButton.frame.maxY + 10, 30, 30)
            reportBothButton.frame = CGRectMake(50, reportTopicButton.frame.maxY + 10, 30, 30)
            
            reportIdeaButton.layer.cornerRadius = 15
            reportTopicButton.layer.cornerRadius = 15
            reportBothButton.layer.cornerRadius = 15
            reportIdeaButton.layer.masksToBounds = true
            reportTopicButton.layer.masksToBounds = true
            reportBothButton.layer.masksToBounds = true
            
            reportIdeaButton.layer.borderWidth = 1
            reportTopicButton.layer.borderWidth = 1
            reportBothButton.layer.borderWidth = 1
            
            reportIdeaButton.layer.borderColor = fiftyGrayColor.CGColor
            reportTopicButton.layer.borderColor = fiftyGrayColor.CGColor
            reportBothButton.layer.borderColor = fiftyGrayColor.CGColor
            
            reportIdeaButton.backgroundColor = twoThirtyGrayColor
            reportTopicButton.backgroundColor = twoThirtyGrayColor
            reportBothButton.backgroundColor = twoThirtyGrayColor
            
            reportIdeaButton.addTarget(self, action: "reportSelection:", forControlEvents: .TouchUpInside)
            reportTopicButton.addTarget(self, action: "reportSelection:", forControlEvents: .TouchUpInside)
            reportBothButton.addTarget(self, action: "reportSelection:", forControlEvents: .TouchUpInside)
            
            
            changeSelection(reportIdeaButton)
            
            container.addSubview(reportIdeaButton)
            container.addSubview(reportTopicButton)
            container.addSubview(reportBothButton)
            
            
            selectionView.frame = CGRectMake(2, 2, 26, 26)
            selectionView.backgroundColor = redColor
            selectionView.layer.cornerRadius = 13
            
            let reportIdeaLabel = UILabel(frame: CGRectMake(reportIdeaButton.frame.maxX + 10, reportIdeaButton.frame.minY, self.view.frame.width - reportIdeaButton.frame.maxX - 20, 30))
            let reportTopicLabel = UILabel(frame: CGRectMake(reportIdeaButton.frame.maxX + 10, reportTopicButton.frame.minY, self.view.frame.width - reportIdeaButton.frame.maxX - 20, 30))
            let reportBothLabel = UILabel(frame: CGRectMake(reportIdeaButton.frame.maxX + 10, reportBothButton.frame.minY, self.view.frame.width - reportIdeaButton.frame.maxX - 20, 30))
            
            reportIdeaLabel.text = "Report Idea"
            reportTopicLabel.text = "Report Topic"
            reportBothLabel.text = "Report Both"
            
            reportIdeaLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            reportTopicLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            reportBothLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            
            reportIdeaLabel.textColor = fiftyGrayColor
            reportTopicLabel.textColor = fiftyGrayColor
            reportBothLabel.textColor = fiftyGrayColor
            
            container.addSubview(reportIdeaLabel)
            container.addSubview(reportTopicLabel)
            container.addSubview(reportBothLabel)
            
        }
        
        let addCommentLabelContainer = UIView(frame: CGRectMake(0, container.frame.maxY + 5, self.view.frame.width, 80))
        addCommentLabelContainer.backgroundColor = fiftyGrayColor
        self.view.addSubview(addCommentLabelContainer)
        
        let addCommentLabel = UILabel(frame: CGRectMake(5, 0, self.view.frame.width - 10, 80))
        addCommentLabel.text = "Tell us why this content is offensive(Optional).  If we find that it violates our content policy it will be removed within 24 hours without notice, but it has already been hidden from you."
        addCommentLabel.numberOfLines = 0
        addCommentLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        addCommentLabel.backgroundColor = fiftyGrayColor
        addCommentLabel.textColor = UIColor.whiteColor()
        addCommentLabelContainer.addSubview(addCommentLabel)
        
        commentsTextView.delegate = self
        commentsTextView.frame = CGRectMake(5, addCommentLabelContainer.frame.maxY + 5, self.view.frame.width - 10, 100)
        commentsTextView.font = UIFont(name: "Avenir", size: 13)
        commentsTextView.textColor = fiftyGrayColor
        commentsTextView.layer.borderColor = fiftyGrayColor.CGColor
        commentsTextView.layer.borderWidth = 1
        commentsTextView.layer.cornerRadius = 5
        self.view.addSubview(commentsTextView)
        
        let submitButton = UIButton(frame: CGRectMake(self.view.frame.width/2 - 50, commentsTextView.frame.maxY + 5, 100, 30))
        submitButton.setTitle("Submit", forState: .Normal)
        submitButton.setTitleColor(fiftyGrayColor, forState: .Highlighted)
        submitButton.backgroundColor = redColor
        submitButton.addTarget(self, action: "submit:", forControlEvents: .TouchUpInside)
        submitButton.titleLabel?.textColor = UIColor.whiteColor()
        submitButton.layer.cornerRadius = 3
        self.view.addSubview(submitButton)
        
        
    }
    
    func submit(sender: UIButton){
        if let currentUser = PFUser.currentUser(){
            let reportObject = PFObject(className: "Report")
            reportObject.ACL?.setPublicReadAccess(false)
            reportObject.ACL?.setPublicWriteAccess(false)
            reportObject["userWhoReported"] = currentUser
            reportObject["userComments"] = commentsTextView.text
            if let idea = activeIdea{
                if selectedButton == 1 || selectedButton == 3{
                    //Report Idea
                    reportObject["ideaPointer"] = activeIdea
                }
                if selectedButton == 2 || selectedButton == 3{
                    //Report Topic
                    reportObject["topicPointer"] = activeTopic
                    if isFromTopic == false{
                        currentUser.addObject(activeTopic, forKey: "topicsToHide")
                        currentUser.addObject(activeTopic.objectId!, forKey: "topicsToHideId")
                    }
                }
            }else{
                //Report Topic
                reportObject["topicPointer"] = activeTopic
                if isFromTopic == false{
                    currentUser.addObject(activeTopic, forKey: "topicsToHide")
                    currentUser.addObject(activeTopic.objectId!, forKey: "topicsToHideId")
                }
            }
            
            var title = String()
            var content = String()
            var username = String()
            
            if let topicTitle = activeTopic["title"] as? String{
                title = topicTitle + " "
            }else{
                title = " "
            }
            
            if let idea = activeIdea{
                if let ideaContent = idea["content"] as? String{
                    content = ideaContent + " "
                }else{
                    content = " "
                }
            }else{
                content = " "
            }
            
            if let currentUsername = currentUser.username{
                username = currentUsername + " "
            }else{
                username = " "
            }
            
            let emailText = "Reporting User: " + username + "\r\n" + "User Comments: " + commentsTextView.text + " " + "\r\n" + "Topic Title: " + title + "\r\n" + "Idea Content: " + content
            
            reportObject["emailText"] = emailText
            reportObject.saveEventually()
            currentUser.saveEventually()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        commentsTextView.endEditing(true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }else{
            return true
        }
    }
    
    func reportSelection(sender: UIButton){
        changeSelection(sender)
    }
    
    
    func changeSelection(buttonSelected: UIButton){
        
        selectionView.removeFromSuperview()
        
        if buttonSelected == reportIdeaButton{
            reportIdeaButton.addSubview(selectionView)
            selectedButton = 1
        }else if buttonSelected == reportTopicButton{
            reportTopicButton.addSubview(selectionView)
            selectedButton = 2
        }else if buttonSelected == reportBothButton{
            reportBothButton.addSubview(selectionView)
            selectedButton = 3
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

}
