//
//  MessageViewController.swift
//  Swapit
//
//  Created by Dustin Yang on 8/13/15.
//  Copyright (c) 2015 Dustin Yang. All rights reserved.
//

import UIKit
import FoldingTabBar
import CoreGraphics;



class MessageViewController:JSQMessagesViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
     private let barSize : CGFloat = 100.0
    var room:PFObject!
    var incomingUser : PFUser!
    var users = [PFUser]()
    var itemImageObj :String!
    
    var messages = [JSQMessage]()
    var messageObjects = [PFObject]()
    
    var outgoingBubbleImage :JSQMessagesBubbleImage!
    var incomingBubbleImage :JSQMessagesBubbleImage!
    
    var selfAvartar : JSQMessagesAvatarImage!
    var incomingAvartar: JSQMessagesAvatarImage!
    
    var whatIlikedView : UIView = UIView()
    var whatOtherslikedView : UIView = UIView()

    
    
    var whatIinterested : [UIImage] = []
    var whatOthersinterested : [UIImage] = []
    
    
    var keepRef:JSQMessagesInputToolbar!
    var searchBar:UISearchBar!

    var scrollview2 : UIScrollView! = UIScrollView()
    var scrollview3 : UIScrollView! = UIScrollView()

    
    var moreClicked : Bool = false
    var userlocation:String!
    
    
    var locationManager : LocationManager!
    var hide:Bool = true
    
    override func viewWillAppear(animated: Bool) {


        moreClicked = false
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.tabBarController.tabBarView.hidden = true
        self.tabBarController?.tabBar.hidden = true
        
        self.title = "Messages"

        let nav = self.navigationController?.navigationBar
        // nav?.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0)
        // nav?.tintColor = UIColor(red: 31/255, green: 96/255, blue: 246/255, alpha: 1.0)
        nav?.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        let btnName: UIButton = UIButton()
        btnName.setImage(UIImage(named: "icon_arrow_left.png"), forState: .Normal)
        btnName.frame = CGRectMake(0, 0, 20, 20)
        btnName.addTarget(self, action: Selector("leftpressed"), forControlEvents: .TouchUpInside)
        
        //.... Set Right/Left Bar Button item
        let leftbutton:UIBarButtonItem = UIBarButtonItem()
        leftbutton.customView = btnName
        self.navigationItem.leftBarButtonItem = leftbutton
        
        
        let btnName2: UIButton = UIButton()
        btnName2.setImage(UIImage(named: "btn_menu"), forState: .Normal)
        btnName2.tintColor = UIColor.whiteColor()
        btnName2.frame = CGRectMake(0, 0, 20, 20)
        btnName2.addTarget(self, action: Selector("rightpressed"), forControlEvents: .TouchUpInside)
        
        //.... Set Right/Left Bar Button item
        let rightbutton:UIBarButtonItem = UIBarButtonItem()
        rightbutton.customView = btnName2
        self.navigationItem.rightBarButtonItem = rightbutton
        
        
        self.senderId = PFUser.currentUser()!.objectId
        self.senderDisplayName = PFUser.currentUser()!.username
        
        let currentUser = PFUser.currentUser()!
        self.inputToolbar!.contentView!.leftBarButtonItem = nil
        
        let selfUsername = PFUser.currentUser()!.username! as NSString
        let incomingUsername = incomingUser.username! as NSString
        
        selfAvartar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(selfUsername.substringWithRange(NSMakeRange(0, 2)), backgroundColor: UIColor.blackColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        
        incomingAvartar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(incomingUsername.substringWithRange(NSMakeRange(0, 2)), backgroundColor: UIColor.blackColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        
        //Chat image
        //   let selfProfileImageFile = PFUser.currentUser()["profileImage"] as? PFFile!
        // let otherUserProfileImageFile = incomingUser["profileImage"] as? PFFile!
        
        if let selfProfileImageFile = currentUser["profileImage"] as? PFFile{
            if  let otherUserProfileImageFile = incomingUser["profileImage"] as? PFFile
            {
                selfProfileImageFile.getDataInBackgroundWithBlock({ (result, error) -> Void in
                    
                    if error == nil
                    {
                        
                        otherUserProfileImageFile.getDataInBackgroundWithBlock({ (result2, error2) -> Void in
                            if error2 == nil
                            {
                                let selfImage = UIImage(data: result!)
                                let incomingImage = UIImage(data: result2!)
                                
                                self.selfAvartar = JSQMessagesAvatarImageFactory.avatarImageWithImage(selfImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                                self.incomingAvartar = JSQMessagesAvatarImageFactory.avatarImageWithImage(incomingImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                                
                            }
                        })
                        
                    }
                    
                    
                })
                
            }
        }
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(backgroundColor)
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        
        //  dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
        displayProducts()

        self.loadMessages()
        // })
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = LocationManager.sharedInstance

        self.tabBarController?.tabBar.hidden = true
        whatIlikedView.frame  = CGRectMake(0, 0, screenWidth, screenHeight*0.2)
        whatIlikedView.backgroundColor = UIColor.whiteColor()
        
        
        scrollview2.frame = CGRectMake(0, 0, whatIlikedView.frame.width*0.4, screenHeight*0.2)
        scrollview3.frame = CGRectMake(whatIlikedView.frame.width*0.6, 0, whatIlikedView.frame.width*0.4, screenHeight*0.2)
        scrollview2.showsHorizontalScrollIndicator = false;
        scrollview2.showsVerticalScrollIndicator = false;
        scrollview3.showsHorizontalScrollIndicator = false;
        scrollview3.showsVerticalScrollIndicator = false;
        
        self.scrollview2.delegate = self
        self.scrollview3.delegate = self

    
     
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadMessages", name: "reloadMessages", object: nil)

        
    }
    
    
    
    override func viewDidDisappear(animated: Bool) {
        // super.viewDidAppear(animated)
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reloadMessages", object: nil)
        
    }
    
    
    // LOAD MEssage -Dustin 8/11
    func loadMessages()
    {
        
        var lastMessage : JSQMessage?  = nil;
        
        if messages.last != nil
        {
            lastMessage = messages.last
        }
        
        
        let messageQuery = PFQuery(className:"Message")
        messageQuery.whereKey("room", equalTo: room)
        messageQuery.orderByAscending("updatedAt")
        
        messageQuery.limit = 1000
        messageQuery.includeKey("user")
        
        
        if lastMessage != nil
        {
            messageQuery.whereKey("createdAt", greaterThan: lastMessage!.date)
            
        }
        messageQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error == nil
            {
                let messages = results as! [PFObject]
                
                
                for message in messages
                {
                    self.messageObjects.append(message)
                    let user = message["user"] as! PFUser
                    self.users.append(user)
                    
                    let chatMessage = JSQMessage(senderId: user.objectId, senderDisplayName: user.username, date: message.createdAt, text: message["content"] as! String)
                    self.messages.append(chatMessage)
                }
                
                
                if results!.count != 0
                {
                    //self.finishReceivingMessage()
                    
                    self.finishReceivingMessageAnimated(true)
                }
            }
        }
        
        
        // Fix the bug when message is received while chatting. But unread indicator is still showing when moved to overview screen
        //  let sb = UIStoryboard(name: "Main", bundle: nil)
        // let messageVC = sb.instantiateViewControllerWithIdentifier("ChatOverView") as? OverViewController
        
        let user1 = PFUser.currentUser()!
        let user2 = incomingUser
 
     let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1,user2,user2,user1)
      //  let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ AND item = %@ OR user1 = %@ AND user2 = %@  AND item = %@ ", user1,user2,self.itemImageObj!,user2,user1,self.itemImageObj!)

        let roomQuery = PFQuery(className: "Room", predicate: pred)
        
        roomQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error == nil
            {
                // let room = results!.last as! PFObject
                //     messageVC!.room = room
                // println("room is \(room)")
                //    messageVC?.incomingUser = user2
                
                let unreadQuery = PFQuery(className: "UnreadMessage")
                unreadQuery.whereKey("user", equalTo: PFUser.currentUser()!)
                unreadQuery.whereKey("room", equalTo: self.room)
                unreadQuery.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                    if error == nil
                    {
                        if results!.count > 0{
                            let unreadMessages = results! as? [PFObject]
                            //    println(unreadMessges)
                            for msg in unreadMessages! {
                                msg.deleteInBackgroundWithBlock(nil)
                                
                            }
                            
                            
                        }
                        
                    }
                })
            }
        }
        
        
        
        
        
    }
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let user1 = PFUser.currentUser()!
        let user2 = incomingUser
        
        if( hide )
        {

            let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1,user2,user2,user1)
            let roomQuery = PFQuery(className: "Room", predicate: pred)
        
            roomQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if error == nil
                {
                    if results!.count > 0
                    {
                        let room = results?.last as? PFObject
                        room?.removeObject(self.incomingUser.username!, forKey: "hide")
                        room?.removeObject(PFUser.currentUser()!.username!, forKey: "hide")

                      //  room!.addUniqueObject(PFUser.currentUser()!.username!, forKey:"hide")
                        room?.saveEventually()
                        
                    }
                }
            }
            hide = false
        }
        
        
        
        let message = PFObject(className: "Message")
        message["content"] = text;
        message["room"] = room
        message["user"] = PFUser.currentUser()!
        
        let currentUser = PFUser.currentUser()!
        let msgACL = PFACL()
        msgACL.setReadAccess(true, forRoleWithName: currentUser.objectId!)
        msgACL.setReadAccess(true, forRoleWithName: incomingUser.objectId!)
        msgACL.setWriteAccess(true, forRoleWithName: currentUser.objectId!)
        msgACL.setWriteAccess(true, forRoleWithName: incomingUser.objectId!)
        
        message.ACL = msgACL
        
        message.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil
            {
                self.loadMessages()
                
                let pushQuery = PFInstallation.query()
                pushQuery?.whereKey("user", equalTo: self.incomingUser)
                
                let push = PFPush()
                push.setQuery(pushQuery)
                
                let pushDict = ["alert":text, "badge":"Increment","sound":""]
                push.setData(pushDict)
                
                let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1,user2,user2,user1)
                let roomQuery = PFQuery(className: "Room", predicate: pred)
              //  roomQuery.whereKey("Blocked", notEqualTo: user2)
                roomQuery.whereKey("Blocked", equalTo: user2.username!)
                
                roomQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                    if error == nil
                    {
                        print("result for push is \(results!.count)")
                        print("user2 \(user2.username)")

                        if results!.count == 0
                        {
                            //send push only he didnt blocked the room
                            push.sendPushInBackgroundWithBlock(nil)
                            
                        }
                    }
                }

                self.room["lastUpdate"] = NSDate()
                self.room.saveInBackgroundWithBlock(nil)
                
                let unreadMsg = PFObject(className: "UnreadMessage")
                unreadMsg["user"] = self.incomingUser
                unreadMsg["room"] = self.room
                
                unreadMsg.saveInBackgroundWithBlock(nil)
                
                
            }
            else
            {
                
                print("Error sending msg\(error?.localizedDescription)")
                
            }
            
            self.finishSendingMessage()
        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
        
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        if message.senderId == self.senderId
        {
            
            return outgoingBubbleImage
        }
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        if message.senderId == self.senderId
        {
            
            return selfAvartar
        }
        return incomingAvartar
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {

        if (indexPath.item) % 2 == 0
        {
            
            let message = messages[indexPath.row]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }

        return nil
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
 
        if (indexPath.item) % 2 == 0
        {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
       // cell.frame.offsetInPlace(dx: 0, dy: self.view.frame.height*0.1)
        let message = messages[indexPath.row]
        
        if message.senderId == self.senderId
        {
            
            cell.textView!.textColor = UIColor.whiteColor()
        }
        else
        {
            cell.textView!.textColor = UIColor.whiteColor()
        }
        //       let attributes  = [NSForegroundColorAttributeName:cell.textView!.textColor]
        
        //      cell.textView!.linkTextAttributes = attributes
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func viewWillDisappear(animated: Bool) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(moreClicked)
        {
            appDelegate.tabBarController.tabBarView.hidden = true
        }
        else
        {
            appDelegate.tabBarController.tabBarView.hidden = false
        }
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateButton(xOffset: CGFloat, image:UIImage) {
        
        let MyImageView : UIImageView = UIImageView()
        
        MyImageView.frame = CGRectMake(xOffset, self.scrollview2.frame.height*0.58, self.scrollview2.frame.height*0.4,self.scrollview2.frame.height*0.4)
        MyImageView.image = image
        MyImageView.layer.cornerRadius = MyImageView.frame.size.width/2
        
        MyImageView.clipsToBounds = true
        scrollview2.addSubview(MyImageView)
        
    }
    func generateButton2(xOffset: CGFloat, image:UIImage) {
        
        let MyImageView : UIImageView = UIImageView()
        
        //  WhatMyImageView.frame  = CGRectMake(xOffset,screenHeight, xOffset+20, screenHeight*0.25)
        MyImageView.frame = CGRectMake(xOffset, self.scrollview3.frame.height*0.58, self.scrollview3.frame.height*0.4,self.scrollview2.frame.height*0.4)
        MyImageView.image = image
        MyImageView.layer.cornerRadius = MyImageView.frame.size.width/2
        
        MyImageView.clipsToBounds = true
        scrollview3.addSubview(MyImageView)
        
    }
    
    /* for chatting window */

    
    func displayProducts()
    {


        
        whatIinterested.removeAll(keepCapacity: false)
        whatOthersinterested.removeAll(keepCapacity: false)

        let query:PFQuery = PFQuery(className: "imageUpload")
        query.whereKey("user", equalTo: incomingUser)
        query.whereKey("chat", equalTo: PFUser.currentUser()!.username!)
        var count : Int = 0
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error  == nil
            {
                for obj in objects!{
                    let thumbNail = obj["image"] as! PFFile
                    print("objects cpunt \(objects!.count)")
                    
                    thumbNail.getDataInBackgroundWithBlock({(imageData, error) -> Void in
                        if (error == nil) {
                            let image = UIImage(data:imageData!)
                            self.whatIinterested.append(image!)

                            count = self.whatIinterested.count
                            if(objects!.count == self.whatIinterested.count && objects!.count >= 1){
                                
                                var xOffset  = screenWidth*0.05 as CGFloat
                                for (_,image) in self.whatIinterested.enumerate()
                                {
                                    self.generateButton(xOffset, image: image)
                                    xOffset+=screenWidth*0.15
                                }
                               self.scrollview2.contentSize = CGSizeMake(self.whatIlikedView.frame.height*0.4 * CGFloat(count)+CGFloat(screenWidth*0.1), self.scrollview2.frame.height)
                               self.whatIlikedView.addSubview(self.scrollview2)
                              
                            }
                            
                        }
                    })
                }
            }
            else
            {
                
                print("errror")
            }
        }
        
        let query2:PFQuery = PFQuery(className: "imageUpload")
        query2.whereKey("user", equalTo: PFUser.currentUser()!)
        query2.whereKey("chat", equalTo: incomingUser.username!)
        var count2 : Int = 0
        query2.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error  == nil
            {
                
                print("objects count is \(objects!.count)")
                for obj in objects!{
                    let thumbNail = obj["image"] as! PFFile
                    
                    thumbNail.getDataInBackgroundWithBlock({(imageData, error) -> Void in
                        if (error == nil) {
                            let image = UIImage(data:imageData!)
                            self.whatOthersinterested.append(image!)
                            
                            count2 = self.whatOthersinterested.count
                            if(objects!.count == self.whatOthersinterested.count && objects!.count >= 1){
                                
                                var xOffset  = screenWidth*0.05 as CGFloat
                                for (_,image) in self.whatOthersinterested.enumerate()
                                {
                                    self.generateButton2(xOffset, image: image)
                                    xOffset+=screenWidth*0.15
                                }
                                self.scrollview3.contentSize = CGSizeMake(self.whatIlikedView.frame.height*0.4 * CGFloat(count2)+CGFloat(screenWidth*0.1), self.scrollview3.frame.height)
                                self.whatIlikedView.addSubview(self.scrollview3)
                                
                            }
                            
                        }
                    })
                }
            }
            else
            {
                
                print("errror")
            }
        }
        self.view.addSubview(self.whatIlikedView)

    }
  
    func leftpressed()
    {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func rightpressed()
    {
        let SettingactionSheet = UIAlertController(title: "More Option", message: "Select an option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        
        
        SettingactionSheet.addAction(UIAlertAction(title: "View Profile", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            self.moreClicked = true
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let profileVC = sb.instantiateViewControllerWithIdentifier("viewProfile") as? viewProfile
            
            var userlocation : String!
            
            let location = CLLocationCoordinate2D(latitude: self.incomingUser["location"]!.latitude,longitude: self.incomingUser["location"]!.longitude)
            let locationFromGeoPoint: CLLocation  = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.locationManager.reverseGeocodeLocationWithCoordinates(locationFromGeoPoint, onReverseGeocodingCompletionHandler: { (reverseGecodeInfo, placemark, error) -> Void in
                print(reverseGecodeInfo)
                if( reverseGecodeInfo != nil)
                {
                    let local = reverseGecodeInfo?.objectForKey("locality") as! String
                    let sublocal = reverseGecodeInfo?.objectForKey("subLocality") as! String
                    userlocation = "\(sublocal),\(local)"
                    profileVC?.otherUser = self.incomingUser
                    profileVC?.userLocation = userlocation
                    
                    
                    let transition : CATransition = CATransition()
                    transition.duration = 0.8
                    transition.type = kCATransitionFade;
                    transition.subtype = kCATransitionFromLeft;
                    
                    self.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
                    self.navigationController!.pushViewController(profileVC!, animated: true)
                    
                    
                   // self.navigationController?.pushViewController(profileVC!, animated: true)
                    
                    
                }

                
            })
            
           
           

            
            
            
        }))
        
        SettingactionSheet.addAction(UIAlertAction(title: "Block User", style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction!) -> Void in
            
            
            let uiAlert = UIAlertController(title: "Block", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { action in
                
                let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", PFUser.currentUser()!, self.incomingUser,self.incomingUser,PFUser.currentUser()!)
            
                let roomQuery = PFQuery(className: "Room", predicate: pred)
            
            roomQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if error == nil
                {
                    if results!.count > 0
                    {
                        let room = results?.last as? PFObject
                        room!.addUniqueObject(PFUser.currentUser()!.username!, forKey:"Blocked")
                      //  room?.saveEventually()
                        room!.saveInBackgroundWithBlock { (success, error) -> Void in
                            if(error == nil)
                            {
                                 self.navigationController?.popViewControllerAnimated(true)
                            }
                        }

                      
                        
                        
                    }
                }
            }
            
            
            
            }))
            uiAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                print("Blocl canceled")
            }))
            
        }))
        
        SettingactionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel  , handler: nil))
        self.presentViewController(SettingactionSheet, animated: true, completion: nil)
        
      
        
        
    }
    
}