//
//  TableViewExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets


protocol OptionDelegate: AnyObject{
    
    func selectedOption(index:Int,videoIndex:Int,title:String)
}

class TableViewDemo: UIViewController {
    weak var delegate:OptionDelegate? = nil
    var videoIndex = 0
    @IBOutlet weak var tableView: UITableView!
    var listArray = NSMutableArray()
    var iconArray = NSMutableArray()
    var countRowIndex = -1
    var countNotification = ""
    var isToHideSeperator = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.sheetViewController?.handleScrollView(self.tableView)
    }
    
    deinit {
        self.delegate = nil
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView = nil
    }


}

extension TableViewDemo: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowTblCell", for: indexPath) as! RowTblCell
        cell.bgVwSeperator.isHidden = isToHideSeperator

        if let title = listArray.object(at: indexPath.row) as? String{
            cell.lblTitle.text = title
        }
        cell.lblTitle.numberOfLines = 0
        if iconArray.count > 0{
            if let iconName = iconArray.object(at: indexPath.row) as? String{
                cell.imgVwIcon.image = UIImage(named: iconName)
                cell.cnstrnt_WidthImage.constant = 20
                cell.imgVwIcon.layoutIfNeeded()
            }
        }else{
            cell.cnstrnt_WidthImage.constant = 0
            cell.imgVwIcon.layoutIfNeeded()

        }
        
        
        if indexPath.row == countRowIndex && countNotification.count > 0{
            cell.lblCount.isHidden = false
            cell.lblCount.text = countNotification
            cell.lblCount.layer.cornerRadius = 12.5
            cell.lblCount.clipsToBounds = true
            cell.lblCount.backgroundColor = .systemRed
            cell.lblCount.textColor = .white
        }else{
            cell.lblCount.isHidden = true
        }
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedOption(index: indexPath.row, videoIndex: videoIndex, title: listArray.object(at: indexPath.row) as? String ?? "")
        //   self.dismiss(animated: true, completion: nil)
        //   self.navigationController?.dismiss(animated: true, completion: nil)
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}


class RowTblCell:UITableViewCell{
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var imgVwIcon:UIImageView!
    @IBOutlet weak var cnstrnt_WidthImage:NSLayoutConstraint!
    @IBOutlet weak var lblCount:UILabel!
    @IBOutlet weak var bgVwSeperator:UIView!

    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
