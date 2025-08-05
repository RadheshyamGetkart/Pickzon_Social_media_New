//
//  CreateAddDetailVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 5/19/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class CreateAddDetailVC: UIViewController {
    var postId = ""
    
    @IBOutlet weak var scrScrollView:UIScrollView!
    @IBOutlet weak var btnDateStart:UIButton!
    @IBOutlet weak var btnDateEnd:UIButton!
    
    @IBOutlet weak var btnCurrencyName:UIButton!
    @IBOutlet weak var btnCurrency:UIButton!
    
    @IBOutlet weak var btnPplLikeAndFriend:UIButton!
    @IBOutlet weak var btnOptionPplLikeAndFriend:UIButton!
    
    
    @IBOutlet weak var btnPeopleArea:UIButton!
    @IBOutlet weak var btnOptionPeopleArea:UIButton!
    
    @IBOutlet weak var btnTargetPeople:UIButton!
    @IBOutlet weak var btnOptionTargetPeople:UIButton!
    
    @IBOutlet weak var viewGender:UIView!
    @IBOutlet weak var btnMale:UIButton!
    @IBOutlet weak var btnFeMale:UIButton!
    @IBOutlet weak var btnAllGender:UIButton!
    
    
    
    
    @IBOutlet weak var viewTargetAudience:UIView!
    let rangeSlider1 = RangeSlider(frame: CGRect.zero)
    let lblStartAge:UILabel = UILabel(frame: CGRect.zero)
    let lblEndAge:UILabel = UILabel(frame: CGRect.zero)
    
    
    @IBOutlet weak var viewMapBack:UIView!
    
    
    @IBOutlet weak var viewPeopleReach:UIView!
    @IBOutlet weak var sliderPeopleReach:UISlider!
    @IBOutlet weak var lblCurrentReach:UILabel!
    
    
    
    
    @IBOutlet weak var btnNext:UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDateStart.layer.cornerRadius = 5.0
        btnDateEnd.layer.cornerRadius = 5.0
        
        btnCurrencyName.layer.cornerRadius = 5.0
        btnCurrency.layer.cornerRadius = 5.0
        
        btnPplLikeAndFriend.layer.cornerRadius = 5.0
        btnPeopleArea.layer.cornerRadius = 5.0
        btnTargetPeople.layer.cornerRadius = 5.0
        
        viewGender.isHidden = true
        viewTargetAudience.isHidden = true
        viewMapBack.isHidden = true
        
        btnMale.layer.cornerRadius = 5.0
        btnFeMale.layer.cornerRadius = 5.0
        btnAllGender.layer.cornerRadius = 5.0
        
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider1.frame = CGRect(x: margin, y: viewTargetAudience.frame.height - 70,
                                    width: width, height: 31.0)
        rangeSlider1.trackHighlightTintColor = UIColor.red
        rangeSlider1.minimumValue = 0
        rangeSlider1.maximumValue = 65
        
        rangeSlider1.lowerValue = 0
        rangeSlider1.upperValue = 65
        
        
        viewTargetAudience.addSubview(rangeSlider1)
        rangeSlider1.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
        
        lblStartAge.frame = CGRect(x: rangeSlider1.frame.origin.x, y: rangeSlider1.frame.origin.y
                                   + 30,
                                   width: 100.0, height: 31.0)
        self.lblStartAge.text = String(format: "Min Age: %0.0f", arguments: [rangeSlider1.lowerValue ])
        viewTargetAudience.addSubview(lblStartAge)
        
        lblEndAge.frame = CGRect(x: (rangeSlider1.frame.origin.x + rangeSlider1.frame.width - 100), y: rangeSlider1.frame.origin.y
                                   + 30,
                                   width: 100.0, height: 31.0)
        self.lblEndAge.text = String(format: "Max Age: %0.0f", arguments: [rangeSlider1.upperValue])
        viewTargetAudience.addSubview(lblEndAge)
        
        btnNext.layer.cornerRadius = btnNext.frame.height / 2.0
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrScrollView.contentSize = CGSize(width: self.view.frame.width - 10, height: 1500)
        
    }
    
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonAction() {
        let viewController:AddPreviewVC = StoryBoard.promote.instantiateViewController(withIdentifier: "AddPreviewVC") as! AddPreviewVC
        viewController.postId = self.postId
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) , \(rangeSlider.upperValue))")
        DispatchQueue.main.async(execute: { [self] in
            self.lblStartAge.text = String(format: "Min Age: %0.0f", arguments: [rangeSlider.lowerValue ])
            self.lblEndAge.text = String(format: "Max Age: %0.0f", arguments: [rangeSlider.upperValue])
            
        })
        
    }
    
    @IBAction func audienceSelected(sender:UIButton) {
        print(sender.tag)
        btnPplLikeAndFriend.backgroundColor = UIColor.systemGray5
        btnPplLikeAndFriend.setTitleColor(UIColor.black, for: .normal)
        btnOptionPplLikeAndFriend.setImage(UIImage(named: "unselectedRadio"), for: .normal)
        
        btnPeopleArea.backgroundColor = UIColor.systemGray5
        btnPeopleArea.setTitleColor(UIColor.black, for: .normal)
        btnOptionPeopleArea.setImage(UIImage(named: "unselectedRadio"), for: .normal)
        
        btnTargetPeople.backgroundColor = UIColor.systemGray5
        btnTargetPeople.setTitleColor(UIColor.black, for: .normal)
        btnOptionTargetPeople.setImage(UIImage(named: "unselectedRadio"), for: .normal)
        
        viewGender.isHidden = true
        viewTargetAudience.isHidden = true
        viewMapBack.isHidden = true
        
        
        if sender.tag == 101 {
            btnPplLikeAndFriend.backgroundColor = UIColor.systemBlue
            btnPplLikeAndFriend.setTitleColor(UIColor.white, for: .normal)
            btnOptionPplLikeAndFriend.setImage(UIImage(named: "selectedRadio"), for: .normal)
            
        }else if sender.tag == 102 {
            
            btnPeopleArea.backgroundColor = UIColor.systemBlue
            btnPeopleArea.setTitleColor(UIColor.white, for: .normal)
            btnOptionPeopleArea.setImage(UIImage(named: "selectedRadio"), for: .normal)
            
        }else if sender.tag == 103 {
            btnTargetPeople.backgroundColor = UIColor.systemBlue
            btnTargetPeople.setTitleColor(UIColor.white, for: .normal)
            btnOptionTargetPeople.setImage(UIImage(named: "selectedRadio"), for: .normal)
            
            viewGender.isHidden = false
            viewTargetAudience.isHidden = false
            viewMapBack.isHidden = false
            
        }
    }
    @IBAction func genderSelected(sender:UIButton) {
        print(sender.tag)
        btnMale.backgroundColor = UIColor.systemGray5
        btnMale.setTitleColor(UIColor.black, for: .normal)
        
        btnFeMale.backgroundColor = UIColor.systemGray5
        btnFeMale.setTitleColor(UIColor.black, for: .normal)
        
        btnAllGender.backgroundColor = UIColor.systemGray5
        btnAllGender.setTitleColor(UIColor.black, for: .normal)
        
        if sender.tag == 11 {//Male Selected
            btnMale.backgroundColor = UIColor.systemBlue
            btnMale.setTitleColor(UIColor.white, for: .normal)
        }else  if sender.tag == 12 {//FeMale Selected
            btnFeMale.backgroundColor = UIColor.systemBlue
            btnFeMale.setTitleColor(UIColor.white, for: .normal)
        }else if sender.tag == 13 {//All Selected
            btnAllGender.backgroundColor = UIColor.systemBlue
            btnAllGender.setTitleColor(UIColor.white, for: .normal)
        }
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value) * 1000
            
        lblCurrentReach.text = "\(currentValue)"
    }

}
