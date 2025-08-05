//
//  UpgradePremiumVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 6/17/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class UpgradePremiumVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tblPremium:UITableView!
    var arrBenefits = [""]
    override func viewDidLoad() {
        super.viewDidLoad()
        tblPremium.register(UINib(nibName: "PremiumViewCell", bundle: nil),
                          forCellReuseIdentifier: "PremiumViewCell")
        tblPremium.register(UINib(nibName: "PremiumPlanCell", bundle: nil),
                          forCellReuseIdentifier: "PremiumPlanCell")
        tblPremium.register(UINib(nibName: "BenefitsCell", bundle: nil),
                          forCellReuseIdentifier: "BenefitsCell")
        
        // Do any additional setup after loading the view.
        self.getPremiumBenefitsAPI()
    }
    
    func getPremiumBenefitsAPI(){
        
            
            DispatchQueue.main.async {
                Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
            }
        
         
            URLhandler.sharedinstance.makeGetAPICall(url:Constant.sharedinstance.getPremiumBenefits, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
                
                DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
                
                
                if(error != nil)
                {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }else{
                    
                    let result = responseObject! as NSDictionary
                    let message = result["message"] as? String ?? ""
                    
                    if  result["status"] as? Int ?? 0 == 1 {
                        
                        let data = result["payload"] as? Array<Dictionary<String, Any>> ?? []
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        }
                    }
                }
            })
    }
    
    // MARK: - Navigation
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 3
        }else {
            return arrBenefits.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumViewCell") as! PremiumViewCell
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumPlanCell") as! PremiumPlanCell
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BenefitsCell") as! BenefitsCell
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
