//
//  LiveJoinVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 1/3/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class LiveJoinVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bgBlurImagevw: UIImageView!
    var overlayController: LiveOverlayViewController!
    var leftRoomId = ""
    var selectedUserId = ""
    
    //MARK: Controller Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tblView.register(UINib(nibName: "LiveStreamingTblCell", bundle: nil), forCellReuseIdentifier: "LiveStreamingTblCell")
        selectedUserId = leftRoomId
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "liveJoinOverlay" {
            overlayController = segue.destination as? LiveOverlayViewController
            overlayController.fromId = selectedUserId
            overlayController.isGoLiveUser = false
            let label = UILabel()
            label.setNameTxt(Themes.sharedInstance.Getuser_id(), "single")
        }
    }
    
}


extension LiveJoinVC:UITableViewDelegate,UITableViewDataSource{
    
    //MARK: UITableView Delegate & Datasource methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return tblView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveStreamingTblCell", for: indexPath) as! LiveStreamingTblCell
        
        return cell
    }
    
    
    
}
