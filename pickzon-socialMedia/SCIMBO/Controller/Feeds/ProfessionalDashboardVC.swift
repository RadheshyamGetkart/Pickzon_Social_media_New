//
//  ProfessionalDashboardVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 4/16/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher
import FSCalendar
import Kingfisher
import FittedSheets

class ProfessionalDashboardVC: UIViewController {
    //Event pass
    
    @IBOutlet weak var btnRedeemEventPass: UIButton!
    @IBOutlet weak var btnCheckEventPass: UIButton!
    
    @IBOutlet weak var dashedView: UIView!
    @IBOutlet weak var lblTotalRecieved: UILabel!
    @IBOutlet weak var lblVirtualPassTitle: UILabel!
    @IBOutlet weak var lblEntryPassTitle: UILabel!
    @IBOutlet weak var lblEntryPass: UILabel!
    @IBOutlet weak var lblVipPass: UILabel!

    @IBOutlet weak var bgViewEventPass: UIView!
    @IBOutlet weak var tblViewEventPass: UITableView!
    @IBOutlet weak var imgVwPass: UIImageView!

    
    @IBOutlet weak var cnstrntHtNavBar: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblTotalVideos: UILabel!
    @IBOutlet weak var lblTotalViews: UILabel!
    @IBOutlet weak var lblTotalLikes: UILabel!
    @IBOutlet weak var btnFromDate: UIButton!
    
    @IBOutlet weak var btnCreator: UIButton!
    @IBOutlet weak var btnEventPasses: UIButton!
    @IBOutlet weak var lblSeperator: UILabel!

    
    var pageNumber = 1
    var isDataLoading = false
    var fromDate = ""
    var toDate = ""
    var listArray:Array<DashboardModel> = Array<DashboardModel>()
    var isFromSelected = true
    var isMoreDataAvailable = true
    var calendar:FSCalendar?
    var dateFormatter:DateFormatter?
    var date1:Date?
    var date2: Date?
    var gregorian:NSCalendar?
    var benefits = [String]()
    @IBOutlet weak var calenDarBgVw: UIView!
    @IBOutlet weak var btnSelectDate: UIButton!
    @IBOutlet weak var lblDateAndTime: UILabel!
    @IBOutlet weak var btnCloseCalendar: UIButton!
    @IBOutlet weak var calenDarView: UIView!
    @IBOutlet weak var tblHeaderBgVw: UIView!
    
    
    @IBOutlet weak var imgVwArrowRed: UIImageView!
    @IBOutlet weak var imgVwArrowGreen: UIImageView!
    @IBOutlet weak var imgVwArrowYellow: UIImageView!
    @IBOutlet weak var lblGoodPercentage: UILabel!
    @IBOutlet weak var lblPercentageStatus: UILabel!
    @IBOutlet weak var graphBgView: UIView!

    @IBOutlet weak var btnGuidelines: UIButton!

    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    
    //MARK: Controller life cycyle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnGuidelines.setImageTintColor(.label)
        imgVwArrowRed.transform = imgVwArrowRed.transform.rotated(by:292)
        imgVwArrowRed.setImageViewTintColor(color: UIColor.label)
        imgVwArrowYellow.transform = imgVwArrowYellow.transform.rotated(by:-10)
        imgVwArrowYellow.setImageViewTintColor(color: UIColor.label)
        imgVwArrowGreen.transform = imgVwArrowGreen.transform.rotated(by:-55)
        imgVwArrowGreen.setImageViewTintColor(color: UIColor.label)
        
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "ProfessionalDashTblCell", bundle: nil), forCellReuseIdentifier: "ProfessionalDashTblCell")
        tblViewEventPass.register(UINib(nibName: "BenefitsTblCell", bundle: nil), forCellReuseIdentifier: "BenefitsTblCell")

        self.bgViewEventPass.isHidden = true
        calenDarBgVw.isHidden = true
        
        self.lblSeperator.frame =  CGRect(x: btnCreator.frame.origin.x, y: btnCreator.frame.origin.y+btnCreator.frame.size.height, width: btnCreator.frame.size.width, height: 2)
        self.btnEventPasses.setTitleColor(.lightGray, for: .normal)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from:  Date())

        let startDateOfMonth = "\(year)/\(month)/1"
        fromDate = startDateOfMonth
        self.btnFromDate.setTitle(startDateOfMonth, for: .normal)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let toDateStr = dateFormatter.string(from: Date())
        toDate = toDateStr
        
        date1 = dateFormatter.date(from: startDateOfMonth)

        date2 = Date()

        self.dateFormatter =  DateFormatter()
        self.dateFormatter?.dateFormat = "E, d MMM yyyy"
       
       /* if date1 != nil && date2 != nil{
            
            let date1Str =  self.dateFormatter?.string(from: self.date1!)
            let date2Str =  self.dateFormatter?.string(from: self.date2!)
            
            let diffInDays = Calendar.current.dateComponents([.day], from: self.date1!, to: self.date2!).day ?? 1
            var daysStr = ""
            if diffInDays == 0{
                daysStr = "(\(1) day)"
            }else{
                daysStr = "(\(diffInDays) days)"
            }
            self.btnFromDate.setTitle("\(date1Str!)-\(date2Str!) \(daysStr)", for: .normal)
        }*/
        
        self.btnFromDate.setTitle(setDateFormat(), for: .normal)
        
        getProfessionalDahboardApi()
        setUpcalendar()
        
        self.imgVwArrowRed.isHidden = true
        self.imgVwArrowYellow.isHidden = true
        self.imgVwArrowGreen.isHidden = true
        
        self.tblView.addSubview(self.topRefreshControl)
        
        btnRedeemEventPass.layer.cornerRadius = 5.0
        btnRedeemEventPass.clipsToBounds = true
        
      //btnCheckEventPass.setUnderlineForButton(text: "Check entry pass", color: .systemBlue, fontSize: 16.0, fontName: "Roboto-medium")
    }
    
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
       
        if isDataLoading == false{
            self.isDataLoading = true
            self.pageNumber = 1
            listArray.removeAll()
            self.tblView.reloadData()
            getProfessionalDahboardApi()
        }
        refreshControl.endRefreshing()
    }
    
    func setUpcalendar(){
        btnCloseCalendar.setImageTintColor(.darkGray)
        btnSelectDate.layer.cornerRadius = 5.0
        
        
        self.gregorian =  NSCalendar(identifier: .gregorian)
        self.dateFormatter =  DateFormatter()
        self.dateFormatter?.dateFormat = "yyyy-MM-dd"
        
        var calendar = FSCalendar(frame: CGRectMake(0, 0, calenDarView.frame.width, calenDarView.frame.height))
        print("Themes.sharedInstance.modelName=\(Themes.sharedInstance.modelName)")
        if Themes.sharedInstance.modelName.contains("5") || Themes.sharedInstance.modelName == "iPhone 6s"{
              calendar = FSCalendar(frame: CGRectMake(0, 0, calenDarView.frame.width-20, calenDarView.frame.height))
        }
        calendar.dataSource = self
        calendar.delegate = self
        calendar.pagingEnabled = true
        calendar.allowsMultipleSelection = true
        calendar.rowHeight = 60
        calendar.placeholderType = .none
        calenDarView.addSubview(calendar)
        self.calendar = calendar
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.titleFont = UIFont(name: "Roboto-Regular", size: 16)
        calendar.weekdayHeight = 30
        calendar.swipeToChooseGesture.isEnabled = true
        self.calendar?.appearance.eventDefaultColor = UIColor.systemBlue
        self.calendar?.appearance.weekdayTextColor = .black
        self.calendar?.appearance.weekdayFont = UIFont(name: "Roboto-Medium", size: 18)
      //  calendar.today = nil; // Hide the today circle
        self.calendar?.appearance.titleTodayColor = .black
        
        self.calendar?.register(RangePickerCell.self, forCellReuseIdentifier: "cell")
        
        self.setDates(d1: date1, d2: date2)
      
    }
    
    
    //Live Event passs
    
    func eventPassUpdateUI(){
        drawDottedLine(start: CGPoint(x: dashedView.bounds.minX, y: dashedView.bounds.minY), end: CGPoint(x: dashedView.bounds.maxX, y: dashedView.bounds.minY), view: dashedView)
        lblTotalRecieved.text = ""
    }

    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [2, 3] // 7 is the length of dash, 3 is length of the gap.

        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    //MARK: UIButton Action Methods
    @IBAction func redeemVirtualPassButtonActionMethod(_ sender:UIButton){
        
        let destVC:ReedemVirtualPassVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ReedemVirtualPassVC") as! ReedemVirtualPassVC
       // destVC.delegate = self
        destVC.modalPresentationStyle = .overCurrentContext
        self.presentView(destVC, animated: true)
    }
    
    @IBAction func checkEntryPassButtonActionMethod(_ sender:UIButton){
        
    }

    
    @IBAction func guidelinesButtonActionMethod(_ sender:UIButton){
        
        if #available(iOS 13.0, *) {
            let controller = StoryBoard.promote.instantiateViewController(identifier: "GuideLinesVC")
            as! GuideLinesVC
            controller.guidelinesType = .professionalDashboard
            controller.title = ""
            let useInlineMode = view != nil
            let nav = UINavigationController(rootViewController: controller)
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.percent(0.75),.intrinsic],
                options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
            sheet.allowGestureThroughOverlay = false
            sheet.cornerRadius = 20

            if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
                sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            } else {
                (AppDelegate.sharedInstance.navigationController?.topViewController)?.present(sheet, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func closeCalendarButtonActionMethod(_ sender:UIButton){
        
        calenDarBgVw.isHidden = true
        
    }

    
    @IBAction func selectButtonActionMethod(_ sender:UIButton){
        
        
        if date1 != nil && date2 != nil {
           
            self.pageNumber = 1
           // self.btnFromDate.setTitle(lblDateAndTime.text, for: .normal)
            self.btnFromDate.setTitle(setDateFormat(), for: .normal)
            calenDarBgVw.isHidden = true
            self.dateFormatter?.dateFormat = "YYYY/MM/dd"
            if let d1 = self.dateFormatter?.string(from: date1!){
                  fromDate = d1
            }
            
            if let d2 = self.dateFormatter?.string(from: date2!){
                toDate = d2
            }
            
            self.getProfessionalDahboardApi()
        }else{
            self.view.makeToast(message:"Please select Date range", duration: 3, position: HRToastActivityPositionDefault)

        }
        

        
    }

    
    @IBAction func backButtonActionMethods(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func fromDateButtonActionMethods(_ sender:UIButton){
        calenDarBgVw.isHidden = false

    }
    
  
    
    @IBAction func  commonTabButtonActionMethods(_ sender:UIButton){
        
        
        self.btnCreator.setTitleColor(.secondaryLabel, for: .normal)
        self.btnEventPasses.setTitleColor(.secondaryLabel, for: .normal)
        sender.setTitleColor(.label, for: .normal)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.lblSeperator.frame =  CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y+sender.frame.size.height, width: sender.frame.size.width, height: 2) })
        
        switch sender.tag{
            
        case 5000:
            self.bgViewEventPass.isHidden = true
            self.btnGuidelines.isHidden = false

            break
        
        case 5001:
            self.bgViewEventPass.isHidden = false
            self.eventPassUpdateUI()
            self.getEventPassApi()
            self.btnGuidelines.isHidden = true
            break
       
        default:
           
            break
        }
        
    }
    
    
    //MARK: Api methods
    
    func getProfessionalDahboardApi(){
        
//        fromDate = "2023/01/15"
//        toDate = "2024/04/15"
        
        if pageNumber == 1{
            tblHeaderBgVw.isHidden = true
        }
        let param:NSDictionary = ["fromDate":"\(fromDate)","toDate":"\(toDate)","pageNumber":pageNumber]
                
        Themes.sharedInstance.activityView(View: self.view)
        
        self.isDataLoading = true
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.performance_dashboard as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
              
                if status == 1{
                    
                    if self.pageNumber == 1{
                        self.isMoreDataAvailable = true
                        self.listArray.removeAll()
                        self.tblView.reloadData {
                        }
                    }
                    if let payload = result["payload"] as? Dictionary<String,Any>{
                        
                        if let listCount = payload["listCount"] as? Dictionary<String,Any>{
                            if self.pageNumber == 1{
                                
                                self.lblTotalLikes.text = (listCount["totalLike"] as? Int ?? 0).asFormatted_k_String
                                self.lblTotalViews.text = (listCount["totalView"] as? Int ?? 0).asFormatted_k_String
                                self.lblTotalVideos.text = (listCount["totalVideo"] as? Int ?? 0).asFormatted_k_String
                                
                                let gaugeScore = listCount["score"] as? Int ?? 0
                                let gaugePercentage = listCount["scorePercentage"] as? Int ?? 0
                                
                                self.lblGoodPercentage.text = "\(gaugePercentage)%"
                                self.imgVwArrowRed.isHidden = true
                                self.imgVwArrowYellow.isHidden = true
                                self.imgVwArrowGreen.isHidden = true

                                if gaugeScore == 0{
                                    self.imgVwArrowRed.isHidden = false
                                    self.lblPercentageStatus.textColor = Themes.sharedInstance.colorWithHexString(hex: "#ff1e0d")
                                    self.lblGoodPercentage.textColor = Themes.sharedInstance.colorWithHexString(hex: "#ff1e0d")

                                    self.lblPercentageStatus.text = "POOR"
                                }else  if gaugeScore == 1{
                                    self.imgVwArrowYellow.isHidden = false
                                    self.lblPercentageStatus.textColor = Themes.sharedInstance.colorWithHexString(hex: "#ffb100")
                                    self.lblGoodPercentage.textColor = Themes.sharedInstance.colorWithHexString(hex: "#ffb100")

                                    self.lblPercentageStatus.text = "GOOD"
                                }else  if gaugeScore == 2{
                                    self.imgVwArrowGreen.isHidden = false
                                    self.lblPercentageStatus.textColor = Themes.sharedInstance.colorWithHexString(hex: "#01a900")
                                    self.lblGoodPercentage.textColor = Themes.sharedInstance.colorWithHexString(hex: "#01a900")

                                    self.lblPercentageStatus.text = "EXCELLENT"
                                }
                            }
                        }
                        self.tblHeaderBgVw.isHidden = false
                        
                        if let videoList = payload["videoList"] as? Array<Dictionary<String, Any>> {
                            
                            for dict in videoList{
                                self.listArray.append(DashboardModel(respDict: dict))
                            }
                            self.isMoreDataAvailable = (videoList.count > 0) ? true : false
                        }
                        
                        self.graphBgView.isHidden = (self.listArray.count == 0) ? true : false
                        
                        self.tblView.reloadData {
                            self.pageNumber = self.pageNumber + 1
                            self.isDataLoading = false
                        }
                    }
                }
                else
                {
                    self.isDataLoading = false
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    //
    func getEventPassApi(){
     
        Themes.sharedInstance.activityView(View: self.view)
        
        self.isDataLoading = true
        
        URLhandler.sharedinstance.makeGetAPICall(url: Constant.sharedinstance.user_event_pass , param: NSDictionary()) { responseObject, error in

            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.isDataLoading = false

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
              
                if status == 1{
                
                    if let payload = result["payload"] as? Dictionary<String,Any>{
                        
                        if let benefits =  payload["benefits"] as?  Array<String>{
                            self.benefits = benefits
                        }
                        let passUrl =   payload["passUrl"] as? String ?? ""
                        
                        self.lblTotalRecieved.text =  "\(payload["received"] as? Int ?? 0)"
                        
                        self.imgVwPass.kf.setImage(with: URL(string: passUrl), placeholder: PZImages.dummyCover, progressBlock: nil) { response in}
                       
                        let virtualPasses = payload["virtualPasses"] as? Int ?? 0
                        let entryPasses = payload["entryPasses"] as? Int ?? 0
                        let entryPass = payload["entryPass"] as? Int ?? 0
                        let vipPass = payload["vipPass"] as? Int ?? 0

                        self.lblVirtualPassTitle.text = "\(virtualPasses) Virtual passes ="
                        self.lblEntryPassTitle.text = "\(entryPasses) Entry passes ="
                        self.lblEntryPass.text = "\(entryPass) Entry pass"
                        self.lblVipPass.text = "\(vipPass) VIP pass"
                        
                        self.tblViewEventPass.reloadData {
                            
                        }
                    }
                }
                else
                {
                    self.isDataLoading = false
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
}

extension ProfessionalDashboardVC:FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance{
   
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        let calendar1 = NSCalendar.current
        let oneMonthBack = calendar1.date(byAdding: .month, value: -2, to: Date())
        return oneMonthBack ?? Date()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return [UIColor.black]
    }
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
//
//        if ((self.gregorian?.isDateInToday(date)) != nil) {
//            return [UIColor.blue]
//        }
//        return [UIColor.clear] //[appearance.eventDefaultColor]
//    }
   
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: .current)
       
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        FSCalendarClass.configureCell(cell, for: date, at: monthPosition, date1: (date1 ?? Date()), date2: (date2 ?? Date()), gregorian: self.gregorian! as Calendar)
    }
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date)
        
        if (calendar.swipeToChooseGesture.state == .changed) {
            // If the selection is caused by swipe gestures
            if (self.date1 == nil) {
                self.date1 = date
            } else {
                if (self.date2 != nil){
                    calendar.deselect(self.date2!)
                }
                self.date2 = date
            }
        } else {
            if (self.date2 != nil) {
                calendar.deselect(self.date1!)
                calendar.deselect(self.date2!)
                self.date1 = date
                self.date2 = nil
            } else if ((self.date1 == nil)) {
                self.date1 = date;
            } else {
                self.date2 = date;
            }
        }
        
        FSCalendarClass.configureVisibleCells(self.calendar!, date11: date1 ?? Date(), date22: date2 ?? Date(), gregorian1: self.gregorian! as Calendar)
        self.setDates(d1: date1, d2: date2)
       /*
        self.dateFormatter =  DateFormatter()
        self.dateFormatter?.dateFormat = "E, d MMM yyyy"
        let date1Str = dateFormatter?.string(from: self.date1!)
        
       
        let date2Str = dateFormatter?.string(from: self.date2!)

        let diffInDays = Calendar.current.dateComponents([.day], from: self.date1!, to: self.date2!).day
        var daysStr = ""
        if diffInDays == 0{
            daysStr = "(\(1) day)"
        }else{
            daysStr = "(\(diffInDays) day)"
        }
        
        self.lblDateAndTime.text = "\(date1Str) - \(date2Str) \(daysStr)"
        */
    }
    
    
    func setDateFormat()->String{
        self.dateFormatter =  DateFormatter()
        self.dateFormatter?.dateFormat = "d MMM yyyy"
        
           let date1Str = dateFormatter?.string(from: self.date1!)
           let date2Str = dateFormatter?.string(from: self.date2!)
           
           let diffInDays = Calendar.current.dateComponents([.day], from: self.date1!, to: self.date2!).day ?? 1
           var daysStr = ""
           if diffInDays == 0{
               daysStr = "(\(1) day)"
           }else{
               daysStr = "(\(diffInDays) days)"
           }
           
          return  "\(date1Str!) - \(date2Str!) \(daysStr)"
    }
    
    func setDates(d1:Date?,d2:Date?){
        
        
         self.dateFormatter =  DateFormatter()
         self.dateFormatter?.dateFormat = "E, d MMM yyyy"
        
        if d1 != nil && d2 != nil{
            
            if date1!.isGreaterThan(date2!) {
                let temp = date1
                date1 = date2
                date2 = temp
            }
            
            let date1Str = dateFormatter?.string(from: self.date1!)
            let date2Str = dateFormatter?.string(from: self.date2!)
            
            let diffInDays = Calendar.current.dateComponents([.day], from: self.date1!, to: self.date2!).day ?? 1
            var daysStr = ""
            if diffInDays == 0{
                daysStr = "(\(1) day)"
            }else{
                daysStr = "(\(diffInDays) days)"
            }
            
            self.lblDateAndTime.text = "\(date1Str!) - \(date2Str!) \(daysStr)"
            
        }else   if d1 == nil {
            
            self.lblDateAndTime.text = ""
        }else   if  d2 == nil{
            
            self.lblDateAndTime.text = ""

        }
         
    }
    // This delegate call when date is DeSelected
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
             print(date)
        
        FSCalendarClass.configureVisibleCells(self.calendar!, date11: date1 ?? Date(), date22: date2 ?? Date(), gregorian1: self.gregorian! as Calendar)
        self.setDates(d1: date1, d2: date2)

    }
    
   
}
extension ProfessionalDashboardVC:UITableViewDataSource,UITableViewDelegate{

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblViewEventPass{
            return UITableView.automaticDimension
        }
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tblViewEventPass{
            return benefits.count
        }
        return listArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblViewEventPass{
            
            let cell = tblViewEventPass.dequeueReusableCell(withIdentifier: "BenefitsTblCell") as! BenefitsTblCell
            cell.cnstrntStackVwTop.constant = 2.5
            cell.cnstrntStackVwBottom.constant = 2.5
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.btnCheck.isHidden =  false
            cell.lblTitle.isHidden =  false
            cell.btnCheck.contentHorizontalAlignment = .center
            cell.btnCheck.setImage(nil, for: .normal)
            cell.lblTitle.textColor = .black
            cell.btnCheck.setTitleColor(.black, for: .normal)
            cell.lblTitle.numberOfLines = 0
            cell.btnCheck.setTitle("\(indexPath.row + 1).", for: .normal)
            cell.lblTitle.text =  "\(benefits[indexPath.row])"
            cell.lblTitle.font = UIFont(name: FontRobotoMedium, size: 14)
            cell.btnCheck.titleLabel?.font = UIFont(name: FontRobotoMedium, size: 14)
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfessionalDashTblCell", for: indexPath) as! ProfessionalDashTblCell
            let obj = listArray[indexPath.row]
            cell.imgVwPost?.kf.setImage(with: URL(string: obj.thumbUrl), options: nil, progressBlock: nil, completionHandler: { response in  })
            cell.imgVwPost?.contentMode = .scaleAspectFill
            cell.lblLikeCount.text = obj.totalLike.asFormatted_k_String
            cell.lblViewCount.text = obj.viewCount.asFormatted_k_String
            cell.lblUnqualifiedReason.text = obj.isQualifiedReason
            
            if obj.isQualified == 1 {
                
                cell.bgVwUnqualified.isHidden = true
                cell.bgVwStack.isHidden = false
                cell.bgVwLikesCount.isHidden = false
                
            }else{
                
                cell.bgVwStack.isHidden = true
                cell.bgVwLikesCount.isHidden = true
                cell.bgVwUnqualified.isHidden = false
            }
            
            return cell
        }
      //  return UITableViewCell()

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == tblView {
            //Call API befor the end of all records
            if  indexPath.row == listArray.count-1  && listArray.count >= 15{
                if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                    
                    self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                    
                }else if !isDataLoading && isMoreDataAvailable == true {
                    isDataLoading = true
                    self.getProfessionalDahboardApi()
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if listArray[indexPath.row].isQualified == 1 && tableView == tblView{
            
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
            vc.postId = listArray[indexPath.row].id
            vc.controllerType = .isFromNotification
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}


struct DashboardModel{
    
    var id = ""
    var url = ""
    var thumbUrl = ""
    var totalLike:Int = 0
    var viewCount:Int = 0
    var isQualified = 1
    var isQualifiedReason = ""
    
    init(respDict:Dictionary<String, Any>){
        
        self.id = respDict["id"] as? String ?? ""
        self.url = respDict["url"] as? String ?? ""
        self.thumbUrl = respDict["thumbUrl"] as? String ?? ""
        self.totalLike = respDict["totalLike"] as? Int ?? 0
        self.viewCount = respDict["viewCount"] as? Int ?? 0
        self.isQualified = respDict["isQualified"] as? Int ?? 0
        self.isQualifiedReason = respDict["isQualifiedReason"] as? String ?? ""
    }
}




extension Date {

  func isEqualTo(_ date: Date) -> Bool {
    return self == date
  }
  
  func isGreaterThan(_ date: Date) -> Bool {
     return self > date
  }
  
  func isSmallerThan(_ date: Date) -> Bool {
     return self < date
  }
}



extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}




extension UIButton{
    
    func setUnderlineForButton( text: String, color: UIColor, fontSize: CGFloat,fontName:String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: color
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        self.setAttributedTitle(attributedText, for: .normal)
    }
}
