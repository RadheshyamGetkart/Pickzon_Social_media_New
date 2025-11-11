//
//  SearchSuggestionVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 27/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher


protocol SearchTextDelegate{
    
    func searchedTxt(txt:String)
}

class SearchSuggestionVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar :NSLayoutConstraint!
    @IBOutlet weak var txtFdSearch :UITextField!
    @IBOutlet weak var tblView :UITableView!
    @IBOutlet weak var btnBack :UIButton!
    var delegate:SearchTextDelegate?
    var suggestionArray = Array<Any>()
    var isDataLoading = false
    var srchTxt = ""
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.setImageTintColor(CustomColor.sharedInstance.newThemeColor)
        self.tblView.register(UINib(nibName: "HashTagTblCell", bundle: nil), forCellReuseIdentifier: "HashTagTblCell")
        txtFdSearch.text = srchTxt
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cnstrntHtNavBar.constant = self.getNavBarHt
    }
    
    //MARK: UIbutton Action methods
    @IBAction func backBtnAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK: Api Methods
    
    func searchSuggestionApi(srchTxt:String){
        
        self.isDataLoading = true
        self.suggestionArray.removeAll()
        self.tblView.reloadData()
            
        let param:NSDictionary  = ["keyword":srchTxt]
       
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.feed_search_suggestion, param: param, completionHandler: {(responseObject, error) ->  () in
            if(error != nil)
            {
                // Themes.sharedInstance.RemoveactivityView(View: self.view)
                // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
               // let message = result["message"] as? String ?? ""
                
                
                if status == 1{
                    
                    /* Type -->> 1 -> HashTag 2-> Post 3->Users*/
                    
                    if let payload = result.value(forKey: "payload") as? Array<Any>{
                        self.suggestionArray = payload
                    }
                    self.tblView.reloadData()
                    self.isDataLoading = false

                    
                }else{
                    self.isDataLoading = false
                    // Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
            }
        })
    }
}


extension SearchSuggestionVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        delegate?.searchedTxt(txt: textField.text ?? "")
        self.navigationController?.popViewController(animated: false)
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Convert current text to NSString to use NSRange safely
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return true }
        
        // Get updated text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if !isDataLoading {
            self.searchSuggestionApi(srchTxt: updatedText)
        }
        
        return true
    }
}



extension SearchSuggestionVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "HashTagTblCell", for: indexPath) as!
        HashTagTblCell
        cell.imgvwProfile.isHidden = true
        cell.bgViewImg.isHidden = false

        if let respDict = suggestionArray[indexPath.item] as? Dictionary<String,Any>{
            
            
            cell.lblTitle.text = "\(respDict["name"] as? String ?? "")"
            cell.lblCount.text = ""
            
            switch (respDict["type"] as? Int ?? 0){
                
            case 1:
                cell.imgView.image = UIImage(named: "hashtag")
                break
            case 2:
                cell.imgView.image = UIImage(named: "srchIcon")
                break
            case 3:
                cell.bgViewImg.isHidden = true
                cell.lblCount.text = "\(respDict["pickzonId"] as? String ?? "")"
                cell.imgvwProfile.isHidden = false
                let processor = CroppingImageProcessor(size: CGSize(width:  cell.imgvwProfile.frame.width, height:  cell.imgvwProfile.frame.height), anchor: CGPoint(x: 0.5, y: 0.5))

//                cell.imgvwProfile.kf.setImage(with: URL(string: "\(respDict["profilePic"] as? String ?? "")"),placeholder: PZImages.avatar,options: [.processor(processor),)
//
                cell.imgvwProfile?.kf.setImage(with: URL(string: "\(respDict["profilePic"] as? String ?? "")"), placeholder: PZImages.avatar , options: [.processor(processor)], progressBlock: nil, completionHandler: { response in        })

               /* cell.imgvwProfile.setImgView(profilePic:"\(respDict["profilePic"] as? String ?? "")", frameImg: "\(respDict["avatar"] as? String ?? "")",changeValue: ("\(respDict["avatar"] as? String ?? "")".count > 0) ? 8 : 5)*/

                break
            default:
                break
            }
        }
        

        cell.bgViewImg.layer.cornerRadius = cell.bgViewImg.frame.height/2.0
        cell.bgViewImg.layer.borderColor = UIColor(hexString: "#737A7F").cgColor
        cell.bgViewImg.layer.borderWidth = 1.0
        cell.bgViewImg.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let respDict = suggestionArray[indexPath.item] as? Dictionary<String,Any>{
            
            switch (respDict["type"] as? Int ?? 0){
                
            case 1:
                let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
                destVc.controllerType = .hashTag
                destVc.hashTag = "\(respDict["name"] as? String ?? "")"
                (AppDelegate.sharedInstance.navigationController?.topViewController)?.pushView(destVc, animated: true)
                break
                
            case 2:
                delegate?.searchedTxt(txt: "\(respDict["name"] as? String ?? "")")
                self.navigationController?.popViewController(animated: false)
                break
            case 3:
                let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.otherMsIsdn = "\(respDict["id"] as? String ?? "")"
                (AppDelegate.sharedInstance.navigationController?.topViewController)?.pushView(profileVC, animated: true)
                break
            default:
                break
            }
            
        }
    }
}
