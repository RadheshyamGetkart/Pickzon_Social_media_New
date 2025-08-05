//
//  FeelingActivityTabViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 7/1/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit

protocol FeelingActivityDelegate: AnyObject {
    
    func feeLingActivitySelected(feelingActivity : Dictionary<String, Any>, isFeeling:Bool)
}


class FeelingActivityTabViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!

    @IBOutlet weak var btnFeeling:UIButton!
    @IBOutlet weak var viewFeelingSub:UIView!
    
    @IBOutlet weak var btnActivity:UIButton!
    @IBOutlet weak var viewActivitySub:UIView!
    
    @IBOutlet weak var cvFeelingActivity:UICollectionView!
    @IBOutlet weak var searchBar:UISearchBar!
    var isFeeling = true
    var arrFeelings = Array<Dictionary<String, Any>>()
    var arrActivities = Array<Dictionary<String, Any>>()
    var arrSearched = Array<Dictionary<String, Any>>()
    
    var feelingActivityDelegate:FeelingActivityDelegate!
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        cvFeelingActivity.register(UINib(nibName: "FeelingActivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeelingActivityCollectionViewCell")
        cvFeelingActivity.layoutSubviews()
        
        self.feelingBtnAction()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        
    }
    
    @IBAction func backBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func feelingBtnAction() {
        isFeeling = true
        btnFeeling.setTitleColor(UIColor(red: 30.0/255.0, green: 110.0/255.0, blue: 222.0/255.0, alpha: 1.0), for: .normal)
        viewFeelingSub.backgroundColor = UIColor(red: 30.0/255.0, green: 110.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        
        btnActivity.setTitleColor(UIColor.lightGray, for: .normal)
        viewActivitySub.backgroundColor = UIColor.white
        if arrFeelings.count == 0 {
            self.getFeelingsListAPI()
        }else {
            cvFeelingActivity.reloadData()
        }
        
    }
    @IBAction func activityBtnAction() {
        isFeeling = false
        btnFeeling.setTitleColor(UIColor.lightGray, for: .normal)
        viewFeelingSub.backgroundColor = UIColor.white
        
        btnActivity.setTitleColor(UIColor(red: 30.0/255.0, green: 110.0/255.0, blue: 222.0/255.0, alpha: 1.0), for: .normal)
        viewActivitySub.backgroundColor = UIColor(red: 30.0/255.0, green: 110.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        if arrActivities.count == 0{
            self.getActivitiesListAPI()
        }else {
            cvFeelingActivity.reloadData()
        }
    }
    
    //MARK:- API Implementation
    func getFeelingsListAPI() {
        
            Themes.sharedInstance.activityView(View: self.view)
            let url = Constant.sharedinstance.getFeelingsURL
            
            let params = NSMutableDictionary()
            
            
            URLhandler.sharedinstance.makeGetAPICall(url:url as String, param: params, completionHandler: {(responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    
                }
                else{
                    
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int16 ?? 0
                    let message = result["message"] as? String ?? ""
                    if status == 1{
                        self.arrFeelings = result["payload"] as? Array<Dictionary<String,Any>> ?? Array<Dictionary<String, Any>>()
                        DispatchQueue.main.async {
                            self.cvFeelingActivity.reloadData()
                        }
                        
                    }
                    else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
       
    }
    
    func getActivitiesListAPI() {
        
            Themes.sharedInstance.activityView(View: self.view)
            let url = Constant.sharedinstance.getActivitiesURL
            
            let params = NSMutableDictionary()
            
            
            URLhandler.sharedinstance.makeGetAPICall(url:url as String, param: params, completionHandler: {(responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    
                }
                else{
                    
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int16 ?? 0
                    let message = result["message"] as? String ?? ""
                    if status == 1 {
                        
                        self.arrActivities = result["payload"] as? Array<Dictionary<String,Any>> ?? Array<Dictionary<String, Any>>()
                        DispatchQueue.main.async {
                            self.cvFeelingActivity.reloadData()
                        }
                    }
                    else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
       
    }
    

   
    
    //MARK:- UICollectionview delegate and datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBar.text!.length > 0 {
            return arrSearched.count
        }else  if isFeeling == true {
        return arrFeelings.count
        }else {
            return arrActivities.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeelingActivityCollectionViewCell", for: indexPath) as! FeelingActivityCollectionViewCell
        cell.layoutIfNeeded()
        
        if searchBar.text!.length > 0 {
            let objDict = arrSearched[indexPath.row]
            cell.lblImage.text = objDict["image"] as? String ?? ""
            cell.lblText.text = objDict["name"] as? String ?? ""
        }else if isFeeling == true {
            let objDict = arrFeelings[indexPath.row]
            cell.lblImage.text = objDict["image"] as? String ?? ""
            cell.lblText.text = objDict["name"] as? String ?? ""
            
        }else {
            let objDict = arrActivities[indexPath.row]
            cell.lblImage.text = objDict["image"] as? String ?? ""
            cell.lblText.text = objDict["name"] as? String ?? ""
        }
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 1.0
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objDict:Dictionary<String, Any>!
        if searchBar.text!.length > 0 {
             objDict = arrSearched[indexPath.row]
        }else if isFeeling == true {
             objDict = arrFeelings[indexPath.row]
        }else {
             objDict = arrActivities[indexPath.row]
        }
        
        feelingActivityDelegate.feeLingActivitySelected(feelingActivity: objDict, isFeeling: isFeeling)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- UISearchbar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)  {
        
        print(searchText)
        arrSearched.removeAll()
        if isFeeling == true {
            for obj in arrFeelings {
                let name = obj["name"] as? String ?? ""
                if name.lowercased().hasPrefix(searchText.lowercased()) {
                    arrSearched.append(obj)
                }
            }
        }else {
            for obj in arrActivities {
                let name = obj["name"] as? String ?? ""
                if name.lowercased().hasPrefix(searchText.lowercased()) {
                    arrSearched.append(obj)
                }
            }
        }
        cvFeelingActivity.reloadData()
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}
