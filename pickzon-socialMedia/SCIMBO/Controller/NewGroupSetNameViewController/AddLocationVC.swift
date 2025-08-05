//
//  AddLocationVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 1/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import IQKeyboardManager
import ActionSheetPicker_3_0
import MapKit


protocol LocationDelegate: AnyObject{
    
    func selectedLocation(locObj:LocationModal)
}

class AddLocationVC: UIViewController {
    
    var delegate:LocationDelegate?
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrnt_HtNavBar:NSLayoutConstraint!

    var titleArray = ["Country","Street Location","Apt,Suit,etc","City","State/Province","Zip/Postal Code"]
    
    var locationObj = LocationModal(locationDict: [:])
    var isCreateNewJob = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrnt_HtNavBar.constant = self.getNavBarHt
        self.tblView.register(UINib(nibName: "LocationTblCell", bundle: nil), forCellReuseIdentifier: "LocationTblCell")

        if isCreateNewJob == true {
            titleArray = ["Country", "City", "State/Province"]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    //MARK: UIButton Action Methods
    
    @IBAction func backBtnAction(_ sender :UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitBtnAction(_ sender :UIButton){
        self.view.endEditing(true)
        if isCreateNewJob == true {
            if locationObj.country.trimmingLeadingAndTrailingSpaces().isEmpty{
                Themes.sharedInstance.ShowNotification("Please enter country.", false)
                
            }else if locationObj.city.trimmingLeadingAndTrailingSpaces().isEmpty{
                Themes.sharedInstance.ShowNotification("Please enter city.", false)
                
            }else if locationObj.state.trimmingLeadingAndTrailingSpaces().isEmpty{
                Themes.sharedInstance.ShowNotification("Please enter state/province.", false)
            }else {
                locationObj.locationName = "\(locationObj.city) \(locationObj.state) \(locationObj.country)".trimmingLeadingAndTrailingSpaces()
                delegate?.selectedLocation(locObj: locationObj)
                self.navigationController?.popViewController(animated: true)
            }
            
        }else {
            if locationObj.country.trimmingLeadingAndTrailingSpaces().isEmpty{
                Themes.sharedInstance.ShowNotification("Please enter country.", false)
                
            }else if locationObj.city.trimmingLeadingAndTrailingSpaces().isEmpty{
                Themes.sharedInstance.ShowNotification("Please enter city.", false)
                
            }else if locationObj.state.trimmingLeadingAndTrailingSpaces().isEmpty{
                Themes.sharedInstance.ShowNotification("Please enter state/province.", false)
                
            }else if locationObj.postalCode.trimmingLeadingAndTrailingSpaces().isEmpty{
                Themes.sharedInstance.ShowNotification("Please enter zip/postal code.", false)
                
            }else if locationObj.postalCode.trimmingLeadingAndTrailingSpaces().length > 10 || locationObj.postalCode.trimmingLeadingAndTrailingSpaces().length < 3{
                Themes.sharedInstance.ShowNotification("Please enter valid zip/postal code.", false)
            }else{
                locationObj.locationName = "\(locationObj.apartment) \(locationObj.streetAddress) \(locationObj.city) \(locationObj.state) \(locationObj.country) \(locationObj.postalCode)".trimmingLeadingAndTrailingSpaces()
                delegate?.selectedLocation(locObj: locationObj)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}


extension AddLocationVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTblCell") as! LocationTblCell
        //cell.txtFdName.iconImage = UIImage(named: iconArray[indexPath.row])
       // cell.txtFdName.iconImageView.setImageColor(color: UIColor.lightGray)
        cell.txtFdName.tag = indexPath.row
       // cell.txtFdName.delegate = self
        cell.txtFdName.placeholder = titleArray[indexPath.row]
        cell.txtFdName.iconTypeValue = 0
        cell.txtFdName.iconWidth = 0
        

        if isCreateNewJob == true {
            cell.txtFdName.setAttributedPlaceHolder(frstText: titleArray[indexPath.row], color: UIColor.lightGray, secondText: "*", secondColor: UIColor.red)
            switch indexPath.row{
            case 0:
                cell.txtFdName.text = locationObj.country
                break
            case 1:
                cell.txtFdName.text = locationObj.city
                break
            case 2:
                cell.txtFdName.text = locationObj.state
                break
            
                
                
            default:
                break
                
            }
        } else {
            if indexPath.row == 1 || indexPath.row == 2 {
                cell.txtFdName.setAttributedPlaceHolder(frstText: titleArray[indexPath.row] , color: UIColor.lightGray, secondText: "", secondColor: UIColor.red)
            }else{
                cell.txtFdName.setAttributedPlaceHolder(frstText: titleArray[indexPath.row], color: UIColor.lightGray, secondText: "*", secondColor: UIColor.red)
            }
            switch indexPath.row{
                
            case 0:
                cell.txtFdName.text = locationObj.country
                break
            case 1:
                cell.txtFdName.text = locationObj.streetAddress
                break
            case 2:
                cell.txtFdName.text = locationObj.apartment
                break
            case 3:
                cell.txtFdName.text = locationObj.city
                break
            case 4:
                cell.txtFdName.text = locationObj.state
                break
            case 5:
                cell.txtFdName.text = locationObj.postalCode
                break
                
                
            default:
                break
                
            }
        }
        return cell
    }
}

//extension AddLocationVC:UITextFieldDelegate,CountryDelegate {
//    
//       
//        func searchedCountry(searchedObj:CountryModal){
//            locationObj.country  = searchedObj.name
//            locationObj.lat =  CGFloat((searchedObj.latitude as NSString).floatValue)
//            locationObj.long =  CGFloat((searchedObj.longitude as NSString).floatValue)
//            self.tblView.reloadData()
//   }
//    //MARK: - SearchLocationResultDelegate
//    func LocationSelected(searchRegion: MKCoordinateRegion, locationString:String) {
//        LocationHelper.shared.getReverseGeoCodedLocationUpdated(location: CLLocation.init(latitude: searchRegion.center.latitude, longitude: searchRegion.center.longitude)) { (location, placemark, error) in
//
//            self.locationObj.lat = searchRegion.center.latitude
//            self.locationObj.long = searchRegion.center.longitude
//            self.locationObj.locationName = locationString
//            self.locationObj.postalCode = placemark?.postalCode ?? ""
//            self.locationObj.state = placemark?.administrativeArea ?? ""
//            self.locationObj.city = placemark?.locality ?? ""
//            self.locationObj.streetAddress = placemark?.subLocality ?? ""
//            self.locationObj.country =  placemark?.country ?? ""
//           // self.locationObj.fullAddress =  placemark?.addressDictionary.form ?? ""
//            DispatchQueue.main.async {
//                self.tblView.reloadData()
//            }
//        }
//    }
//    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField.tag == 0{
//            
////            let destVc = StoryBoard.feeds.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
////            destVc.delegate = self
////            self.navigationController?.pushViewController(destVc, animated: true)
//                        
//            return false
//        }
//        return true
//    }
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//       
//      /*  if textField.tag == 0 {
//            let vc = UIStoryboard(name: "LetGo", bundle: nil).instantiateViewController(withIdentifier: "SearchResultTableViewController") as! SearchResultTableViewController
//            vc.delegate = self
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
//            self.navigationController?.pushViewController(viewController: vc, completion: {
//                
//            })
//        }*/
//        if textField.tag == 5{
//            textField.keyboardType = .numberPad
//        }else{
//            textField.keyboardType = .default
//        }
//    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        
//        var enteredText = textField.text ?? ""
//        enteredText = enteredText.trimmingLeadingAndTrailingSpaces()
//        if isCreateNewJob == true {
//            switch textField.tag {
//            case 0:
//                locationObj.country = enteredText
//                self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                break
//            case 1:
//                locationObj.city = enteredText
//                self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                break
//            case 2:
//                locationObj.state = enteredText
//                self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                break
//            default:
//                break
//            }
//        }else {
//            switch textField.tag {
//            case 0:
//                locationObj.country = enteredText
//                self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                break
//            case 1:
//                locationObj.streetAddress = enteredText
//                self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                break
//                
//            case 2:
//                locationObj.apartment = enteredText
//                self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                break
//            case 3:
//                locationObj.city = enteredText
//                self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                break
//            case 4:
//                locationObj.state = enteredText
//                self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                break
//            case 5:
//                locationObj.postalCode = enteredText
//                self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                break
//                //        case 6:
//                //            locationObj.locationType = enteredText
//                //            self.tblView.reloadRows(at: [IndexPath(row: textField.tag , section: 0)], with: .none)
//                //            break
//                
//            default:
//                break
//            }
//        }
//    }
//}
