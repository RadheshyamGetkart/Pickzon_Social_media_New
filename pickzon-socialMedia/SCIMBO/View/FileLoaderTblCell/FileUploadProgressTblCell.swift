//
//  FileUploadProgressTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 5/2/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class FileUploadProgressTblCell: UITableViewCell {
    
    @IBOutlet weak var imgVw:UIImageView!
    @IBOutlet weak var progreessVw:UIProgressView!
    @IBOutlet weak var lblPercentage:UILabel!
    var isFoundThumbnail = false
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        progreessVw.progress = 1.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setDataInProgress(progress:CGFloat,mediaArray:Array<Any>){
        
        DispatchQueue.main.async {
            self.progreessVw.progress = Float(progress)
            self.lblPercentage.text = "\(String(format: "%.0f", progress * 100))%"
        }
        
        if mediaArray.count > 0 && isFoundThumbnail == false{
            //self.isFoundThumbnail = true
            if let img = mediaArray.first as? UIImage{
                DispatchQueue.main.async {
                    
                    self.imgVw.image = img
                    
                }
            } else if let imgStr = mediaArray.first as? String{
                imgVw.kf.setImage(with: URL(string: imgStr),placeholder: UIImage(named:"dummy"))
            }else if let imgUrl = mediaArray.first as? URL{
                DispatchQueue.main.async {
                    
                    self.imgVw.image = UIImage(contentsOfFile: imgUrl.path)
                }
            }
        }
    }
}
