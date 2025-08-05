//
//  DeleteAccountVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 10/18/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit
import IQKeyboardManager

class DeleteAccountVC: UIViewController {
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var tblView: UITableView!
    var selectedIndex = 0
    var subTitleArray = ["This is a temporary deactivation of your account, which could be done deliberately or unintentionally from the user’s side.","This is a permanent deletion of your account, which means you won't be able to retrieve your account, once it is deleted."]
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.estimatedRowHeight = 70
        tblView.rowHeight = UITableView.automaticDimension
    }
    
    //MARK: UIBUtton Action Methods
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

   
    @IBAction func deleteButtonAction(_ sender: Any) {
        
        let destVc:DeleteAccountOptionsVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "DeleteAccountOptionsVC") as! DeleteAccountOptionsVC
        destVc.selectedOption = selectedIndex
        self.navigationController?.pushViewController(destVc, animated: true)
    }
    
    
  
    
}


extension DeleteAccountVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteAccountTblCell", for: indexPath) as! DeleteAccountTblCell
        cell.lblDesc.text = subTitleArray[indexPath.row]
        cell.btnRadio.setImage(UIImage(named: "unselectedRadio"), for: .normal)
        if indexPath.row == selectedIndex{
            cell.btnRadio.setImage(UIImage(named: "selectedRadio"), for: .normal)
        }
        if indexPath.row == 0 {
            cell.lblTitle.text = "Deactivate Account"
           
        }else if indexPath.row == 1{
            cell.lblTitle.text = "Delete Account"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tblView.reloadData()
        
        if indexPath.row == 0{
            self.btnDelete.setTitle("Deactivate Account", for: .normal)
        }else if indexPath.row == 1{
            self.btnDelete.setTitle("Delete Account", for: .normal)
        }
        
    }
}

class DeleteAccountTblCell:UITableViewCell{
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var btnRadio:UIButton!

}
