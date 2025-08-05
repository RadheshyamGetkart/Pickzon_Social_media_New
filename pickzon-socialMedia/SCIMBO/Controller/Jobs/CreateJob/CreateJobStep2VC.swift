//
//  CreateJobStep2VC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 2/28/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class CreateJobStep2VC: UIViewController {
    @IBOutlet weak var tblJob:UITableView!
    

    var titleArray = ["Gender", "Education", "Experience Level", "Preferred Skills", "Job description"]
    let iconArray = ["pageName","Tagline","Category","Web","Companysize"]
    
    var objNewJob = CreateNewJob()
    var arrEducation: Array<String> = ["10th","12th","Graduate"]
    var arrExperienceLevel: Array<String> = ["Fresher", "< One Year", "Two years"]
    var arrSkills: Array<String> = []
    
    var jobCategoryID = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        tblJob.separatorStyle = .none
        
        
        tblJob.register(UINib(nibName: "GenderCell", bundle: nil),
                          forCellReuseIdentifier: "GenderCell")
        
       
        tblJob.register(UINib(nibName: "CreateBusinessTblCell", bundle: nil),
                          forCellReuseIdentifier: "CreateBusinessTblCell")
        tblJob.register(UINib(nibName: "DescriptionTblCell", bundle: nil),
                          forCellReuseIdentifier: "DescriptionTblCell")
        
        tblJob.register(UINib(nibName: "TagViewTblCell", bundle: nil),
                          forCellReuseIdentifier: "TagViewTblCell")
        tblJob.register(UINib(nibName: "PreferredSkillsCell", bundle: nil),
                          forCellReuseIdentifier: "PreferredSkillsCell")
        
        self.getJobsSkills()
    }
    
    func getJobsSkills(){
        let url = Constant.sharedinstance.getJobSkillsURL + "/\(jobCategoryID)"
        
        URLhandler.sharedinstance.makeGetAPICall(url: url, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1{
                    
                    if let payload = result["payload"] as? Array<String> {
                        
                    self.arrSkills = payload
                        
                    }
                    self.tblJob.reloadData()
                } else {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
            self.tblJob.reloadData()
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
    }
    
    @objc func genderButtonAction(sender:UIButton) {
        
        switch sender.tag {
        case 1:
            objNewJob.gender = 1
            break
        case 2:
            objNewJob.gender = 2
            break
        case 3:
            objNewJob.gender = 3
            break
        default:
            break
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        tblJob.reloadRows(at: [indexPath], with: .none)
    }
    
    @IBAction func nextStepButtonAction() {
        var showErrorAlert = false
        var msg  = ""
        if objNewJob.education.length == 0 {
            showErrorAlert = true
            msg = "Please enter education"
        }else if objNewJob.experienceLevel.length == 0 {
            showErrorAlert = true
            msg = "Please enter experience level"
        }else if objNewJob.arrPreferredSkills.count == 0 {
            showErrorAlert = true
            msg = "Please enter preferred skills"
        }else if objNewJob.jobDescription.length == 0 {
            showErrorAlert = true
            msg = "Please enter job description"
        }
        
        if showErrorAlert == true {
            let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
               alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
               }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let vc: CreateJobStep3VC = StoryBoard.job.instantiateViewController(withIdentifier: "CreateJobStep3VC") as! CreateJobStep3VC
        vc.objNewJob = self.objNewJob
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}

extension CreateJobStep2VC:PrefereSkillDelegate {
    func skillSelected(skill:String) {
        if !objNewJob.arrPreferredSkills .contains(where: { $0 == skill }) {
            objNewJob.arrPreferredSkills.append(skill)
        }else {
            let index = objNewJob.arrPreferredSkills.firstIndex(where: { $0 == skill }) ?? -1
            if index != -1 {
                objNewJob.arrPreferredSkills.remove(at: index)
            }
        }
        tblJob.reloadData()
    }
}

extension CreateJobStep2VC:TagPeopleDelegate, TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {

        print("tagPressed")

       /* if let index =  self.groupObj.tagUserArray.firstIndex(of: title){
            sender.removeTagView(tagView)

            self.groupObj.tagUserArray.remove(at: index)
            self.arrTagPeople.remove(at: index)
            self.tagIdArray.remove(at: index)
            self.tblView.reloadData()

        }*/
    }

    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
       
        print("tagRemoveButtonPressed")
       /* if let index =  self.groupObj.tagUserArray.firstIndex(of: title){
            sender.removeTagView(tagView)
            self.groupObj.tagUserArray.remove(at: index)
            self.arrTagPeople.remove(at: index)
            self.tagIdArray.remove(at: index)
            self.tblView.reloadData()
            
        }*/
    }
    @objc func addPreferredSkills(_ sender:UIButton){
        
       /* let viewController:TagPeopleViewController = StoryBoard.main.instantiateViewController(withIdentifier: "TagPeopleViewController") as! TagPeopleViewController
        viewController.tagPeopleDelegate = self
        viewController.arrSelectedUser =  self.arrSkills
        self.navigationController?.pushView(viewController, animated: true)
        */
         
    }
    
 func tagPeopleDoneAction(arrTagPeople : Array<Dictionary<String, Any>>) {
     print(arrTagPeople)
     
     /*for objDict in arrTagPeople {
         print(objDict)
         if !self.groupObj.tagUserArray.contains((objDict["pickzonId"] as? String ?? "")){
             self.groupObj.tagUserArray.append((objDict["pickzonId"] as? String ?? ""))
             self.tagIdArray.append((objDict["userId"] as? String ?? ""))
         }
         self.arrTagPeople = arrTagPeople
     }
     self.tblView.reloadData()
      */
 }
}
extension CreateJobStep2VC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenderCell") as! GenderCell
            
            cell.btnMale.addTarget(self, action: #selector(genderButtonAction(sender: )), for: .touchUpInside)
            cell.btnFeMale.addTarget(self, action: #selector(genderButtonAction(sender: )), for: .touchUpInside)
            cell.btnBoth.addTarget(self, action: #selector(genderButtonAction(sender: )), for: .touchUpInside)
            
            cell.btnMale.setImage(UIImage(named:"unselectedRadio"), for: .normal)
            cell.btnFeMale.setImage(UIImage(named:"unselectedRadio"), for: .normal)
            cell.btnBoth.setImage(UIImage(named:"unselectedRadio"), for: .normal)
            
            if objNewJob.gender == 1 {
                cell.btnMale.setImage(UIImage(named: "selectedRadio"), for: .normal)
            }else if objNewJob.gender == 2 {
                cell.btnFeMale.setImage(UIImage(named: "selectedRadio"), for: .normal)
            }else if objNewJob.gender == 3 {
                cell.btnBoth.setImage(UIImage(named: "selectedRadio"), for: .normal)
            }
            return cell
        }else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PreferredSkillsCell") as! PreferredSkillsCell
            cell.arrSkillsSuggested = self.arrSkills
            cell.arrSkillsSelected = objNewJob.arrPreferredSkills
            cell.clnSkillsSuggestion.reloadData()
            cell.clnHeight.constant = cell.clnSkillsSuggestion.collectionViewLayout.collectionViewContentSize.height;
            cell.skilDelegate = self
            cell.selectionStyle = .none
                return cell
        }else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTblCell") as! DescriptionTblCell
           // cell.txtVwDesc.setAttributedPlaceHolder(frstText: titleArray[indexPath.row], color: UIColor.lightGray, size1: 15.0, secondText: "*", secondColor: UIColor.red, size2: 15.0)
            cell.titleLbl.text = titleArray[safe: indexPath.row]?.uppercased()
            cell.txtVwDesc.isUserInteractionEnabled = true
            cell.txtVwDesc.text = objNewJob.jobDescription
            cell.titleLbl.isHidden = (objNewJob.jobDescription.length == 0) ? true : false
           // cell.iconImgVw.image = UIImage(named: iconArray[indexPath.row] as! String)
            cell.txtVwDesc.delegate = self
            cell.txtVwDesc.tag = indexPath.row
            return cell
        }else {
            
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CreateBusinessTblCell") as! CreateBusinessTblCell
                cell.ddImgVw.isHidden = false
                cell.txtFd.iconImage = UIImage(named: iconArray[indexPath.row] )
                cell.txtFd.iconImageView.setImageColor(color: UIColor.lightGray)
                cell.txtFd.tag = indexPath.row
                cell.txtFd.delegate = self
                
                
                
                cell.txtFd.setAttributedPlaceHolder(frstText: titleArray[indexPath.row], color: UIColor.lightGray, secondText: "*", secondColor: UIColor.red)
                
                cell.txtFd.isUserInteractionEnabled = true
                
                switch indexPath.row{
                    
               
                case 1:
                    cell.txtFd.text = objNewJob.education
                    break
                case 2:
                    cell.txtFd.text = objNewJob.experienceLevel
                    break
               
                default:
                    break
                    
                }
                
                cell.selectionStyle = .none
                return cell
            
        }
    }
    
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 3{
            return UITableView.automaticDimension
        }else {
            return 60
        }
    }*/
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 3 {
            return UITableView.automaticDimension
        }else {
            return 60
        }
    }
}

extension CreateJobStep2VC:UITextFieldDelegate, UITextViewDelegate {
    //MARK: - UItextfield Delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1{
            self.view.endEditing(true)
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [arrEducation
                
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
                
                if let str = (values as AnyObject?) as? NSArray {
                    
                    
                    self.objNewJob.education   = str[0] as? String ?? ""
                    self.tblJob.reloadRows(at: [IndexPath(row: textField.tag, section: 0)], with: .none)
                    
                    
                }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
        }else if textField.tag == 2{
            self.view.endEditing(true)
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [arrExperienceLevel
                
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
                
                if let str = (values as AnyObject?) as? NSArray {
                    
                    
                    self.objNewJob.experienceLevel   = str[0] as? String ?? ""
                    self.tblJob.reloadRows(at: [IndexPath(row: textField.tag, section: 0)], with: .none)
                    
                    
                }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var enteredText = textField.text ?? ""
        enteredText = enteredText.trimmingLeadingAndTrailingSpaces()
       
        switch textField.tag {
        case 1:
            objNewJob.education = enteredText
            self.tblJob.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
            break
        case 2:
            objNewJob.experienceLevel = enteredText
            self.tblJob.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
            break
        case 4:
            objNewJob.jobDescription = enteredText
            self.tblJob.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
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
        let indexPath = IndexPath(row: textView.tag, section: 0)

        let cell: DescriptionTblCell = self.tblJob.cellForRow(at: indexPath) as! DescriptionTblCell
        cell.titleLbl.isHidden = (newText.length == 0) ? true : false
        objNewJob.jobDescription = newText
        if newText.length > 130{
            return false
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




