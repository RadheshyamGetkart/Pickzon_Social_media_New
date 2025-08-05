//
//  FeedCommentOptionsVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/11/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

protocol FeedCommentOptionDelegate: AnyObject {
    func whoCanCommentSelected(option:Int,isStory:Int)
}

class FeedCommentOptionsVC: UIViewController {
    
    var commentDelegate:FeedCommentOptionDelegate?
    @IBOutlet weak var switchEnableComment:UISwitch!
    @IBOutlet weak var switchEnableStory:UISwitch!
    @IBOutlet weak var mainBgView:UIView!
    @IBOutlet weak var bgViewComment:UIView!
    @IBOutlet weak var bgViewStory:UIView!
    var isToggleOn = 0
    var isStory = 0
    var isToHideStory = true
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        mainBgView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        switchEnableComment.addTarget(self, action: #selector(whoCanCommentAction(sender: )), for: .valueChanged)
        self.mainBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnView)))
        self.switchEnableComment.isOn = (isToggleOn == 0) ? false : true
        self.switchEnableStory.isOn = (isStory == 0) ? false : true
        if isToHideStory == true{
            bgViewStory.isHidden = true
        }
    }
    
    //MARK: Tapgesture methods
    @objc func tapOnView(){
        self.dismissView(animated: true)
    }
    
    //MARK: UIBUtton Action methods
   
    @IBAction @objc func whoCanCommentAction(sender:UISwitch){
        
        commentDelegate?.whoCanCommentSelected(option: (switchEnableComment.isOn == true) ? 1 : 0, isStory: (switchEnableStory.isOn == true) ? 1 : 0)
        // self.tapOnView()
    }
  
    @IBAction @objc func storyAdd(sender:UISwitch){
        
        commentDelegate?.whoCanCommentSelected(option: (switchEnableComment.isOn == true) ? 1 : 0, isStory: (switchEnableStory.isOn == true) ? 1 : 0)
        // self.tapOnView()
    }
    
}
