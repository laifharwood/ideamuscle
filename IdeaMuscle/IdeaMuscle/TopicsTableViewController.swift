//
//  TopicsTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class TopicsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate{
    
    var tableView: UITableView = UITableView()
    var tableViewTwo: UITableView = UITableView()
    var profilePicArray = [UIImage()]
    var ideaTotalsArray = [1230, 554, 65]
    var ideaTopicArray = ["This is topic one", "This is long topic two, it is longer than usual isn't it, do you agree? Or don't you agree that is the question that you need to answer right now, hey, hey, hey. what's up? Okay a little longer now to see what happens on the ipad. hope it's good.", "This is topic three"]
    var usernameArray = ["@bennett","@bennett","@bennett"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.hidesBottomBarWhenPushed = true
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
//        var navBar = UINavigationBar()
//        
//        navBar.frame.origin.y = -30
//        self.view.addSubview(navBar)
        
        
        self.title = "Topics"
        
        //Right Compose Button
        let composeOriginalButton = UIButton()
        let composeOriginalImage = UIImage(named: "ComposeWhite.png")
        composeOriginalButton.setImage(composeOriginalImage, forState: .Normal)
        composeOriginalButton.frame = CGRectMake(self.view.frame.width - 38, 25, 24.7, 25)
        composeOriginalButton.addTarget(self, action: "composeOriginal:", forControlEvents: .TouchUpInside)
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: composeOriginalButton)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false);
        
        //MARK: - Left Small Logo
        
        let leftLogoView = UIImageView(image: smallLogo)
        leftLogoView.frame = CGRectMake(10, 25, 35, 35)
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: leftLogoView)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        
        //MARK: - Top Bar Config
        let topBarView = UIView()
        topBarView.frame = CGRectMake(0, navigationController!.navigationBar.frame.maxY, self.view.frame.width, 30)
        topBarView.backgroundColor = oneFiftyGrayColor
        self.view.addSubview(topBarView)
        
        // MARK: - Table View Configuration
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRectMake(0, topBarView.frame.maxY, self.view.frame.width, self.view.frame.height - 113)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 100
        //tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        self.view.addSubview(tableView)
        
        
    
        
            //Segmented Control
            let items = ["Today", "7", "30", "All"]
            let customSC = UISegmentedControl(items: items)
            customSC.selectedSegmentIndex = 0
            customSC.frame = CGRectMake(5, 5, topBarView.frame.width - 10, 20)
            customSC.tintColor = UIColor.whiteColor()
            customSC.backgroundColor = seventySevenGrayColor
            customSC.layer.borderColor = UIColor.whiteColor().CGColor
            customSC.layer.cornerRadius = 4
            //customSC.layer.masksToBounds = true
            customSC.addTarget(self, action: "changeView:", forControlEvents: .ValueChanged)
            topBarView.addSubview(customSC)
        
        
        
        
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController!.tabBar.hidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return ideaTotalsArray.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        
        //MARK: - Profile Button Config
        var profileImage = UIImage(named: "IMG_1398.jpg") as UIImage!
        profileImage = cropToSquare(image: profileImage)
        profileImage = profileImage.convertToGrayScale()
        
        var profileButton = UIButton()
        profileButton.frame = CGRectMake(10, 55, 40, 40)
        profileButton.layer.cornerRadius = profileButton.frame.width/2
        //profileButton.layer.borderColor = UIColor.grayColor().CGColor
        //profileButton.layer.borderWidth = 2
        if indexPath.row == 1{
            profileButton.layer.borderColor = redColor.CGColor
            profileButton.layer.borderWidth = 2
        }
        profileButton.layer.masksToBounds = true
        profileButton.setImage(profileImage, forState: .Normal)
        profileButton.tag = indexPath.row
        profileButton.addTarget(self, action: "profileTapped:", forControlEvents: .TouchUpInside)
        cell.addSubview(profileButton)
        
        //MARK: - Idea Total Button Config
        var ideaTotalButton = UIButton()
        var ideaTotalButtonWidth = CGFloat()
        if ideaTotalsArray[indexPath.row] < 1000{
            ideaTotalButtonWidth = 30
        }else if ideaTotalsArray[indexPath.row] > 999 && ideaTotalsArray[indexPath.row] < 10000{
            ideaTotalButtonWidth = 40
        }else if ideaTotalsArray[indexPath.row] > 9999 && ideaTotalsArray[indexPath.row] < 100000{
            ideaTotalButtonWidth = 50
        }
        ideaTotalButton.frame =  CGRectMake(cell.frame.maxX - (ideaTotalButtonWidth + 10), 20, ideaTotalButtonWidth, cell.frame.height - 40)
        //ideaTotalButton.layer.cornerRadius = 2.0
        //ideaTotalButton.layer.borderColor = customGrayColor.CGColor
        ideaTotalButton.backgroundColor = UIColor.whiteColor()
        //ideaTotalButton.layer.borderWidth = 1
        ideaTotalButton.setTitle("\(ideaTotalsArray[indexPath.row])", forState: .Normal)
        ideaTotalButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        ideaTotalButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        ideaTotalButton.addTarget(self, action: "viewIdeas:", forControlEvents: .TouchUpInside)
        ideaTotalButton.tag = indexPath.row
        cell.addSubview(ideaTotalButton)
        
        
        //MARK: - Compose Button Config
        var composeButton = UIButton()
        var composeImage = UIImage(named: "ideaCompose.png") as UIImage!
        composeButton.frame = CGRectMake(cell.frame.width/2 + 30, 60, 20, 25)
        composeButton.setImage(composeImage, forState: .Normal)
        composeButton.addTarget(self, action: "composeForTopic:", forControlEvents: .TouchUpInside)
        composeButton.tag = indexPath.row
        cell.addSubview(composeButton)
        
        //MARK: - Share Button Config
        var shareButton = UIButton()
        var shareImage = UIImage(named: "ideaShare.png") as UIImage!
        shareButton.frame = CGRectMake(composeButton.frame.minX - 35, 60, 20, 25)
        shareButton.setImage(shareImage, forState: .Normal)
        shareButton.addTarget(self, action: "shareTopic:", forControlEvents: .TouchUpInside)
        shareButton.tag = indexPath.row
        cell.addSubview(shareButton)
        
        //MARK: - Idea Topic Label Config
        var ideaTopicLabel = UILabel()
        var labelWidth = cell.frame.width - ideaTotalButton.frame.width - 25
        ideaTopicLabel.frame = CGRectMake(10, 10, labelWidth, 40)
        ideaTopicLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        ideaTopicLabel.numberOfLines = 2
        ideaTopicLabel.textColor = UIColor.blackColor()
        ideaTopicLabel.text = ideaTopicArray[indexPath.row]
        cell.addSubview(ideaTopicLabel)
        
        //MARK: - Username Label Config
        var usernameLabel = UILabel()
        var usernameLabelWidth = cell.frame.width - profileButton.frame.width - (shareButton.frame.width * 2) - ideaTotalButton.frame.width - 10
        usernameLabel.frame = CGRectMake(profileButton.frame.maxX + 5, profileButton.frame.maxY - profileButton.frame.height/2, usernameLabelWidth, 20)
        usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        usernameLabel.textColor = twoHundredGrayColor
        usernameLabel.text = usernameArray[indexPath.row]
        cell.addSubview(usernameLabel)
        
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let topicsDetaiController = TopicsDetailViewController()
        self.navigationController?.pushViewController(topicsDetaiController, animated: true)
        
        
    }
    
    // MARK: - Image Functions
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)!
        
        return image
    }
    func imageToGray(image: UIImage) -> UIImage{
        
        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.None.rawValue)
        let context =  CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), 8, 0, colorSpace, bitmapInfo)
        
        CGContextDrawImage(context, imageRect, image.CGImage)
        
        let imageRef = CGBitmapContextCreateImage(context)
        
        let newImage = UIImage(CGImage: CGImageCreateCopy(imageRef))
        
        return newImage!
    }
    func imageToRed(image: UIImage) -> UIImage{
        
        let filter = CIFilter(name: "CIColorMonochrome")
        let context = CIContext(options: nil)
        var ciImage = CIImage(image: image)
        var extent: CGRect!
        extent = CGRectMake(0, 0, image.size.width, image.size.height)
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        let redCiColor = CIColor(red: 255/255, green: 100/255, blue: 100/255)
        
        filter.setValue(redCiColor, forKey: kCIInputColorKey)
        let imageRed = UIImage(CGImage: context.createCGImage(filter.outputImage, fromRect: extent))
        
        return imageRed!
    }
    

    
    
    // MARK: - Button Tap Actions
    func profileTapped(sender: UIButton!){
        println(sender.tag)
        
    }
    func viewIdeas(sender: UIButton!){
        println(sender.tag)
    }
    func composeForTopic(sender: UIButton!){
        println(sender.tag)
    }
    func shareTopic(sender: UIButton!){
        println(sender.tag)
    }
    func composeOriginal(sender: UIButton!){
        
        let composeVC = ComposeViewController()
        
        self.presentViewController(composeVC, animated: true, completion: nil)
        
    }
    func changeView(sender: UISegmentedControl){
        
        println(sender.selectedSegmentIndex)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
