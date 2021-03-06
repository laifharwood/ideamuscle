//
//  ComposeViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/8/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate{
    
    var tableView: UITableView = UITableView()
    
    let grayCheckmarkImage = UIImage(named: "checkmarkGray.png")
    let redCheckmarkImage = UIImage(named: "checkmarkRed.png")
    var publicBoolArray = [false, false, false, false, false, false, false, false, false, false]
    
    //MARK: - UIViews for text views
    var frameOne = UIView()
    var frameTwo = UIView()
    var frameThree = UIView()
    var frameFour = UIView()
    var frameFive = UIView()
    var frameSix = UIView()
    var frameSeven = UIView()
    var frameEight = UIView()
    var frameNine = UIView()
    var frameTen = UIView()
    
    var frameArray = [UIView]()
    
    
    var textViewOne = UITextView()
    var textViewTwo = UITextView()
    var textViewThree = UITextView()
    var textViewFour = UITextView()
    var textViewFive = UITextView()
    var textViewSix = UITextView()
    var textViewSeven = UITextView()
    var textViewEight = UITextView()
    var textViewNine = UITextView()
    var textViewTen = UITextView()
    
    var textViewArray = [UITextView]()
    var textViewValues = ["", "", "", "", "", "", "", "", "", ""]
    
    var submitButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textViewOne.becomeFirstResponder()
        
        self.view.backgroundColor = twoHundredGrayColor
        
        textViewOne.delegate = self
        textViewTwo.delegate = self
        textViewThree.delegate = self
        textViewFour.delegate = self
        textViewFive.delegate = self
        textViewSix.delegate = self
        textViewSeven.delegate = self
        textViewEight.delegate = self
        textViewNine.delegate = self
        textViewTen.delegate = self
        
        // MARK: - Top Bar Config
        var topBar = UIView()
        topBar.frame = CGRectMake(0, 0, self.view.frame.width, 64)
        topBar.backgroundColor = seventySevenGrayColor
        self.view.addSubview(topBar)
        
            // MARK: - Compose Title
            var title = UILabel()
            title.text = "Compose Ideas"
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
            cancelButton.addTarget(nil, action: "cancel:", forControlEvents: .TouchUpInside)
            topBar.addSubview(cancelButton)
        
            //MARK: - Small Logo Right
            var logoView = UIImageView(image: smallLogo)
            logoView.frame = CGRectMake(topBar.frame.width - 40, topBar.frame.height/2 - 7.5, 35, 35)
            topBar.addSubview(logoView)
        
        //MARK: - Topic Title Bar
        var topicTitleBar = UIView()
        topicTitleBar.frame = CGRectMake(0, topBar.frame.maxY + 10, self.view.frame.width, 60)
        topicTitleBar.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(topicTitleBar)
        
            //MARK: - Topic Title Label
            var topicLabel = UILabel(frame: CGRectMake(2.5, 2.5, topicTitleBar.frame.width - 5, topicTitleBar.frame.height - 5))
            topicLabel.text = "This is a test topic. In real life this would be the topic that people would come up with their 10 ideas for. One, Two, Three, Four, Five, Six, Seven"
            topicLabel.textColor = UIColor.blackColor()
            topicLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
            topicLabel.numberOfLines = 3
            topicLabel.textAlignment = NSTextAlignment.Center
            topicTitleBar.addSubview(topicLabel)
            
       //MARK: - Table View Config
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRectMake(0, topicTitleBar.frame.maxY + 5, self.view.frame.width, self.view.frame.height - 129)
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 70
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0)
        self.view.addSubview(tableView)
        
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 16
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        //MARK: - Create Reusable Cell
        let cell = UITableViewCell()
        
        
        cell.backgroundColor = twoHundredGrayColor
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.row < 10 {
        
        //MARK: - frameArray Initialize
        let frameArray = [frameOne, frameTwo, frameThree, frameFour, frameFive, frameSix, frameSeven, frameEight, frameNine, frameTen]
        
        for frame in frameArray{
            frame.frame = CGRectMake(0, 5, cell.frame.width, 60)
            frame.backgroundColor = seventySevenGrayColor
            
        }
        
        
        cell.addSubview(frameArray[indexPath.row])
        
        //MARK: - Number Label
        let numberArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        var numberLabel = UILabel()
        numberLabel.frame = CGRectMake(5, frameArray[indexPath.row].frame.height/2 - 10, 20, 20)
        numberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        numberLabel.textColor = UIColor.whiteColor()
        numberLabel.text = "\(numberArray[indexPath.row])"
        frameArray[indexPath.row].addSubview(numberLabel)
        
        
        //MARK: - Text View
        self.textViewArray = [textViewOne, textViewTwo, textViewThree, textViewFour, textViewFive, textViewSix, textViewSeven, textViewEight, textViewNine, textViewTen]
        
        var index = 0
        
        for textView in textViewArray{
            
            textView.tag = index
            ++index
            
        }
        for textView in textViewArray{
            textView.frame = CGRectMake(numberLabel.frame.width + 5, 5, self.view.frame.width - numberLabel.frame.width - 70, frameArray[indexPath.row].frame.height - 10)
            textView.backgroundColor = UIColor.whiteColor()
            textView.layer.cornerRadius = 3
            textView.layer.masksToBounds = true
            textView.textColor = fiftyGrayColor
            textView.font = UIFont(name: "HelveticaNeue-Light", size: 10)
            textView.returnKeyType = UIReturnKeyType.Done
            textView.tintColor = redColor
            //textView.text = textViewValues[indexPath.row]
            
        }
        frameArray[indexPath.row].addSubview(textViewArray[indexPath.row])
        
        
        //MARK: - Make Public Label
        var mPLabelX = CGFloat()
        mPLabelX = textViewArray[indexPath.row].frame.maxX + (cell.frame.width - textViewArray[indexPath.row].frame.maxX)/2 - 25
        
        let makePublicLabel = UILabel(frame: CGRectMake(mPLabelX,5, 70, 15))
        makePublicLabel.text = "Make Public?"
        makePublicLabel.textColor = UIColor.whiteColor()
        makePublicLabel.font = UIFont(name: "HelveticaNeue-Light", size: 9)
        frameArray[indexPath.row].addSubview(makePublicLabel)
        
        
        //MARK: - Checkmark Button
        let checkmarkButton = UIButton(frame: CGRectMake(mPLabelX + 8.75, makePublicLabel.frame.maxY + 2.5, 35, 27.8))
        checkmarkButton.setImage(grayCheckmarkImage, forState: .Normal)
        //checkmarkButton.setImage(redCheckmarkImage, forState: .Selected)
        checkmarkButton.tag = indexPath.row
        checkmarkButton.addTarget(self, action: "makePublic:", forControlEvents: .TouchUpInside)
        
        frameArray[indexPath.row].addSubview(checkmarkButton)
            
        }else if indexPath.row == 10{
            
            for view in cell.subviews{
                
                view.removeFromSuperview()
            }
            
            submitButton.frame = CGRectMake(cell.frame.width/2 - 75, 5, 150, 50)
            submitButton.setTitle("Submit", forState: .Normal)
            submitButton.setTitleColor(twoHundredGrayColor, forState: .Disabled)
            submitButton.setTitleColor(redColor, forState: .Normal)
            submitButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
            submitButton.backgroundColor = fiftyGrayColor
            submitButton.layer.cornerRadius = 2
            submitButton.addTarget(self, action: "Submit:", forControlEvents: .TouchUpInside)
            checkForSumbitActive()
            
            
            cell.addSubview(submitButton)
            
            
            
        }else{
            
            for view in cell.subviews{
                
                view.removeFromSuperview()
            }
        }
        
    
        return cell
    }
    
    
    var activeTextView = 0
    
    
    
    func textViewDidEndEditing(textView: UITextView) {
    
        checkForSumbitActive()
        
    }
    
    func checkForSumbitActive(){
        
        if textViewOne.text != "" && textViewTwo.text != "" && textViewThree.text != "" && textViewFour.text != "" && textViewFive.text != "" && textViewSix.text != "" && textViewSeven.text != "" && textViewEight.text != "" && textViewNine.text != "" && textViewTen.text != ""{
            submitButton.enabled = true
            submitButton.alpha = 1
        }else{
            
            submitButton.enabled = false
            submitButton.alpha = 0.2
        }
        
        
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            
            textView.resignFirstResponder()
            
            if textView.tag < 10{
                var pathToScroll = NSIndexPath()
                pathToScroll = NSIndexPath(forRow: textView.tag + 1, inSection: 0)
                
                tableView.scrollToRowAtIndexPath(pathToScroll, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                if textView.tag < 9{
                textViewArray[textView.tag + 1].becomeFirstResponder()
                }
            }
            return false
        }else{
        
        return true
        }
    }
    
    func submit(sender: UIButton!){
        
        //Submit validation
    }
    
    func makePublic(sender: UIButton){
        
        if publicBoolArray[sender.tag] == false{
        
        sender.setImage(redCheckmarkImage, forState: .Normal)
        publicBoolArray[sender.tag] = true
        }else{
            sender.setImage(grayCheckmarkImage, forState: .Normal)
            publicBoolArray[sender.tag] = false
        }
        
        
        
    }
    
    func cancel(sender: UIButton!){
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
