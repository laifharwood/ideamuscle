//
//  ComposeTopicViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/15/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ComposeTopicViewController: UIViewController, UITextViewDelegate {
    var shouldDismissCompose = false
    var textView = UITextView()
    var isPublic = true
    let grayCheckmarkImage = UIImage(named: "checkmarkGray.png")
    let redCheckmarkImage = UIImage(named: "checkmarkRed.png")
    var checkmarkButton = UIButton()
    var submitButton = UIButton()
    var characterCountLabel = UILabel()
    var characterCount = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        textView.becomeFirstResponder()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        // MARK: - Top Bar Config
        var topBar = UIView()
        topBar.frame = CGRectMake(0, 0, self.view.frame.width, 64)
        topBar.backgroundColor = seventySevenGrayColor
        self.view.addSubview(topBar)
        
        // MARK: - Compose Title
        var title = UILabel()
        title.text = "New Topic"
        title.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        title.textColor = UIColor.whiteColor()
        title.frame = CGRectMake(topBar.frame.width/2 - 60, topBar.frame.height/2, 120, 16)
        topBar.addSubview(title)
        title.textAlignment = NSTextAlignment.Center
        
        //MARK: - Cancel Button
        var cancelButton = UIButton()
        cancelButton.frame = CGRectMake(0, topBar.frame.height/2, 60, 16)
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 12)
        cancelButton.setTitleColor(redColor, forState: .Normal)
        cancelButton.addTarget(nil, action: "cancelExit:", forControlEvents: .TouchUpInside)
        topBar.addSubview(cancelButton)
        
        //MARK: - Small Logo Right
        var logoView = UIImageView(image: smallLogo)
        logoView.frame = CGRectMake(topBar.frame.width - 40, topBar.frame.height/2 - 7.5, 35, 35)
        topBar.addSubview(logoView)
        
        //MARK: - Text View container
        var textViewContainer = UIView()
        textViewContainer.frame = CGRectMake(0, topBar.frame.maxY + 5, self.view.frame.width, 100)
        textViewContainer.backgroundColor = seventySevenGrayColor
        self.view.addSubview(textViewContainer)
        
            //MARK: - Description Label
            var descriptionLabel = UILabel()
            descriptionLabel.frame = CGRectMake(5, 5, self.view.frame.width - 10, 20)
            descriptionLabel.text = "Enter your topic."
            descriptionLabel.textColor = UIColor.whiteColor()
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
            descriptionLabel.textAlignment = .Center
            textViewContainer.addSubview(descriptionLabel)
        
            //MARK: - Text View
            textView.frame = CGRectMake(5, 30, self.view.frame.width - 70, 40)
            textView.backgroundColor = UIColor.whiteColor()
            textView.layer.cornerRadius = 3
            textView.layer.masksToBounds = true
            textView.textColor = fiftyGrayColor
            textView.font = UIFont(name: "Avenir", size: 10)
            textView.returnKeyType = UIReturnKeyType.Done
            textView.tintColor = redColor
            textViewContainer.addSubview(textView)
        
            //MARK: - Character Count
            characterCountLabel.frame = CGRectMake(textView.frame.maxX - 40, textView.frame.maxY + 3, 40, 20)
            characterCountLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)
            characterCountLabel.textColor = UIColor.whiteColor()
            characterCountLabel.text = "\(characterCount)" + "/118"
            textViewContainer.addSubview(characterCountLabel)
        
            //MARK: - Make Public Label
            var mPLabelX = CGFloat()
            mPLabelX = textView.frame.maxX + (self.view.frame.width - textView.frame.maxX)/2 - 25
        
            let makePublicLabel = UILabel(frame: CGRectMake(mPLabelX,textView.frame.minY, 70, 10))
            makePublicLabel.text = "Make Public?"
            makePublicLabel.textColor = UIColor.whiteColor()
            makePublicLabel.font = UIFont(name: "HelveticaNeue-Light", size: 9)
            textViewContainer.addSubview(makePublicLabel)
        
        
            //MARK: - Checkmark Button
        
            checkmarkButton = UIButton(frame: CGRectMake(mPLabelX + 8.75, makePublicLabel.frame.maxY + 2.5, 35, 27.8))
            checkmarkButton.setImage(redCheckmarkImage, forState: .Normal)
            checkmarkButton.addTarget(self, action: "makeTopicPublic:", forControlEvents: .TouchUpInside)
        
            textViewContainer.addSubview(checkmarkButton)
        
        //MARK: - Submit Button
        
        submitButton.frame = CGRectMake(self.view.frame.width/2 - 75, textViewContainer.frame.maxY + 5, 150, 50)
        submitButton.setTitle("Submit", forState: .Normal)
        submitButton.setTitleColor(twoHundredGrayColor, forState: .Disabled)
        submitButton.setTitleColor(redColor, forState: .Normal)
        submitButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        submitButton.backgroundColor = fiftyGrayColor
        submitButton.layer.cornerRadius = 2
        submitButton.enabled = false
        submitButton.alpha = 0.2
        submitButton.addTarget(self, action: "submit:", forControlEvents: .TouchUpInside)
        self.view.addSubview(submitButton)
        

        // Do any additional setup after loading the view.
    }
    
    func cancelExit(sender: UIButton!){
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }else if text == "" {
            if characterCount > 0{
                
            --characterCount
            characterCountLabel.text = "\(characterCount)" + "/118"
            if characterCount == 0{
                submitButton.enabled = false
                submitButton.alpha = 0.2
            }
            return true
            }else{

                return false
            }
            
            
        }else if characterCount == 118{
            return false
        }else if text == " "{
            if characterCount > 0{
                
                ++characterCount
                characterCountLabel.text = "\(characterCount)" + "/118"
                submitButton.enabled = true
                submitButton.alpha = 1
                return true
            }else{
                return false
            }
            
            
            
        }else{
            ++characterCount
            characterCountLabel.text = "\(characterCount)" + "/118"
            submitButton.enabled = true
            submitButton.alpha = 1
            return true
        }
    }
    
    func makeTopicPublic(sender: UIButton!){
        
        if isPublic == false{
            checkmarkButton.setImage(redCheckmarkImage, forState: .Normal)
            isPublic = true
            
        }else{
            
            checkmarkButton.setImage(grayCheckmarkImage, forState: .Normal)
            isPublic = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if shouldDismissCompose == true{
            self.dismissViewControllerAnimated(true, completion: nil)
            shouldDismissCompose = false
        }
    }
    
    func submit(sender: UIButton!){
        
        var newTopic = PFObject(className: "Topic")
        
        
        if isPublic == true{
            var creator = PFUser.currentUser()
            newTopic["title"] = textView.text
            newTopic["creator"] = creator
            newTopic["isPublic"] = true
            
            let publicAcl = PFACL()
            publicAcl.setPublicReadAccess(true)
            publicAcl.setPublicWriteAccess(true)
            publicAcl.setWriteAccess(true, forUser: creator!)
            newTopic["ACL"] = publicAcl
            
            newTopic.saveInBackgroundWithBlock { (success, error) -> Void in
                if success{
                    
                    println("Topic Saved Publically Successfully")
                    //activeComposeTopicObject = newTopic
                    
                    
                }else{
                    
                    println("error Public Save")
                }
            }
            
            
        }else{
            
            var newTopic = PFObject(className: "Topic")
            var creator = PFUser.currentUser()
            newTopic["title"] = textView.text
            newTopic["creator"] = creator
            newTopic["isPublic"] = false
            
            let privateAcl = PFACL()
            privateAcl.setPublicWriteAccess(false)
            privateAcl.setPublicReadAccess(false)
            privateAcl.setReadAccess(true, forUser: creator!)
            privateAcl.setWriteAccess(true, forUser: creator!)
            newTopic["ACL"] = privateAcl
            
            newTopic.saveInBackgroundWithBlock { (success, error) -> Void in
                if success{
                    
                    println("Topic Saved Privately Successfully")
                    //activeComposeTopicObject = newTopic
                    
                    
                }else{
                    
                    println("error Private Save")
                }
            }
        }
        
        shouldDismissCompose = true
        textView.text = ""
        let composeVC = ComposeViewController()
        composeVC.activeComposeTopicObject = newTopic
        self.presentViewController(composeVC, animated: true, completion: nil)
        
        
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
