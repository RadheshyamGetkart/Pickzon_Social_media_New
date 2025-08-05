//
//  JobsHomeVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 2/28/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class JobsHomeVC: UIViewController {
    @IBOutlet weak var tblSuggestedJobs:UITableView!
    var pageNumber = 1
    
    var arrSuggestedJobs:Array<JobDetail> = Array()
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblSuggestedJobs.separatorStyle = .none
        
        tblSuggestedJobs.register(UINib(nibName: "suggestedJobsCell", bundle: nil),
                          forCellReuseIdentifier: "suggestedJobsCell")

        tblSuggestedJobs.estimatedRowHeight = 148
        tblSuggestedJobs.rowHeight = UITableView.automaticDimension
        tblSuggestedJobs.separatorColor = UIColor.clear
        self.getSuggestedJobs()
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    func getSuggestedJobs(){
        let suggestedJobURL = Constant.sharedinstance.getSuggestedJobsURL + "/\(pageNumber)"
        
        URLhandler.sharedinstance.makeGetAPICall(url: suggestedJobURL, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1{
                    
                    if let payload = result["payload"] as? Array<Dictionary<String, Any>> {
                        for obj in payload {
                            self.arrSuggestedJobs.append(JobDetail(dict: obj))
                        }
                        self.tblSuggestedJobs.reloadData()
                    }
                } else {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    @IBAction func addNewJob() {
        let destVc:CreateJobStep1VC = StoryBoard.job.instantiateViewController(withIdentifier: "CreateJobStep1VC") as! CreateJobStep1VC
        
        self.navigationController?.pushViewController(destVc, animated: true)
    }

}

extension JobsHomeVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.arrSuggestedJobs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestedJobsCell") as! suggestedJobsCell
        cell.selectionStyle = .none
        let objJobDetail =  arrSuggestedJobs[indexPath.row]
        cell.imgProfilePic.kf.setImage(with: URL(string: objJobDetail.employer.actualProfileImage), placeholder: PZImages.dummyCover, options: nil, progressBlock: nil) { response in}
        cell.lblJobTitle.text = objJobDetail.jobTitle
        cell.lblCompanyName.text = objJobDetail.company
        cell.lblLocation.text = objJobDetail.location.state + objJobDetail.location.country
        cell.lblJobTime.text = objJobDetail.jobTime
        if objJobDetail.workplace.count > 0 {
            cell.lblWorkPlace.text = "   " + objJobDetail.workplace + "   "
        }else {
            cell.lblWorkPlace.text =  objJobDetail.workplace
        }
        
        if objJobDetail.experienceLevel.count > 0 {
            cell.lblExpLevel.text = "   " + objJobDetail.experienceLevel + "   "
        }else {
            cell.lblExpLevel.text =  objJobDetail.experienceLevel
        }
        
        if objJobDetail.jobType.count > 0 {
            cell.lblJobType.text = "   " + objJobDetail.jobType + "   "
        }else {
            cell.lblJobType.text =  objJobDetail.jobType 
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


struct JobDetail {
    var company = ""
    var currency = ""
    var description = ""
    var education = ""
    var employer:Employer!
    var experienceLevel = ""
    var gender = ""
    var industry = ""
    
    var isApplied = 0
    var isSaved = 0
    var jobId = ""
    var jobTime = ""
    var jobTitle = ""
    var jobType = ""
    var location = LocationModal(locationDict:[:])
    var maximumSalary = 0
    var minimumSalary = 0
     
    var openings = 0
    var salaryPaid = ""
    var salaryvisibility = 0
    var skills: Array<String> = Array()
    var workplace = ""
    
    init(dict:Dictionary<String, Any>) {
        
        self.company = dict["company"] as? String ?? ""
        self.currency = dict["currency"] as? String ?? ""
        self.description = dict["description"] as? String ?? ""
        self.education = dict["education"] as? String ?? ""
        self.employer = Employer(dict: dict["employer"] as? Dictionary<String, Any> ?? [:])
        self.experienceLevel = dict["experienceLevel"] as? String ?? ""
        self.gender = dict["gender"] as? String ?? ""
        self.industry = dict["industry"] as? String ?? ""
        
        self.isApplied = dict["isApplied"] as? Int ?? 0
        self.isSaved = dict["isSaved"] as? Int ?? 0
        self.jobId = dict["jobId"] as? String ?? ""
        self.jobTime = dict["jobTime"] as? String ?? ""
        self.jobTitle = dict["jobTitle"] as? String ?? ""
        self.jobType = dict["jobType"] as? String ?? ""
        self.location = LocationModal(locationDict: dict["location"] as? NSDictionary ?? [:] )
        self.maximumSalary = dict["maximumSalary"] as? Int ?? 0
        self.minimumSalary = dict["minimumSalary"] as? Int ?? 0
        self.salaryPaid = dict["salaryPaid"] as? String ?? ""
        self.openings = dict["openings"] as? Int ?? 0
        self.salaryvisibility = dict["salaryvisibility"] as? Int ?? 0
        self.skills = dict["skills"] as? Array<String> ?? []
        self.workplace = dict["workplace"] as? String ?? ""
    }
}
struct Employer {
    var actualProfileImage = ""
    var celebrity = 0
    var headline = ""
    var jobProfile = ""
    var livesIn = ""
    var name = ""
    var pickzonId = ""
    var profilePic = ""
    var userId = ""
    
    init(dict:Dictionary<String,Any>) {
        self.actualProfileImage = dict["actualProfileImage"] as? String ?? ""
        self.celebrity = dict["celebrity"] as? Int ?? 0
        self.headline = dict["headline"] as? String ?? ""
        self.jobProfile = dict["jobProfile"] as? String ?? ""
        self.livesIn = dict["livesIn"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.pickzonId = dict["pickzonId"] as? String ?? ""
        self.profilePic = dict["profilePic"] as? String ?? ""
        self.userId = dict["userId"] as? String ?? ""
    }
}
