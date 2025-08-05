//
//  BoostPostVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/3/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class BoostPostVC: UIViewController {
/*
 boost: { type: Number }
  
             0 default
             1 pending boost post
             2 approved boost post
             3 rejected boost post
  
 If any post boost value is 1 or 2  - User can not edit that post even in the 24 hours of time period.
 */
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var imgVwPost:UIImageView!
   
    
    var pageMenu : CAPSPageMenu?
    var objWallpost:WallPostModel?

    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        let createboostVc =  StoryBoard.promote.instantiateViewController(withIdentifier: "CreateBoostVC") as! CreateBoostVC
        createboostVc.title = "Create"
        createboostVc.objWallpost = objWallpost
        controllerArray.append(createboostVc)
        
        
        let dashboardVC =  StoryBoard.promote.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
        dashboardVC.title = "Dashboard"
        controllerArray.append(dashboardVC)

        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(2.0),
            .menuItemSeparatorPercentageHeight(0.1),
            .menuItemWidth(self.view.frame.size.width/2-50),
            .centerMenuItems(true),
            .bottomMenuHairlineColor(UIColor.lightGray),
            .selectionIndicatorColor(UIColor.label),
            .scrollMenuBackgroundColor(UIColor.systemBackground),
            .selectedMenuItemLabelColor(.label),
            .unselectedMenuItemLabelColor(.darkGray),
            .menuHeight(25)
        ]

        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, cnstrntHtNavBar.constant, self.view.frame.width, self.view.frame.height-cnstrntHtNavBar.constant), pageMenuOptions: parameters)
        pageMenu?.delegate = self
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear BoostPostVC")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear BoostPostVC")

    }
    
    //MARK: UIButton Action Methods
    
    @IBAction func backBtnActionMethod(_ sender:UIButton){
   
        self.navigationController?.popViewController(animated: true)
    }
}



extension BoostPostVC : CAPSPageMenuDelegate {

  
    func willMoveToPage(_ controller: UIViewController, index: Int){
        //print(index)
    }

    func didMoveToPage(_ controller: UIViewController, index: Int){
        //print(index)
    }

}
