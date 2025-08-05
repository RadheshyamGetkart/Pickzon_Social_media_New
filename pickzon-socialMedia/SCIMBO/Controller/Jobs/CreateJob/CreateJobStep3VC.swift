//
//  CreateJobStep3VC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 2/28/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class CreateJobStep3VC: UIViewController {
    
    @IBOutlet weak var tblJob:UITableView!
    
    var titleArray = ["Job Title", "Work Place Type", "Industry", "Job Type", "Company Name","Salary", "No. of openings", "Job Location","Gender", "Education", "Experience Level", "Preferred Skills", "Job description"]
    let iconArray = ["pageName","Tagline","Category","Web","Companysize","pageName","Tagline","Category","Web","Companysize","Companytype","Mobile","Mail","yearFound","Location","Description", "Web"]
    var objNewJob = CreateNewJob()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblJob.register(UINib(nibName: "CreateBusinessTblCell", bundle: nil),
                          forCellReuseIdentifier: "CreateBusinessTblCell")
        tblJob.register(UINib(nibName: "DescriptionTblCell", bundle: nil),
                          forCellReuseIdentifier: "DescriptionTblCell")
        tblJob.reloadData()
        
    }
    @IBAction func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func postAJobAction(){
        var param = NSMutableDictionary()
       
        
        
        param = [ "jobTitle": objNewJob.jobTitle,
                  "workplace": objNewJob.workPlaceType,
                  "industry": objNewJob.industry,
                  "jobType": objNewJob.jobType,
                  "company": objNewJob.companyName,
                  "salaryPaid": objNewJob.salaryOptions,
                  "currency":"₹",
                  "minimumSalary": "\(objNewJob.minSalary)",
                  "maximumSalary": "\(objNewJob.maxSalary)",
                  "salaryvisibility" : "\(objNewJob.showSalaryOnPost == true ? 1 : 0)",
                  "openings": "\(objNewJob.noOfOpenings)",
                  "location": [
                    "country": objNewJob.locationObj.country,
                    "state": objNewJob.locationObj.state,
                    "city": objNewJob.locationObj.city
                      ],
                  "gender": objNewJob.gender == 1 ? "male" : objNewJob.gender == 2 ? "female" : "both" ,
                  "education": objNewJob.education,
                      "experienceLevel": objNewJob.experienceLevel,
                  "skills": objNewJob.arrPreferredSkills,
                  "description": objNewJob.jobDescription
         ]
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.createJobURL, param: param) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
                       alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                           for vc in self.navigationController?.viewControllers ?? [] {
                               if vc.isKind(of: JobsHomeVC.self) == true {
                                   self.navigationController?.popToViewController(vc, animated: true)
                                   break
                               }
                           }
                          
                       }))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }

    @IBAction func termsOfServicesAction(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController:PrivacyPolicyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        viewController.strTitle = "Terms of Services"
        viewController.strURl = Constant.sharedinstance.termsURL
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    @IBAction func privacyPolicyAction(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController:PrivacyPolicyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        viewController.strTitle = "Privacy Policy"
        viewController.strURl = Constant.sharedinstance.privacyURL
        self.navigationController?.pushView(viewController, animated: true)
    }
    

}


extension CreateJobStep3VC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       if indexPath.row == 11 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTblCell") as! DescriptionTblCell
           // cell.txtVwDesc.setAttributedPlaceHolder(frstText: titleArray[indexPath.row], color: UIColor.lightGray, size1: 15.0, secondText: "*", secondColor: UIColor.red, size2: 15.0)
            cell.titleLbl.text = titleArray[safe: indexPath.row]?.uppercased()
            cell.txtVwDesc.isUserInteractionEnabled = true
            cell.txtVwDesc.text = objNewJob.jobDescription
            cell.titleLbl.isHidden = (objNewJob.jobDescription.length == 0) ? true : false
          //  cell.iconImgVw.image = UIImage(named: iconArray[indexPath.row] as! String)
            cell.txtVwDesc.tag = indexPath.row
           cell.txtVwDesc.isUserInteractionEnabled = false
            return cell
        }else {
            
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CreateBusinessTblCell") as! CreateBusinessTblCell
                cell.ddImgVw.isHidden = true
                cell.txtFd.iconImage = UIImage(named: iconArray[indexPath.row] )
                cell.txtFd.iconImageView.setImageColor(color: UIColor.lightGray)
                cell.txtFd.tag = indexPath.row
                cell.txtFd.lineView.isHidden = true
                
                
                
            cell.txtFd.setAttributedPlaceHolder(frstText: "", color: UIColor.lightGray, secondText: "", secondColor: UIColor.red)
                
                cell.txtFd.isUserInteractionEnabled = false
                
                switch indexPath.row{
                    
                case 0:
                    cell.txtFd.text = objNewJob.jobTitle
                    break
                case 1:
                    cell.txtFd.text = objNewJob.workPlaceType
                    break
                case 2:
                    cell.txtFd.text = objNewJob.companyName
                    break
                case 3:
                    cell.txtFd.text = "\(objNewJob.minSalary) to \(objNewJob.maxSalary)"
                    break
                case 4:
                    cell.txtFd.text = "\(objNewJob.noOfOpenings)"
                    break
                case 5:
                    cell.txtFd.text = "\(objNewJob.locationObj.city), \(objNewJob.locationObj.state), \(objNewJob.locationObj.country)"
                    break
                case 6:
                    cell.txtFd.text = objNewJob.gender == 1 ? "Male" : (objNewJob.gender == 2 ? "Female":"Male and Female")
                    break
                case 7:
                    cell.txtFd.text = objNewJob.education
                    break
                case 8:
                    cell.txtFd.text = objNewJob.experienceLevel
                    break
                case 9:
                    cell.txtFd.text = objNewJob.arrPreferredSkills.joined(separator: ",")
                    break
               
                default:
                    break
                    
                }
                
                cell.selectionStyle = .none
            cell.txtFd.isUserInteractionEnabled = false
                return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 11 {
            return UITableView.automaticDimension
        }else {
            return 70
        }
    }
}
