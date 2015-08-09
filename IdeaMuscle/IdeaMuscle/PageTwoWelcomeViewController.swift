//
//  PageTwoWelcomeViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 8/4/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class PageTwoWelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        let topContainer = UIView(frame: CGRectMake(0, UIApplication.sharedApplication().statusBarFrame.height, self.view.frame.width, 75))
        topContainer.backgroundColor = fiftyGrayColor
        self.view.addSubview(topContainer)
        
        let title = UILabel(frame: CGRectMake(5, 5, self.view.frame.width - 10, topContainer.frame.height - 10))
        title.text = "Why We Made Idea Muscle"
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
        textView.text = "We have found so much value in coming up with 10 ideas a day, but found that for us it was a hard habit to form and to do consistently and that’s why we built the IdeaMuscle app. We figured if we built an app around the practice of coming up with 10 ideas a day and added some social and competitive elements then that would give us and other people a little extra motivation to form the habit and also provide a place where like minded people can connect and discuss all the ideas they come up with. We hope you like the app! If you have any questions, suggestions, or issues please let us know. You can email us at support@ideamuscle.me."
        
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
