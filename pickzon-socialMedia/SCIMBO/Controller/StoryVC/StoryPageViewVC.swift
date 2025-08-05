//
//  StoryPageViewVC.swift
//  SCIMBO
//
//  Created by Getkart on 04/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit


protocol StoryPageViewControllerDelegate : AnyObject{
    
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
    var isFirst = true
    
    fileprivate lazy var pages: [UIViewController] = {
        
        var views = [UIViewController]()
        self.wallStatusArray.forEach({ wallObj in
            var i = 0
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "StoryViewController") as! StoryViewController
            vc.isMyStatus = self.isMyStatus
            vc.wallStatusObj = wallObj
           
            var urlArray:Array<URL> = Array()
            wallObj.statusArray.forEach({ obj in
                
                if checkMediaTypes(strUrl: obj.media) == 3{
                    if let url = URL(string:  obj.media){
                        urlArray.append(url)
                    }
                }else{
                    
                }
            })
            
            if urlArray.count > 0{
                VideoPreloadManager.shared.set(waiting: urlArray)
            }
            
            vc.startIndex = i
            if startIndex > 0{
                vc.startIndex = startIndex
            }
            vc.view.clipsToBounds = true
            vc.delegate = self
            views.append(vc)
        })
        return views
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController{
        let vc = StoryBoard.main.instantiateViewController(withIdentifier: identifier) as! StoryViewController
        vc.view.clipsToBounds = true
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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        print("pages[currentStatusIndex] = \(currentStatusIndex) ===\(pages.count)")
        if pages.count > currentStatusIndex {
            setViewControllers([pages[currentStatusIndex]], direction: .forward, animated: true, completion: nil)
        }
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        swipeDown.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeDown)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        statusBarHidden = false
        //To play when come back
        if pages.count > currentStatusIndex && isFirst == false{
            pages[currentStatusIndex].viewWillAppear(true)
        }else{
            self.isFirst = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("UIViewcontroller: StatusPageViewController")
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }
    }
    
    deinit {
        self.wallStatusArray.removeAll()
        pages[currentStatusIndex].viewDidAppear(true)
        print("Deinit PAgeView")
    }

    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            
        }else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
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
    
    func previewPreviousStory()
    {
        guard currentStatusIndex-1 < pages.count && currentStatusIndex-1 >= 0  else {
            PlayerHelper.shared.pause()
            isHidden = false
            setNeedsStatusBarAppearanceUpdate()
            customDelegate?.DidDismiss()
            self.dismissView(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            return
        }
        currentStatusIndex = currentStatusIndex-1
        setViewControllers([pages[currentStatusIndex]], direction: .reverse, animated: true, completion: nil)
        if let controller =  pages[currentStatusIndex] as? StoryViewController {
            controller.refreshItemswhenBack()
            
        }
      
    }
    
    
    func currentStoryEnded() {
        guard currentStatusIndex+1 < pages.count  else {
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
        //  DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
        //   let Chat_arr:NSMutableArray = NSMutableArray()
        //   Chat_arr.add(messageFrame)
        //   if(Chat_arr.count > 0)
        //     {
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
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        guard pages.count > previousIndex else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        guard pages.count > nextIndex else { return nil }
        
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("New animation")
        
    }
    
   
}



extension StoryPageViewVC: UIPageViewControllerDelegate { }



