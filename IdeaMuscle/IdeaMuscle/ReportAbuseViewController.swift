//
//  ReportAbuseViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/30/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ReportAbuseViewController: UIViewController {
    
    var activeIdea = PFObject?()
    var activeTopic = PFObject(className: "Topic")
    var reportIdeaButton = UIButton()
    var reportTopicButton = UIButton()
    var reportBothButton = UIButton()
    var selectedButton = 1
    var commentsTextView = UITextView()
    var container = UIView()
    let selectionView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Report Abuse"
        self.view.backgroundColor = UIColor.whiteColor()
        if self.tabBarController != nil{
            self.tabBarController!.tabBar.hidden = true
        }
        
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
