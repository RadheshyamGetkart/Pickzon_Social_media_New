//
//  CreateJobStep1VC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 2/28/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class CreateJobStep1VC: UIViewController, LocationDelegate {
    
    @IBOutlet weak var tblJob:UITableView!
    

    var titleArray = ["Job Title", "Work Place Type", "Industry", "Job Type", "Company Name","Salary", "No. of openings", "Job Location"]
    let iconArray = ["job_account_details_outline","job_location","job_industry","job_Group","office_building","job_money","job_peoples_two","Mail"]
    
    var objNewJob = CreateNewJob()
    var arrJobCategories:Array<Dictionary<String,Any>> = Array()
    var arrjobTitles:Array<String> = Array()
    var selectedJobCategoryID = ""
    var arrJobIndustries:Array<String> = ["Actor","Artist", "Author"]
    var arrjobTypes:Array<String> = ["Private", "Goverment"]
    var arrjobWorkplaces:Array<String> = ["Hybrid", "On-site", "Wfh/remote", "remote"]
    
    var arrSalaryOptions:Array<String> = ["Monthly", "Annualy"]
    var jobCategoryID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tblJob.separatorStyle = .none
        
        tblJob.register(UINib(nibName: "SalaryCell", bundle: nil),
                          forCellReuseIdentifier: "SalaryCell")
        tblJob.register(UINib(nibName: "AddNewLocationCell", bundle: nil),
                          forCellReuseIdentifier: "AddNewLocationCell")
        
        tblJob.register(UINib(nibName: "CreateBusinessTblCell", bundle: nil),
                          forCellReuseIdentifier: "CreateBusinessTblCell")
        
        self.getJobsFormValues()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func getJobsFormValues(){
        
        URLhandler.sharedinstance.makeGetAPICall(url: Constant.sharedinstance.getjobformURL, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1{
                    
                    if let payload = result["payload"] as? NSDictionary{
                        self.arrJobCategories = payload["jobCategories"] as? Array<Dictionary<String,Any>> ?? Array()
                        for obj in self.arrJobCategories {
                            self.arrjobTitles.append(obj["categoryName"] as? String ?? "")
                        }
                        
                        self.arrJobIndustries =  payload["jobIndustries"] as? Array<String> ?? Array()
                        
                        self.arrjobTypes =  payload["jobTypes"] as? Array<String> ?? Array()
                        self.arrjobWorkplaces =  payload["jobWorkplaces"] as? Array<String> ?? Array()
                        
                    }
                } else {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    
    @objc func showSalaryOptions(){
        
        self.view.endEditing(true)
        
        if let cell = tblJob.cellForRow(at: IndexPath(row: 5, section: 0)) as? SalaryCell {
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                arrSalaryOptions
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
                
                if let str = (values as AnyObject?) as? NSArray {
                    
                    self.objNewJob.salaryOptions   = str[0] as? String ?? ""
                    self.tblJob.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .none)
                }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: cell.btnSalaryOption)
            
        }
    }
    
    @objc func addNewLocationForJob(){
//        let destVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
//        destVC.delegate = self
//        destVC.locationObj = objNewJob.locationObj
//        destVC.isCreateNewJob = true
//        self.navigationController?.pushViewController(destVC, animated: true)
    }
    func selectedLocation(locObj:LocationModal){
      
        self.objNewJob.locationObj = locObj
        
        self.tblJob.reloadRows(at: [IndexPath(row: 7, section: 0)], with: .none)
        
    }
    
      
    @objc func showSalaryOnJobPosted(){
        if self.objNewJob.showSalaryOnPost == true {
            self.objNewJob.showSalaryOnPost = false
        }else {
            self.objNewJob.showSalaryOnPost = true
        }
        self.tblJob.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .none)
    }
    
    @IBAction func nextStepButtonAction() {
        var showErrorAlert = false
        var msg  = ""
        if objNewJob.jobTitle.length == 0 {
            showErrorAlert = true
            msg = "Please enter job title"
        }else if objNewJob.workPlaceType.length == 0 {
            showErrorAlert = true
            msg = "Please enter work place type"
            
        }else if objNewJob.industry.length == 0 {
            showErrorAlert = true
            msg = "Please enter industry"
        }else if objNewJob.jobType.length == 0 {
            showErrorAlert = true
            msg = "Please enter job type"
        }else if objNewJob.companyName.length == 0 {
            showErrorAlert = true
            msg = "Please enter company name"
        }else if objNewJob.minSalary.length == 0 {
            showErrorAlert = true
            msg = "Please enter minimum salary"
        }else if objNewJob.maxSalary.length == 0 {
            showErrorAlert = true
            msg = "Please enter maximum salary"
        }else if objNewJob.noOfOpenings == 0 {
            showErrorAlert = true
            msg = "Please enter number of openings"
        }else if objNewJob.locationObj.country.length == 0 {
            showErrorAlert = true
            msg = "Please add location"
        }
        
        if showErrorAlert == true {
            
            let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
               alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
               }))
            self.present(alert, animated: true, completion: nil)
            
        }else {
            let vc: CreateJobStep2VC = StoryBoard.job.instantiateViewController(withIdentifier: "CreateJobStep2VC") as! CreateJobStep2VC
            vc.objNewJob = self.objNewJob
            vc.jobCategoryID = self.selectedJobCategoryID
            self.navigationController?.pushViewController(vc, animated: true)
             
            
        }
        
    }
    
    
}




extension CreateJobStep1VC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SalaryCell") as! SalaryCell
            cell.lblSalaryOption.text = "Salary (\(objNewJob.salaryOptions))"
            
            cell.btnSalaryOption.addTarget(self, action: #selector(self.showSalaryOptions), for: .touchUpInside)
            cell.txtMinSalary.text = "\(objNewJob.minSalary)"
            cell.txtMinSalary.tag = 20
            cell.txtMaxSalary.tag = 21
            cell.txtMinSalary.delegate = self
            cell.txtMaxSalary.delegate = self
            cell.txtMaxSalary.text = "\(objNewJob.maxSalary)"
            cell.btnCurrencyOption.setTitle("\(objNewJob.currancySymbol)", for: .normal)
            cell.btnShowSalaryOnPost.setImage(objNewJob.showSalaryOnPost == true ? PZImages.check : PZImages.uncheck, for: .normal)
            cell.btnShowSalaryOnPost.addTarget(self, action: #selector(self.showSalaryOnJobPosted), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else {
            if objNewJob.locationObj.country == "" && indexPath.row == 7 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewLocationCell") as! AddNewLocationCell
                
                cell.btnAddLocation.addTarget(self, action: #selector(self.addNewLocationForJob), for: .touchUpInside)
                
                cell.selectionStyle = .none
                return cell
            }else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CreateBusinessTblCell") as! CreateBusinessTblCell
                cell.ddImgVw.isHidden = false
                cell.txtFd.iconImage = UIImage(named: iconArray[indexPath.row] as! String)
                cell.txtFd.iconImageView.setImageColor(color: UIColor.lightGray)
                cell.txtFd.tag = indexPath.row
                cell.txtFd.delegate = self
                
                
                
                cell.txtFd.setAttributedPlaceHolder(frstText: titleArray[indexPath.row], color: UIColor.lightGray, secondText: "*", secondColor: UIColor.red)
                
                cell.txtFd.isUserInteractionEnabled = true
                
                switch indexPath.row{
                    
                case 0:
                    cell.txtFd.text = objNewJob.jobTitle
                    cell.ddImgVw.isHidden = true
                    break
                case 1:
                    cell.txtFd.text = objNewJob.workPlaceType
                    break
                case 2:
                    cell.txtFd.text = objNewJob.industry
                    break
                case 3:
                    cell.txtFd.text = objNewJob.jobType
                    break
                case 4:
                    cell.txtFd.text = objNewJob.companyName
                    cell.ddImgVw.isHidden = true
                    break
                    
                case 6:
                    cell.txtFd.text = "\(objNewJob.noOfOpenings)"
                    cell.ddImgVw.isHidden = true
                    break
                case 7:
                    cell.txtFd.text = "\(objNewJob.locationObj.city), \(objNewJob.locationObj.state), \(objNewJob.locationObj.country)"
                    cell.ddImgVw.isHidden = true
                    break
                    
                default:
                    break
                    
                }
                
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 {
            return 114
        }else {
            return 60
        }
    }
}

extension CreateJobStep1VC:UITextFieldDelegate {
    //MARK: - UItextfield Delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 0{
            self.view.endEditing(true)
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                arrjobTitles
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
                
                if let str = (values as AnyObject?) as? NSArray {
                    
                    
                    self.objNewJob.jobTitle   = str[0] as? String ?? ""
                    for obj in self.arrJobCategories {
                        if obj["categoryName"] as? String == self.objNewJob.jobTitle {
                            self.selectedJobCategoryID = obj["_id"] as? String ?? ""
                            break
                        }
                    }
                    self.tblJob.reloadRows(at: [IndexPath(row: textField.tag, section: 0)], with: .none)
                    
                    
                }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
        }else if textField.tag == 1{
            self.view.endEditing(true)
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                arrjobWorkplaces
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
                
                if let str = (values as AnyObject?) as? NSArray {
                    
                    
                    self.objNewJob.workPlaceType   = str[0] as? String ?? ""
                    self.tblJob.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                    
                    
                }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
        }else   if textField.tag == 2{
            self.view.endEditing(true)
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                arrJobIndustries
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
                
                if let str = (values as AnyObject?) as? NSArray {
                    
                    self.objNewJob.industry   = str[0] as? String ?? ""
                    self.tblJob.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
        }else   if textField.tag == 3{
            self.view.endEditing(true)
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                arrjobTypes
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
                
                if let str = (values as AnyObject?) as? NSArray {
                    
                    self.objNewJob.jobType   = str[0] as? String ?? ""
                    self.tblJob.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
                }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
        }else   if textField.tag == 7{
            self.addNewLocationForJob()
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var enteredText = textField.text ?? ""
        enteredText = enteredText.trimmingLeadingAndTrailingSpaces()
       
        switch textField.tag {
            
        case 0:
            objNewJob.jobTitle = enteredText
            self.tblJob.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
           
            break
        case 1:
            objNewJob.workPlaceType = enteredText
            self.tblJob.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
            break
        case 4:
            objNewJob.companyName = enteredText
            self.tblJob.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
            break
        case 6:
            objNewJob.noOfOpenings = Int(enteredText) ?? 0
            self.tblJob.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
            break
            
        case 7:
                
//                let destVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
//                destVC.delegate = self
//                destVC.locationObj = objNewJob.locationObj
//                self.navigationController?.pushViewController(destVC, animated: true)
              
                break
        case 20:
            objNewJob.minSalary = enteredText
            self.tblJob.reloadRows(at: [IndexPath(row: 5 , section: 0)], with: .none)
           
            break
        case 21:
            if Int64(objNewJob.minSalary) ?? 0 > Int64(enteredText) ?? 0 {
                let alert = UIAlertController(title: "", message: "Minimum salary cannot be greater than maximum salary.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }else {
                objNewJob.maxSalary = enteredText
                
            }
            self.tblJob.reloadRows(at: [IndexPath(row: 5 , section: 0)], with: .none)
            break
        
       
        default:
            break
        }
        
    }
    
    
    

 
 
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     return true
 }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {


        /* let previousText:NSString = textField.text! as NSString
         let updatedText = previousText.replacingCharacters(in: range, with: string)
        
        if textField.tag == 0 || textField.tag == 1{
            if string.isEmpty {
                return true
            }
            
            let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|(){}")
               .union(.newlines)
               .union(.illegalCharacters)
               .union(.controlCharacters)

            if textField.text?.rangeOfCharacter(from: invalidCharacters) != nil {
                print ("Illegal characters detected in file name")
                return false
            }

            var alphaNumericRegEx = "^[A-Za-z\\s]*$"
           
            let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
            return predicate.evaluate(with: string)
        }

        if textField.tag == 6 && updatedText.count>15{
            return false
        }*/
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let indexPath = IndexPath(row: 10, section: 0)

        let cell: DescriptionTblCell = self.tblJob.cellForRow(at: indexPath) as! DescriptionTblCell
        cell.titleLbl.isHidden = (newText.length == 0) ? true : false
        
        if newText.length > 130{
           // return false
        }
        
        
       
        return true
    }
    
       
    /* func textViewDidEndEditing(_ textView: UITextView) {
               pageObj.aboutPage = textView.text
           
       }
       
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        tblView.beginUpdates()
            
            descHeight = (height > 40) ? height : 40
            pageObj.aboutPage = textView.text.trimmingCharacters(in: .whitespaces)
      
        tblView.endUpdates()
    }*/
}


struct CreateNewJob {
    var jobTitle = ""
    var workPlaceType = ""
    var industry = ""
    var jobType = ""
    var companyName = ""
    var salaryOptions = "Annually"
    var currancySymbol = ""
    var minSalary = ""
    var maxSalary = ""
    var showSalaryOnPost = true
    var noOfOpenings = 1
    var locationObj:LocationModal = LocationModal(locationDict:[:])
    
    var gender = 3
    var education = ""
    var experienceLevel = ""
    var arrPreferredSkills = Array<String>()
    var jobDescription = ""
}

