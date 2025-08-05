//
//  FilterBoostVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/4/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import FSCalendar

protocol FilterDateDelegate{
    func filterSelectedDate(date1:String,date2:String,lastDays:Int)
}

enum DaysSelectedType{
    case days7
    case days14
    case days28
    case customDate
}

class FilterBoostVC: UIViewController {
    
    @IBOutlet weak var cnstrntLeading:NSLayoutConstraint!
    @IBOutlet weak var cnstrntTrailing:NSLayoutConstraint!

    
    @IBOutlet weak var btnPostCategory:UIButton!
    @IBOutlet weak var btn7Days:UIButton!
    @IBOutlet weak var btn14Days:UIButton!
    @IBOutlet weak var btn28Days:UIButton!
    @IBOutlet weak var btnCustom:UIButton!

    var delegate:FilterDateDelegate?
    
    var fromDate = ""
    var toDate = ""
    var isFromSelected = true
    var isMoreDataAvailable = true
    var calendar:FSCalendar?
    var dateFormatter:DateFormatter?
    var date1:Date?
    var date2: Date?
    var gregorian:NSCalendar?
    var filterSelectionType:DaysSelectedType?
    
    @IBOutlet weak var calenDarBgVw: UIView!
    @IBOutlet weak var btnSelectDate: UIButton!
    @IBOutlet weak var lblDateAndTime: UILabel!
    @IBOutlet weak var btnCloseCalendar: UIButton!
    @IBOutlet weak var calenDarView: UIView!
    
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        self.view.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
        
       // self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnView)))
        
        cornerradius(color: .lightGray, cornerRadius: 5.0, btn: btnPostCategory)
        calenDarBgVw.isHidden = true
        setUpcalendar()
    }
    
    func cornerradius(color:UIColor,cornerRadius:CGFloat,btn:UIButton){
        
        btn.layer.borderColor = color.cgColor
        btn.layer.borderWidth = 1.0
        btn.layer.cornerRadius = 5.0
        btn.clipsToBounds = true
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
    
    @objc func tapOnView(){
        self.dismissView(animated: true)
    }
    
    //MARK: UIButton action methods
    
    @IBAction func closeCalendarButtonActionMethod(_ sender:UIButton){
        
        calenDarBgVw.isHidden = true
        tapOnView()
        
    }

    @IBAction func selectButtonActionMethod(_ sender:UIButton){
        
        
        if date1 != nil && date2 != nil {
           
            calenDarBgVw.isHidden = true
            self.dateFormatter?.dateFormat = "YYYY/MM/dd"
            if let d1 = self.dateFormatter?.string(from: date1!){
                  fromDate = d1
            }
            
            if let d2 = self.dateFormatter?.string(from: date2!){
                toDate = d2
            }
            let diffInDays = Calendar.current.dateComponents([.day], from: self.date1!, to: self.date2!).day ?? 1
            self.delegate?.filterSelectedDate(date1: fromDate, date2: toDate, lastDays: diffInDays)
            tapOnView()
           
        }else{
            self.view.makeToast(message:"Please select Date range", duration: 3, position: HRToastActivityPositionDefault)

        }
        
    }

    
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        tapOnView()
    }
    
    @IBAction func last7DaysBtnAction(_ sender: UIButton) {
        
        filterSelectionType = .days7
        cornerradius(color: .lightGray, cornerRadius: 5.0, btn: btn7Days)
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btn14Days)
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btn28Days)
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btnCustom)
    }
    
    @IBAction func last14DaysBtnAction(_ sender: UIButton) {
      
        filterSelectionType = .days14
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btn7Days)
        cornerradius(color: .lightGray, cornerRadius: 5.0, btn: btn14Days)
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btn28Days)
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btnCustom)
    }
    
    @IBAction func last28DaysBtnAction(_ sender: UIButton) {
        
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btn7Days)
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btn14Days)
        cornerradius(color: .lightGray, cornerRadius: 5.0, btn: btn28Days)
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btnCustom)
     
        filterSelectionType = .days28
    }
    
    
  
    @IBAction func customBtnAction(_ sender: UIButton) {
        calenDarBgVw.isHidden = false
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btn7Days)
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btn14Days)
        cornerradius(color: .clear, cornerRadius: 5.0, btn: btn28Days)
        cornerradius(color: .lightGray, cornerRadius: 5.0, btn: btnCustom)
        filterSelectionType = .customDate
    }
    
    @IBAction func applyBtnAction(_ sender: UIButton) {
        
        if filterSelectionType == .days7{
            
            let day7 = Date().dateBeforeOrAfterFromToday(numberOfDays: -7)
            self.delegate?.filterSelectedDate(date1: day7.getDateFormat(formatString: "yyyy/MM/dd"), date2: Date().getDateFormat(formatString: "yyyy/MM/dd"),lastDays:7)
            
        }else if filterSelectionType == .days14{
            
            let day14 = Date().dateBeforeOrAfterFromToday(numberOfDays: -14)
            self.delegate?.filterSelectedDate(date1: day14.getDateFormat(formatString: "yyyy/MM/dd"), date2: Date().getDateFormat(formatString: "yyyy/MM/dd"),lastDays:14)
            
        }else if filterSelectionType == .days28{
            
            let day28 = Date().dateBeforeOrAfterFromToday(numberOfDays: -28)
            self.delegate?.filterSelectedDate(date1: day28.getDateFormat(formatString: "yyyy/MM/dd"), date2: Date().getDateFormat(formatString: "yyyy/MM/dd"),lastDays:28)
            
        }else if filterSelectionType == .customDate{
            
        }
        tapOnView()
    }
    
    //MARK:
}


extension FilterBoostVC:FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance{
   
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



extension Date {

    func dateBeforeOrAfterFromToday(numberOfDays :Int?) -> Date {

        let resultDate = Calendar.current.date(byAdding: .day, value: numberOfDays!, to: Date())!
        return resultDate
    }
    
    
    func getDateFormat(formatString:String) ->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        return dateFormatter.string(from: self)
    }
}
