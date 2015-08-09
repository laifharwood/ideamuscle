//
//  PageThreeWelcomeViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 8/4/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class PageThreeWelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        let topContainer = UIView(frame: CGRectMake(0, UIApplication.sharedApplication().statusBarFrame.height, self.view.frame.width, 75))
        topContainer.backgroundColor = fiftyGrayColor
        self.view.addSubview(topContainer)
        
        let title = UILabel(frame: CGRectMake(5, 5, self.view.frame.width - 10, topContainer.frame.height - 10))
        title.text = "Getting Started"
        title.font = UIFont(name: "HelveticaNeue", size: 18)
        title.textColor = UIColor.whiteColor()
        title.textAlignment = NSTextAlignment.Center
        topContainer.addSubview(title)
        
        let textContainer = UIView(frame: CGRectMake(0, topContainer.frame.maxY, self.view.frame.width, self.view.frame.height - topContainer.frame.height - 50))
        textContainer.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(textContainer)
        
        let textView = UITextView(frame: CGRectMake(5, 5, textContainer.frame.width - 10, textContainer.frame.height - 10))
        textView.editable = false
        textView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        textView.font = UIFont(name: "Avenir", size: 14)
        textView.text = "Here’s some general information about the app and it’s features:\n\nIdeaMuscle is a free app with the ability for you to upgrade to pro through an in app purchase in our store which can be found in the “More” section of the app.  The app is free forever but without upgrading you are limited in features you have access to.\n\nYou may compose ideas for your own topics or topics that others have made public. To compose ideas for your own topic you will find a white compose button in the top right of all the main views in the app.  To compose ideas for someone else's topic there is a compose button in the bottom right of the screen on a topic or idea detail view. If you come up with your own topic you have the choice to make it public or keep it private. Once you make a topic public you will not be able to delete it or make it private since other users may have come up with ideas for the topic.  You can also make ideas private or public as well.  Ideas and topics are not editable after posting.\n\n10 ideas must be composed for a topic before the app will let you submit the ideas.\n\nAll public ideas can be upvoted and commented on by other users.\n\n\nHere’s a brief overview of the four main sections in the app:\n\nTop Ideas/Topics Section - This section contains global lists of the top ideas and topics. You can sort ideas and topics by different time periods.  Top ideas are determined by number of upvotes and top topics are determined by number of public ideas submitted.\n\nFeed Section - This section contains a list of ideas from other users that you follow.\n\nLeaderboard Section - This section contains two leaderboards, one that ranks you among those you follow, and another that ranks all users in the world. Rankings are based on total number of upvotes a user has on all their public ideas.\n\nMore Section - This section contains a variety of other features and views."
        
        textContainer.addSubview(textView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
