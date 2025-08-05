//
//  RequestGoLiveVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 3/26/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import AVKit
import Foundation

class RequestGoLiveVC: UIViewController {

    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var videoView: VideoPlayerView!

    var titleArray = ["Full Name","Audition Video Link"]
    var videoLink = ""
    var name = ""

    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "InputTblCell", bundle: nil), forCellReuseIdentifier: "InputTblCell")
        guard let realm = DBManager.openRealm() else {
            return
        }
        
        if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: Themes.sharedInstance.Getuser_id()) {
            name = existingUser.name
        }
        btnSubmit.layer.cornerRadius = 8.0
        btnSubmit.clipsToBounds = true
        
        print("Settings.sharedInstance.auditionVideoEx === \(Settings.sharedInstance.auditionVideoEx)")
        
        if let videoURL = URL(string:Settings.sharedInstance.auditionVideoEx){
            videoView.setURLToPlay(for:videoURL)
        }
       // videoView.play(for: URL(string:Settings.sharedInstance.auditionVideoEx)!)
        videoView.pause()
        videoView.layer.cornerRadius = 8.0
        videoView.clipsToBounds = true
        videoView.contentMode = .scaleAspectFit
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.videoView.addGestureRecognizer(tap)

    }
    
    @objc  func handleTap() {
        
        if  let videoURL = URL(string: Settings.sharedInstance.auditionVideoEx){
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.player?.isMuted = false
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    //MARK: UIButton Action methods
    @IBAction func backButtonActionMethods(_ sender : UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
 
    @IBAction func submitRequestButtonActionMethods(_ sender : UIButton){
        self.view.endEditing(true)
        
        if videoLink.length == 0 {
            Themes.sharedInstance.ShowNotification("Please enter valid url", false)
            
        }else if  !videoLink.validateUrl(){
           Themes.sharedInstance.ShowNotification("Inavlid url", false)
        }else{
            goLiveRequestAccessApi()
        }
    }
    
    func goLiveRequestAccessApi(){
        
        let param:NSDictionary = ["action":1,"videoLink":videoLink]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.go_live_access_request, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: message as NSString, buttonTitles: ["Okay"], onController: self) { title, index in
                        self.navigationController?.popViewController(animated: true)
                    }
                    Settings.sharedInstance.isLiveAllowed = 0
                }
                else
                {
                    self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }

}

extension RequestGoLiveVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    //MARK: UITextfield Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1{
            videoLink =  textField.text ?? ""
            self.tblView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: UITableview Delegate & Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "InputTblCell") as! InputTblCell
        
        cell.txtFdName.setAttributedPlaceHolder(frstText: titleArray[indexPath.row] , color: UIColor.lightGray, secondText: "*", secondColor: UIColor.red)
        cell.txtFdName.isAllowCopyPaste = true
        cell.txtFdName.iconWidth = 0
        cell.txtFdName.delegate = self
        cell.txtFdName.tag = indexPath.row
        
        switch indexPath.row {
        case 0:
            cell.txtFdName.text = name
            cell.txtFdName.isUserInteractionEnabled = false
            break
        case 1:
            cell.txtFdName.text = videoLink
            cell.txtFdName.isUserInteractionEnabled = true
            break
        default:
            break
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            
        }else if indexPath.row == 1{
            
        }
    }
    
   
}




