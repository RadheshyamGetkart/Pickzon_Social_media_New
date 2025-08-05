//
//  AccountInfoVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/20/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import IQKeyboardManager
import Photos

class AccountInfoVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var lblNavTitle: UILabel!

    var callBack: ((_ objWithdraw: WithdrawCoinModel,_ img:UIImage?)-> Void)?
    var titleArray = ["Bank Name","Account No.","Confirm Account No.","IFSC","Account Holder Name"]

    var isChecked = true
    var accountInfo = WithdrawCoinModel(respDict: [:])
    var isEdit = false
    
    
    @IBOutlet weak var btnChooseImg: UIButton!
    var picker:UIImagePickerController?
    var uploadedImage:UIImage?
    
    //MARK: Controller life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavbar.constant = self.getNavBarHt
        btnNext.layer.cornerRadius = 5.0
        btnNext.clipsToBounds = true
        tblView.register(UINib(nibName: "AccountInfoTblCell", bundle: nil), forCellReuseIdentifier: "AccountInfoTblCell")
        
        if isEdit == true{
            btnNext.setTitle("Update", for: .normal)
            lblNavTitle.text = "Update account information"
        }
        btnChooseImg.layer.cornerRadius = 5.0
        btnChooseImg.layer.borderWidth = 1.0
        btnChooseImg.layer.borderColor = UIColor.lightGray.cgColor
        btnChooseImg.clipsToBounds = true
        
        if accountInfo.accReferenceImage.count > 0 {
            self.btnChooseImg.setTitle("File Attached", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    //MARK: Common Button Actions
    @IBAction func backButonAction(_ sender:UIButton){
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chooseImageButonAction(_ sender:UIButton){
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        if accountInfo.accReferenceImage.count > 0{
            
            let action1: UIAlertAction = UIAlertAction(title: "Upload", style: .default) { action -> Void in
                self.openGallery()
            }
            
            let action2: UIAlertAction = UIAlertAction(title: "Preview", style: .default)
            { action -> Void in
                let zoomCtrl = VKImageZoom()
                zoomCtrl.image_url = URL(string: self.accountInfo.accReferenceImage)
                //zoomCtrl.image = sender.currentImage
                zoomCtrl.modalPresentationStyle = .fullScreen
                self.present(zoomCtrl, animated: true, completion: nil)
            }
            actionSheetController.addAction(action1)
            actionSheetController.addAction(action2)
            
        }else{
            let action1: UIAlertAction = UIAlertAction(title: "Upload", style: .default) { action -> Void in
                self.openGallery()
            }
            actionSheetController.addAction(action1)
        }
        let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .destructive) { action -> Void in
        }
        actionSheetController.addAction(cancel)
        
        actionSheetController.view.tintColor = UIColor.systemBlue
        self.presentView(actionSheetController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if accountInfo.bankName.count < 1 {
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please enter bank name.")

        }else if accountInfo.accountNo.count < 5 {
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please enter account no.")


        }else if accountInfo.accountNo != accountInfo.confirmAccountNo {
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Confirm account no.must be same as account number.")
        }else if !accountInfo.ifscCode.isIfscCodeValid{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please enter valid IFSC code.")

        }else if accountInfo.acccountHolderName.count < 2 {
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please enter account holder name.")

        }else if accountInfo.accReferenceImage.count == 0  && uploadedImage == nil  {
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please upload bank proof.")

        }else{
            accountInfo.isBankSaved = isChecked

            if isEdit == true{
                callBack?(accountInfo, uploadedImage)
                self.navigationController?.popViewController(animated: true)
            }else{
                let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WithdrawVC") as! WithdrawVC
                vc.accountInfo = accountInfo
                vc.imageBank = uploadedImage
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func btnCheckBoxAction(_ sender: UIButton) {
        self.view.endEditing(true)
        isChecked.toggle()
        if isChecked{
            btnCheckBox.setImage(UIImage(named: "ic_round-check-box"), for: .normal)
        }else{
            btnCheckBox.setImage(UIImage(named: "ic_round-uncheck-box"), for: .normal)

        }
    }
}

extension AccountInfoVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
     
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return  titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tblView.dequeueReusableCell(withIdentifier: "AccountInfoTblCell") as! AccountInfoTblCell
       
        cell.lblTitle.text = titleArray[indexPath.row]
        cell.lblSubTitle.text = ""
        cell.txtFdName.tag = indexPath.row
        cell.txtFdName.delegate = self
        
        switch indexPath.row{
            
        case 0:
            cell.txtFdName.text = accountInfo.bankName
            cell.txtFdName.autocapitalizationType = .words
            break
        case 1:
            cell.txtFdName.text = accountInfo.accountNo
            break
        case 2:
            cell.txtFdName.text = accountInfo.confirmAccountNo
            break
        case 3:
            cell.txtFdName.text = accountInfo.ifscCode
            cell.txtFdName.autocapitalizationType = .allCharacters
            break
        case 4:
            cell.lblSubTitle.text = "Name as per your bank account"
            cell.txtFdName.text = accountInfo.acccountHolderName
            cell.txtFdName.autocapitalizationType = .words

            break
        default:
            break
        }
        return cell
    }
    
    //MARK: UITextfield Delegate method
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {


        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
           
        if string.isEmpty {
            return true
        }
        
        if updatedText.length > 25 && (textField.tag == 1 || textField.tag == 2){
            return false
        }
        
        if textField.tag == 3 && updatedText.length > 11{
            return false
        }
        if (textField.tag == 0 ||  textField.tag == 4) && updatedText.length > 30{
            return false
        }
       
        if textField.tag == 3{
            return updatedText.isAlphanumeric
        }
        
        if (textField.tag == 0 || textField.tag == 4) {
            if string.isEmpty {
                return true
            }
            let allowedCharacters = CharacterSet.letters.union(CharacterSet(charactersIn: " "))
            guard updatedText.rangeOfCharacter(from: allowedCharacters.inverted) == nil else { return false }

            
            
        }
                
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      
        switch textField.tag{
        case 0:
            textField.keyboardType = .alphabet
            break
        case 1:
            textField.keyboardType = .numberPad
            break
        case 2:
            textField.keyboardType = .numberPad
            break
            
        case 3:
            textField.keyboardType = .alphabet
            break
        case 4:
            textField.keyboardType = .alphabet
            break
        default:
            break
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch textField.tag{
        case 0:
            accountInfo.bankName = textField.text ?? ""
            break
        case 1:
            accountInfo.accountNo = textField.text ?? ""
            break
        case 2:
            accountInfo.confirmAccountNo = textField.text ?? ""
            break
            
        case 3:
            accountInfo.ifscCode = textField.text ?? ""
            break
        case 4:
            accountInfo.acccountHolderName = textField.text ?? ""
            break
        default:
            break
        }
        self.tblView.reloadRows(at: [IndexPath(row:textField.tag,section:0)], with: .none)
    }
}


extension AccountInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func openGallery(){
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                DispatchQueue.main.async {
                    self.picker = UIImagePickerController()
                    self.picker?.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.picker?.delegate = self
                    self.present(self.picker!, animated: true, completion: nil)
                }
                
            }
        }
    }
        
        
    
    
    //MARK: -- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
       // let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
        
        if let image = info[.originalImage] as? UIImage {
            uploadedImage = image
            self.btnChooseImg.setTitle("File Attached", for: .normal)
       
                
        }else {
            uploadedImage = nil
           
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismissView(animated: true, completion: nil)
    }
    
}
