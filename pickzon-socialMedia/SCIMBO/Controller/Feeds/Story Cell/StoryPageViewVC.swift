//
//  StoryPageViewVC.swift
//  SCIMBO
//
//  Created by Getkart on 04/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit


protocol StoryPageViewControllerDelegate : class{
    
    func DidDismiss()
    func didClickDelete(_ messageFrame : WallStatus.StoryStaus)
    func didclickedViewCount()
}



class StoryPageViewVC: UIPageViewController {
  
    weak var customDelegate:StoryPageViewControllerDelegate?

    var isMyStatus = false
    var currentStatusIndex = 0
    var statusBarHidden = true
    var wallStatusArray = [WallStatus]()
    var idArr = [String]()
    var startIndex : Int = Int()
    var isFromView : Bool = Bool()
   // var wallStatusObj = WallStatus(responseDict: NSDictionary())

    
    fileprivate lazy var pages: [UIViewController] = {
        
        
    
            
            var views = [UIViewController]()
        
            self.wallStatusArray.forEach({ wallObj in
               
                
//                if(wallStatusObj.user != Themes.sharedInstance.Getuser_id())
//                {
                    var i = 0
//                    let datasource : NSMutableArray = self.wallStatusArray[id]!
//                    for messageFrame in datasource {
//                        let messageFrame : UUMessageFrame = messageFrame as! UUMessageFrame
//
//                        if(messageFrame.message.is_viewed != "1")
//                        {
//                            i = datasource.index(of: messageFrame) - 1
//                            break
//                        }
//                    }
//                    if(i < 0 || i > 0)
//                    {
//                        i = i + 1
//                    }
                    let vc = StoryBoard.main.instantiateViewController(withIdentifier: "StoryViewController") as! StoryViewController
                    vc.isMyStatus = self.isMyStatus
                    vc.wallStatusObj = wallObj
                    vc.startIndex = i
                    //vc.userId = id
                    vc.view.clipsToBounds = true
                     vc.delegate = self
                    views.append(vc)
               // }
            })
            return views
        
        
        
        
        
        
        ///
        
//        var views = [UIViewController]()
//        self.wallStatusObj.statusArray.forEach({ id in
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoryViewController") as! StoryViewController
//        vc.isMyStatus = self.isMyStatus
//        vc.wallStatusObj = wallStatusObj
//        //vc.statusArray = self.wallStatusArray[id]!
//        vc.startIndex = self.startIndex
//        vc.isFromView = self.isFromView
//        vc.userId = Themes.sharedInstance.Getuser_id()
//        vc.view.clipsToBounds = true
//        vc.delegate = self
//        views.append(vc)
//        })
//        return views

        /*
        if(self.isMyStatus)
        {
            var views = [UIViewController]()
            self.idArr.forEach({ id in
                if(id == Themes.sharedInstance.Getuser_id())
                {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoryViewController") as! StoryViewController
                    vc.isMyStatus = self.isMyStatus
                    vc.wallStatusObj = wallStatusObj
                    //vc.statusArray = self.wallStatusArray[id]!
                    vc.startIndex = self.startIndex
                    vc.isFromView = self.isFromView
                    vc.userId = Themes.sharedInstance.Getuser_id()
                    vc.view.clipsToBounds = true
                   // vc.delegate = self
                    views.append(vc)
                }
            })
            return views
        }
        else
        {
            
            var views = [UIViewController]()
            self.idArr.forEach({ id in
                if(id != Themes.sharedInstance.Getuser_id())
                {
                    var i = 0
                    let datasource : NSMutableArray = self.wallStatusArray[id]!
                    for messageFrame in datasource {
                        let messageFrame : UUMessageFrame = messageFrame as! UUMessageFrame
                        
                        if(messageFrame.message.is_viewed != "1")
                        {
                            i = datasource.index(of: messageFrame) - 1
                            break
                        }
                    }
                    if(i < 0 || i > 0)
                    {
                        i = i + 1
                    }
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoryViewController") as! StoryViewController
                    vc.isMyStatus = self.isMyStatus
                    vc.statusArray = self.wallStatusArray[id]!
                    vc.startIndex = i
                    vc.userId = id
                    vc.view.clipsToBounds = true
                 //   vc.delegate = self
                    views.append(vc)
                }
            })
            return views
        }*/
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        let vc = StoryBoard.main.instantiateViewController(withIdentifier: identifier) as! StoryViewController
        vc.view.clipsToBounds = true
        //vc.delegate = self
        vc.isMyStatus = isMyStatus
        return vc
    }
    
    var isHidden = true{
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        
        //        if let firstVC : UIViewController = pages[currentStatusIndex]
        //        {
        
        print("pages[currentStatusIndex] = \(currentStatusIndex) ===\(pages.count)")
        if pages.count > currentStatusIndex {
        setViewControllers([pages[currentStatusIndex]], direction: .forward, animated: true, completion: nil)
        //        }
        }
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        swipeDown.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        statusBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("UIViewcontroller: StatusPageViewController")
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
            
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }
    }
    
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            print("Swipe Up")
            
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            print("Swipe Down")
            isHidden = false
            setNeedsStatusBarAppearanceUpdate()
            customDelegate?.DidDismiss()
            self.dismissView(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)

        }
    }
}

extension StoryPageViewVC:StoryViewControllerDelegate{
   
    func didClickDelete(_ messageFrame: WallStatus.StoryStaus) {
        isHidden = false
        setNeedsStatusBarAppearanceUpdate()
        customDelegate?.didClickDelete(messageFrame)
        self.dismissView(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func didClickReplyMessage(_ messageFrame: WallStatus, _ message: String, _ toId: String) {
        
        
    }
    
    func currentStoryEnded() {
        guard currentStatusIndex+1 < pages.count else {
            PlayerHelper.shared.pause()
            isHidden = false
            setNeedsStatusBarAppearanceUpdate()
            customDelegate?.DidDismiss()
            self.dismissView(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)

            return
        }
        
        guard pages.count > currentStatusIndex+1 else {
            isHidden = false
            setNeedsStatusBarAppearanceUpdate()
            customDelegate?.DidDismiss()
            self.dismissView(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)

            return
        }
        currentStatusIndex = currentStatusIndex+1
        setViewControllers([pages[currentStatusIndex]], direction: .forward, animated: true, completion: nil)
    }
    
    func backButtonClicked() {
        isHidden = false
        setNeedsStatusBarAppearanceUpdate()
        customDelegate?.DidDismiss()
        self.dismissView(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func didClickViewStatusUsers(statusId:String){
        let profileVC:LikeUsersVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LikeUsersVC") as! LikeUsersVC
        profileVC.controllerType = .storyView
        profileVC.postId = statusId
        self.pushView(profileVC, animated: true)
        self.dismissView(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    func didClickForward(_ messageFrame: WallStatus) {
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
        //
        //            let Chat_arr:NSMutableArray = NSMutableArray()
        //            Chat_arr.add(messageFrame)
        //            if(Chat_arr.count > 0)
        //            {
        //                let selectShareVC = self.storyboard?.instantiateViewController(withIdentifier:"SelectShareContactViewController" ) as! SelectShareContactViewController
        //                selectShareVC.messageDatasourceArr =  Chat_arr
        //                selectShareVC.isFromForward = true
        //                selectShareVC.isFromStatus = true
        //                self.pushView(selectShareVC, animated: true)
        //            }
        //        })
    }
}

extension StoryPageViewVC: UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return nil }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
}



extension StoryPageViewVC: UIPageViewControllerDelegate { }



