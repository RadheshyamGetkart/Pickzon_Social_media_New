//
//  BaseVC.swift
//  Coravida
//
//  Created by Sachtech on 08/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import DropDown
import CoreLocation

//Thi code is 
class SwiftBaseViewController: UIViewController {
    
    //MARK: Userdefined Variables
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        hideNavBar()
        
    }
    
    func hideNavBar(){
        navigationController?.navigationBar.isHidden = true
    }

    func showNavBar(){
        navigationController?.navigationBar.isHidden = false
    }

    func setTransparentNavBar(){
        navigationController?.transparentNavBar()
    }

    func toast(_ message:String){
        self.view.makeToast(message)
    }

    func randomString() -> String {
      let length = 24
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func getJoinedString(arr: [String])-> String{
        if arr.count == 1{
            return arr[0]
        }else if arr.count == 2{
            return arr.joined(separator: "and")
        }else if arr.count > 2{
            let lastElement = arr.last ?? ""
            var arrStr = arr
            arrStr.removeLast()
            let str = arrStr.joined(separator: ", ")
            let arr = [str, lastElement]
            return arr.joined(separator: " and ")
        }else{
            return ""
        }
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "PickZon", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func  getAttributedString(string1: String,string2: String) -> NSMutableAttributedString{
        
        let attrs1 = [NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 15), NSAttributedString.Key.foregroundColor: UIColor.black]
        let attrs2 = [NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 15), NSAttributedString.Key.foregroundColor: UIColor(named: "darkAppText")]
        
        let str1 = NSAttributedString(string: string1, attributes: attrs1 as [NSAttributedString.Key : Any])
        
        let str2 = NSAttributedString(string: " \(string2)", attributes: attrs2 as [NSAttributedString.Key : Any])
        
        let getText = NSMutableAttributedString()
        
        getText.append(str1)
        getText.append(str2)
        return getText
        
    }
    
    func getLocationName(_ loc: [Double]) -> String {
        let geocoder = CLGeocoder()
        var placeName: String = ""
        if loc.count == 2{
            geocoder.reverseGeocodeLocation(CLLocation(latitude: loc[0], longitude: loc[1])) { (places, error) in
                if error == nil{
                    if let place = places?.first{
                        placeName = "\(place.name ?? ""), \(place.locality ?? "")"
                    }
                }
            }}
        return placeName
    }
    
    func dateFormatting(dateStr: String, format: String) -> String{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "GMT-07")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let yourDate = formatter.date(from: dateStr)
        formatter.dateFormat = format
        let getDate = formatter.string(from: yourDate ?? Date())
        return getDate
    }

    //    
//    func fetchCountryCurrency(_ countryname: String) -> (String, String){
//        let filePath = Bundle.main.path(forResource: "currency", ofType: "plist")
//        let countries = NSMutableArray(contentsOfFile: filePath ?? "") ?? []
//        var countryArr: [NSDictionary] = []
//        for country in countries{
//            countryArr.append(country as? NSDictionary ?? [:])
//        }
//        if let currencyPicked = countryArr.filter ({ (country) -> Bool in
//            let countryCurrency = "\(country.object(forKey: "name") ?? "")"
//            return countryCurrency.localizedCaseInsensitiveCompare(countryname) == .orderedSame
//        }).first{
//            return ("\(currencyPicked.object(forKey: "currencyCode") ?? "")", "\(currencyPicked.object(forKey: "currencytSymbol") ?? "")")
//        }else{
//            return ("INR","₹")
//        }
//    }
    
    func fetchCountryCountryCodeIOS2(_ countryCodeISO3: String) -> (String){
        let filePath = Bundle.main.path(forResource: "countryiso3", ofType: "plist")
        let countries = NSMutableArray(contentsOfFile: filePath ?? "") ?? []
        var countryArr: [NSDictionary] = []
        for country in countries{
            countryArr.append(country as? NSDictionary ?? [:])
        }
        if let currencyPicked = countryArr.filter ({  (country) -> Bool in
            let countryCurrency = "\(country.object(forKey: "iso3") ?? "")"
            return countryCurrency.localizedCaseInsensitiveCompare(countryCodeISO3) == .orderedSame
        }).first{
            return ("\(currencyPicked.object(forKey: "iso2") ?? "")")
        }else{
            return ("IN")
        }
    }
    
    
    
    //MARK: - CAMERA ACCESS CHECK
            func cameraAllowsAccessToApplicationCheck()
            {
                let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
                switch authorizationStatus {
                case .notDetermined:
                    // permission dialog not yet presented, request authorization
                    AVCaptureDevice.requestAccess(for: AVMediaType.video,
                        completionHandler: { (granted:Bool) -> Void in
                            if granted {
                                print("access granted", terminator: "")
                            }
                            else {
                                print("access denied", terminator: "")
                            }
                    })
                case .authorized:
                    print("Access authorized", terminator: "")
                    self.presentPickerSelector()
                case .denied, .restricted:
                    alertToEncourageCameraAccessWhenApplicationStarts()
                
                    break
                default:
                    print("DO NOTHING", terminator: "")
                }
            }


     func alertToEncourageCameraAccessWhenApplicationStarts()
        {
            AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Please enable camera", buttonTitles: ["Cancel","Okay"], onController: self) { title, index in
                
                if index == 0{
                    return
                }else{
                    let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
                    if let url = settingsUrl {
                        DispatchQueue.main.async {
                            UIApplication.shared.openURL(url as URL)
                        }

                    }
                }
            }
        }
}

extension SwiftBaseViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func presentPickerSelector(){
           
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.allowsEditing = true
        
        picker.allowsEditing = false
        
        let alert = UIAlertController(title: "Select image from", message: nil, preferredStyle:    UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (handler) in
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            self.present(picker, animated: true, completion: nil)
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (handler) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (handler) in
            
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
       }
}

