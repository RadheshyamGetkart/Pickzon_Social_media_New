//
//  ExtensionClass.swift
//  SCIMBO
//
//  Created by Getkart on 07/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit
import Photos


//MARK: NSAttributedString
extension NSAttributedString {
    
    internal convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }
        
        guard let attributedString = try? NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString: attributedString)
    }
}

//MARK: URL
extension URL{
   
  
    
    func getVideoSize() -> CGSize? {
        let asset = AVAsset(url: self)
        guard let track = asset.tracks(withMediaType: .video).first else {
            return nil // No video track found
        }
        
        let naturalSize = track.naturalSize
        let orientation = track.preferredTransform
        
        // Apply transformation to obtain the actual size
        let transformedSize = naturalSize.applying(orientation)
        
        var width = transformedSize.width
        var height = transformedSize.height
        
        
         if width < 0 || height < 0 {
             width = width < 0 ? width * -1 : width
             height = height < 0 ? height * -1 : height
         }

        // Swap width and height if needed (landscape vs. portrait)
        let videoSize = CGSize(width: Int(width),
                               height: Int(height))
        print("\nvideoSize===\(videoSize)")
        return videoSize
    }
    
    func drawPDFfromURL() -> UIImage? {
        guard let document = CGPDFDocument(self as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }

        return img
    }
}


//MARK: UIBUTton
extension UIButton{
    
    func setGradientColork(colorLeft:UIColor,colorRight:UIColor,titleColor:UIColor,cornerRadious:CGFloat,image:String,title:String){
       
        //let colorLeft = UIColor(red: 13.0/255.0, green: 107.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        //let colorRight = UIColor(red: 21.0/255.0, green: 178.0/255.0, blue: 254.0/255.0, alpha: 1.0).cgColor
        let gradientLayerColor4 = CAGradientLayer()
        gradientLayerColor4.colors = [colorLeft.cgColor, colorRight.cgColor]
        gradientLayerColor4.locations = [0.0, 1.0]
        gradientLayerColor4.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayerColor4.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayerColor4.frame = self.bounds
   
        self.layer.insertSublayer(gradientLayerColor4, at:0)
        self.setTitleColor(titleColor, for: .normal)
        if image.length > 0{
           // self.setImage(UIImage(named:image), for: .normal)
            self.bringSubviewToFront(self.imageView!)
        }
        if title.length > 0{
            self.setTitle(title, for: .normal)
        }
        self.layer.cornerRadius = cornerRadious
        self.clipsToBounds = true
    }
    
    
    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = color
    }
    
    func setAttributedText(firstText:String,firstcolor:UIColor,seconText:String,secondColor:UIColor) -> Void {
        
        let firstfont:UIFont = UIFont.systemFont(ofSize: 14)
        let boldFont:UIFont = UIFont.systemFont(ofSize: 16)
        
        //Making dictionaries of fonts that will be passed as an attribute
        let firstDict:NSDictionary = NSDictionary(object: firstcolor, forKey:
                                                    NSAttributedString.Key.foregroundColor as NSCopying)
        
        let boldDict:NSDictionary = NSDictionary(object: secondColor, forKey:
                                                    NSAttributedString.Key.foregroundColor as NSCopying)
        
        
        let attributedString = NSMutableAttributedString(string: firstText,
                                                         attributes: firstDict as? [NSAttributedString.Key : Any])
        
        let boldString = NSMutableAttributedString(string:seconText,
                                                   attributes:boldDict as? [NSAttributedString.Key : Any])
        attributedString.append(NSMutableAttributedString(string:" ",
                                                          attributes:boldDict as? [NSAttributedString.Key : Any]))
        attributedString.append(boldString)
        
        self.setAttributedTitle(attributedString, for: .normal)
        
    }
}


//MARK: UILABEL
extension UILabel{
    
    func setAttributedPlaceHolder(frstText:String,color:UIColor,secondText:String,secondColor:UIColor) -> Void {
       
        
//        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
//        let myAttribute1 = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
        
        // Initialize with a string only
        let attrStar = NSAttributedString(string: secondText, attributes: [NSAttributedString.Key.foregroundColor: secondColor])
        
        // Initialize with a string and inline attribute(s)
        let attrString2 = NSAttributedString(string: frstText, attributes: [NSAttributedString.Key.foregroundColor: color])
        
        
        let attr1: NSMutableAttributedString = NSMutableAttributedString()
        attr1.append(attrString2)
        attr1.append(attrStar)
        self.attributedText = attr1
        
       
    }
    
    func setAttributedText(firstText:String,firstcolor:UIColor,seconText:String,secondColor:UIColor,isBold:Bool = true) -> Void {
        
        let firstfont:UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let boldFont:UIFont = (isBold) ? UIFont.systemFont(ofSize: 16, weight: .semibold) : UIFont.systemFont(ofSize: 16, weight: .regular)
        
        let firstDict:NSDictionary = [ NSAttributedString.Key.foregroundColor : firstcolor,NSAttributedString.Key.font:firstfont]
        
        let boldDict:NSDictionary =  [ NSAttributedString.Key.foregroundColor:secondColor,NSAttributedString.Key.font:boldFont]
        
        let attributedString = NSMutableAttributedString(string: firstText,
                                                         attributes: firstDict as? [NSAttributedString.Key : Any])
        
        let boldString = NSMutableAttributedString(string:seconText,
                                                   attributes:boldDict as? [NSAttributedString.Key : Any])
        attributedString.append(NSMutableAttributedString(string:" ",
                                                          attributes:boldDict as? [NSAttributedString.Key : Any]))
        attributedString.append(boldString)
        self.attributedText = attributedString
    }

    
    func setAttributedText(firstText:String,firstcolor:UIColor,seconText:String,secondColor:UIColor,firstFont:UIFont,secondFont:UIFont) -> Void {
   
        
        let firstDict:NSDictionary = [ NSAttributedString.Key.foregroundColor : firstcolor,NSAttributedString.Key.font:firstFont]
        
        let boldDict:NSDictionary =  [ NSAttributedString.Key.foregroundColor:secondColor,NSAttributedString.Key.font:secondFont]
        
        let attributedString = NSMutableAttributedString(string: firstText,
                                                         attributes: firstDict as? [NSAttributedString.Key : Any])
        
        let boldString = NSMutableAttributedString(string:seconText,
                                                   attributes:boldDict as? [NSAttributedString.Key : Any])
        attributedString.append(NSMutableAttributedString(string:" ",
                                                          attributes:boldDict as? [NSAttributedString.Key : Any]))
        attributedString.append(boldString)
        self.attributedText = attributedString
    }
    
}

//MARK: UIVIew
extension UIView {
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

//MARK: UIDatepicker
extension UIDatePicker {
    func setYearValidation(year:Int) {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -year
        let maxDate: Date = calendar.date(byAdding: components, to: currentDate)!
        components.year = -150
        let minDate: Date = calendar.date(byAdding: components, to: currentDate)!
        self.minimumDate = minDate
        self.maximumDate = maxDate
    } }



//MARK: UICollectionView
extension UICollectionView {
    
    func reloadWithoutAnimation()
    {
        UIView.setAnimationsEnabled(false)
        self.reloadData()
        UIView.setAnimationsEnabled(true)
    }
    
    
    public func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0.0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }
}

//MARK: UITableview


extension UITableView {
    
    func reloadAnimately(_ completion: @escaping ()->()) {
        
        UIView.transition(with: self,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations:
                            { () -> Void in
            self.reloadData()
        }, completion: nil);
    }
    
    
    public var boundsWithoutInset: CGRect {
        var boundsWithoutInset = bounds
        boundsWithoutInset.origin.y += contentInset.top
        boundsWithoutInset.size.height -= contentInset.top + contentInset.bottom
        return boundsWithoutInset
    }
    
    public func isRowCompletelyVisible(at indexPath: IndexPath) -> Bool {
        
        
        guard let lastIndexPath = indexPathsForVisibleRows?.first else {
            return false
        }
        return lastIndexPath == indexPath
        
        // return boundsWithoutInset.contains(rectForRow(at: indexPath))
    }
    
    func reloadWithoutAnimation()
    {
        UIView.setAnimationsEnabled(false)
        self.reloadData()
        UIView.setAnimationsEnabled(true)
    }
    
    
    public func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0.0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }
    
    func scroll(to: scrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }
    
    enum scrollsTo {
        case top,bottom
    }
}

//MARK: UIDevice
extension UIDevice {
    /// Returns `true` if the device has a notch
    var hasDeviceNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        if UIDevice.current.orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}

//MARK: UIViewcontroller
extension UIViewController{
    
    var getNavBarHt:CGFloat  {
        //        print("\(UIApplication.shared.statusBarFrame.size.height)==topBarHeight==\((self.navigationController?.navigationBar.frame.height ?? 0.0))" )
        
        return   UIApplication.shared.statusBarFrame.size.height +
        (self.navigationController?.navigationBar.frame.height ?? 0.0) + 5
        
    }
    
    func downloadAllMedia(urlArray:Array<String>){
        
        var indexCount = 1
        
        for videoImageUrl in urlArray {
            print(videoImageUrl)
            DispatchQueue.global(qos: .background).async {
                if let url = URL(string: videoImageUrl), let urlData = NSData(contentsOf: url) {
                    let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let fileName = url.lastPathComponent
                    let filePath="\(galleryPath)/\(Int(Date().timeIntervalSince1970))\(fileName)"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            
                            if checkMediaTypes(strUrl:videoImageUrl) == 1{
                                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL:
                                                                                        URL(fileURLWithPath: filePath))
                            }else {
                                
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:
                                                                                        URL(fileURLWithPath: filePath))
                            }
                            
                            if indexCount == urlArray.count {
                                DispatchQueue.main.async {
                                    
                                    self.view?.makeToast(message: "Downloaded successfully" , duration: 2, position: HRToastActivityPositionDefault)
                                }
                            }
                            
                            indexCount = indexCount + 1
                            
                            
                        }) {
                            
                            success, error in
                            if success {
                                print("Succesfully Saved")
                                
                                if FileManager.default.fileExists(atPath: filePath) {
                                    // delete file
                                    do {
                                        try FileManager.default.removeItem(atPath: filePath)
                                    } catch {
                                        print("Could not delete file, probably read-only filesystem")
                                    }
                                }
                                
                            } else {
                                print(error?.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
}

//MARK: String
extension String {
    
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var utf8String:UnsafePointer<Int8>? {
        return (self as NSString).utf8String
    }
    
    func decode() -> String? {
        let data = self.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
    
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
    
    
    
    func validateUrl () -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
          let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
          let result = urlTest.evaluate(with: self.lowercased())
           return result
          }
    
    
    func convertAttributtedColorText(isCenter:Bool = false,linkAndMentionColor:UIColor = Themes.sharedInstance.tagAndLinkColor() ) -> NSAttributedString{
        
     
        
        let  originalStr = self
        var att = NSMutableAttributedString(string: originalStr)
       
        if isCenter{
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            att = NSMutableAttributedString(string: originalStr,
                                            attributes: [ NSAttributedString.Key.paragraphStyle: style])
        }
  
        
        // let detectorType: NSTextCheckingResult.CheckingType = [.address, .phoneNumber, .link]
        let detectorType: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        
        let mentionPattern = "\\B@[A-Za-z0-9_]+"
        let mentionRegex = try? NSRegularExpression(pattern: mentionPattern, options: [.caseInsensitive])
        let mentionMatches  = mentionRegex?.matches(in: originalStr, options: [], range: NSMakeRange(0, originalStr.utf16.count))
        
        for result in mentionMatches! {
            if let range1 = Range(result.range, in: originalStr) {
                let matchResult = originalStr[range1]
                
                if matchResult.count > 0  {
                    //                    att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor(),NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 18.0)], range: result.range)
                    att.addAttributes([NSAttributedString.Key.foregroundColor:linkAndMentionColor], range: result.range)
                }
            }
        }
        
        let hashtagPattern = "#[^\\s!@#\\$%^&*()=+.\\/,\\[{\\]};:'\"?><]+" // "(^|\\s)#([A-Za-z_][A-Za-z0-9_]*)"
        let regex = try? NSRegularExpression(pattern: hashtagPattern, options: [.caseInsensitive])
        let matches  = regex?.matches(in: originalStr, options: [], range: NSMakeRange(0, originalStr.utf16.count))
        
        for result in matches! {
            if let range1 = Range(result.range, in: originalStr) {
                let matchResult = originalStr[range1]
                
                if matchResult.count > 0  {
                    att.addAttributes([NSAttributedString.Key.foregroundColor:linkAndMentionColor], range: result.range)
                }
            }
        }
        
        do {
            let detector = try NSDataDetector(types: detectorType.rawValue)
            let results = detector.matches(in: originalStr, options: [], range: NSRange(location: 0, length:
                                                                                            originalStr.utf16.count))
            for result in results {
                if let range1 = Range(result.range, in: originalStr) {
                    let matchResult = originalStr[range1]
                    
                    if matchResult.count > 0  {
                        att.addAttributes([NSAttributedString.Key.foregroundColor:linkAndMentionColor], range: result.range)
                    }
                }
            }
        } catch {
            print("handle error")
        }
        return att
    }
    
}



//MARK: UITEXtview

extension UITextView {
    /// Returns the current word that the cursor is at.
    func currentWord() -> String {
        guard let cursorRange = self.selectedTextRange else { return "" }
        func getRange(from position: UITextPosition, offset: Int) -> UITextRange? {
            guard let newPosition = self.position(from: position, offset: offset) else { return nil }
            return self.textRange(from: newPosition, to: position)
        }
    
        var wordStartPosition: UITextPosition = self.beginningOfDocument
        var wordEndPosition: UITextPosition = self.endOfDocument
    
        var position = cursorRange.start
    
        while let range = getRange(from: position, offset: -1), let text = self.text(in: range) {
            if text == " " || text == "\n" {
                wordStartPosition = range.end
                break
            }
            position = range.start
        }
    
        position = cursorRange.start
    
        while let range = getRange(from: position, offset: 1), let text = self.text(in: range) {
            if text == " " || text == "\n" {
                wordEndPosition = range.start
                break
            }
            position = range.end
        }
    
        guard let wordRange = self.textRange(from: wordStartPosition, to: wordEndPosition) else { return "" }
    
        return self.text(in: wordRange) ?? ""
    }
}

//MARK: UIIMage
extension UIImage {
    func blurred(radius: CGFloat) -> UIImage {
        let ciContext = CIContext(options: nil)
        guard let cgImage = cgImage else { return self }
        let inputImage = CIImage(cgImage: cgImage)
        guard let ciFilter = CIFilter(name: "CIGaussianBlur") else { return self }
        ciFilter.setValue(inputImage, forKey: kCIInputImageKey)
        ciFilter.setValue(radius, forKey: "inputRadius")
        guard let resultImage = ciFilter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let cgImage2 = ciContext.createCGImage(resultImage, from: inputImage.extent) else { return self }
        return UIImage(cgImage: cgImage2)
    }
    
        func averageNewColor() -> UIColor? {
            guard let cgImage = cgImage else { return nil }
            
            let width = cgImage.width
            let height = cgImage.height
            
            let bytesPerPixel = 4 // Assuming 8-bit RGBA channels
            let bytesPerRow = bytesPerPixel * width
            let totalBytes = bytesPerRow * height
            
            guard let pixelData = CGDataProvider(data: cgImage.dataProvider!.data! as CFData)?.data else { return nil }
            let data = UnsafePointer<UInt8>(CFDataGetBytePtr(pixelData))
            
            var totalRed: UInt32 = 0
            var totalGreen: UInt32 = 0
            var totalBlue: UInt32 = 0
            
            for row in 0 ..< height {
                for column in 0 ..< width {
                    let pixelOffset = (row * bytesPerRow) + (column * bytesPerPixel)
                    let red = UInt32(data![pixelOffset])
                    let green = UInt32(data![pixelOffset + 1])
                    let blue = UInt32(data![pixelOffset + 2])
                    
                    totalRed += red
                    totalGreen += green
                    totalBlue += blue
                }
            }
            
            let pixelCount = width * height
            let averageRed = totalRed / UInt32(pixelCount)
            let averageGreen = totalGreen / UInt32(pixelCount)
            let averageBlue = totalBlue / UInt32(pixelCount)
            
            return UIColor(
                red: CGFloat(averageRed) / 255.0,
                green: CGFloat(averageGreen) / 255.0,
                blue: CGFloat(averageBlue) / 255.0,
                alpha: 1.0
            )
        }
    

    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
            return nil
        }
    }
    
    var getAverageColour: UIColor? {
            //A CIImage object is the image data you want to process.
            guard let inputImage = CIImage(image: self) else { return nil }
            // A CIVector object representing the rectangular region of inputImage .
            let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
            
            guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
            guard let outputImage = filter.outputImage else { return nil }

            var bitmap = [UInt8](repeating: 0, count: 4)
            let context = CIContext(options: [.workingColorSpace: kCFNull])
        
             context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        

       
            return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
       
        }
}

//MARK: Removing saved media files while uploading
extension Array{
    
    func removeSavedURLFiles(){
        
        for url in self{
            do {
                
                if let urls = url as? URL{
                    if FileManager.default.fileExists(atPath: (urls.path)) {
                        try FileManager.default.removeItem(at: urls)
                        print(" Image DEleted")
                    }
                    
                }
            } catch let err as NSError {
                print("Not able to remove\(err)")
            }
        }
    }
}


//MARK: - UIApplication Extension
extension UIApplication {
   
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
  
    var statusBarUIView: UIView? {
      if #available(iOS 13.0, *) {
          let tag = 38482
          let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

          if let statusBar = keyWindow?.viewWithTag(tag) {
              return statusBar
          } else {
              guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
              let statusBarView = UIView(frame: statusBarFrame)
              statusBarView.tag = tag
              keyWindow?.addSubview(statusBarView)
              return statusBarView
          }
      } else if responds(to: Selector(("statusBar"))) {
          return value(forKey: "statusBar") as? UIView
      } else {
          return nil
      }
    }
}

//MARK:- Date Extension
extension Date{
    
    static var timeStamp: Int64{
        return Int64(Date().timeIntervalSince1970)
    }
    
    func toMonthNameFormatWithTime()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy hh:mm a"
        return formatter.string(from: self)
    }
    
    
    func toDDMMYYY()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        return formatter.string(from: self)
    }
    
    func toMMDDYYYY() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        return formatter.string(from: self)
    }
    
    func toDDMMYYYTime()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return formatter.string(from: self)
    }
    
    func toDDMMYYYYAndTime()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
    func toMMDD()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM.dd"
        return formatter.string(from: self)
    }
    
    func toHHMMA() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = .autoupdatingCurrent
        formatter.timeZone = NSTimeZone.local
        return formatter.string(from: self)
    }
    
    func offsetFrom() -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: self, to: Date());
        var seconds: String = ""
        var minutes: String = ""
        var hours: String = ""
        var days: String = ""
        
        if difference.second ?? 0 == 1{
            seconds = "\(difference.second ?? 0) sec ago"
        }else{
            seconds = "\(difference.second ?? 0) secs ago"
        }
        if difference.minute ?? 0 == 1{
            minutes = "\(difference.minute ?? 0) min ago"
        }else{
            minutes = "\(difference.minute ?? 0) mins ago"
        }
        if difference.hour ?? 0 == 1{
            hours = "\(difference.hour ?? 0) hour ago"
        }else{
            hours = "\(difference.hour ?? 0) hours ago"
        }
    
        if difference.day ?? 0 == 1{
            days = "Yesterday"
            //days = "\(difference.day ?? 0) day ago"
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let getDate = dateFormatter.string(from: self)
            days = getDate
            //days = "\(difference.day ?? 0) days ago"
        }
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
    
    func getDayTime() -> String{
        let calender = Calendar.current
        var date = ""
        if calender.isDateInToday(self){
            date = "Today"
        }else if calender.isDateInYesterday(self){
            date = "Yesterday"
        }
        else{
            date = self.toDDMMYYY()
        }
        
        return date + " | " + self.toHHMMA()
    }
    
    func dateAddOnDay(_ days: Int) -> Date{
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}

//MARK:- String Extension
extension String{
    
    
    func toMonthNameFormatWithTime()->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy hh:mm a"
        let newDate = formatter.date(from: self) ?? Date()
        return newDate
    }

    func toDateFormatDate()->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let newDate = formatter.date(from: self) ?? Date()
        return newDate
    }
    
    
    func toDate()->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let newDate = formatter.date(from: self) ?? Date()
        return newDate
    }
    
    func toDDMMYYYY()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let newDate = formatter.date(from: self) ?? Date()
        return newDate.toDDMMYYY()
    }

    func toMMMDD()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let newDate = formatter.date(from: self) ?? Date()
        return newDate.toMMDD()
    }
    
    var boolValue: Bool {
        return self == "1" ? true : false
    }
    
    func base64Encoded() -> String{
        let stringData = self.data(using: .utf8) ?? Data()
        let encodedStr = stringData.base64EncodedString()
        return encodedStr
    }
    func base64Decoded() -> String{
        let data = Data(base64Encoded: self) ?? Data()
        let decodedStr = String(data: data, encoding: .utf8) ?? ""
        return decodedStr
    }

    var toData: Data?{
        return Data(base64Encoded: self)
    }
    
    func dateTimeStatus() -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        let newDdate = dateFormatter.date(from: self)!
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter1.locale = .autoupdatingCurrent
        dateFormatter1.timeZone = NSTimeZone.local
        let dateString = dateFormatter1.string(from: newDdate)
        
        let convDate = dateFormatter1.date(from: dateString) ?? Date()
        
        return convDate.toDDMMYYY()
    }
}

//MARK:- UIImage Extension
extension UIImage {
    
  
    
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: - Image Scaling.
    
    /// Represents a scaling mode
    enum ScalingMode {
        case aspectFill
        case aspectFit
        
        /// Calculates the aspect ratio between two sizes
        ///
        /// - parameters:
        ///     - size:      the first size used to calculate the ratio
        ///     - otherSize: the second size used to calculate the ratio
        ///
        /// - return: the aspect ratio between the two sizes
        func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
            let aspectWidth  = size.width/otherSize.width
            let aspectHeight = size.height/otherSize.height
            
            switch self {
            case .aspectFill:
                return max(aspectWidth, aspectHeight)
            case .aspectFit:
                return min(aspectWidth, aspectHeight)
            }
        }
    }
    
    /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
    ///
    /// - parameter:
    ///     - newSize:     the size of the bounds the image must fit within.
    ///     - scalingMode: the desired scaling mode
    ///
    /// - returns: a new scaled image.
    func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFill) -> UIImage {
        
        let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
        
        /* Build the rectangle representing the area to be drawn */
        var scaledImageRect = CGRect.zero
        
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y    = (newSize.height - size.height * aspectRatio) / 2.0
        
        /* Draw and retrieve the scaled image */
        UIGraphicsBeginImageContext(newSize)
        
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
}

//MARK:- Double Extension
extension Double{
    func timestampToDate() -> Date{
        let date = Date(timeIntervalSince1970: self)
        return date
    }
    
    func toMinSec() -> String{
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
}

extension Int64{
    func timestampToDate() -> Date{
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return date
    }
    func calculateDataSize() -> String{
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useBytes,.useKB,.useMB,.useGB]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self))
        return string
    }
    func convertSecondsToTimeFormats(format: String = "TTT") -> String{
        let days = Int64(self) / 86400
        let hours = Int64(self) % 86400 / 3600
        let minutes = Int64(self) / 60 % 60
        let seconds = Int64(self) % 60
        var stringArr = ""
        if days != 0{
            stringArr = days == 1 ? "\(days) Day" : "\(days) Days"
        }
        else if hours != 0{
            stringArr = hours == 1 ? "\(hours) Hour" : "\(hours) Hours"
        }
        else if minutes != 0{
            stringArr = minutes == 1 ? "\(minutes) Minute" : "\(minutes) Minutes"
        }
        else if seconds != 0{
            stringArr = seconds == 1 ? "\(seconds) Second" : "\(seconds) Seconds"
        }else{
             stringArr = "Off"
        }
        if format == "T"{
            let strArr = stringArr.split(separator: " ")
            if strArr.count > 1{
                let num = String(strArr[0])
                var day = String(strArr[1].prefix(1))
                day = day == "D" ? day : day.lowercased()
                let dayArr = [num,day]
                return dayArr.joined(separator: " ")
            }else{
               return stringArr
            }
        }else{
            return stringArr
        }
    }
}

extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
    var stringValue: String {
        return self ? "true" : "false"
    }
    
    var numStringValue: String{
       return self ? "1" : "0"
    }
}

extension UIView{
    
    
    func addShadowToView(corner:CGFloat,shadowColor:UIColor,shadowRadius:CGFloat,shadowOpacity:Float){
        
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = corner
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
    }
    
    
    func addBlurEffect(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}

extension URL {
    func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).last {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}


extension Int {
    var boolValue: Bool {
        return self != 0
    }
}

extension Data{
    var toString: String{
        return self.base64EncodedString()//String(bytes: self, encoding: .utf8) ?? ""
    }
}


//MARK: UITextfield
extension  UITextField {
        
    func addLeftPadding() -> Void {

        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.leftView = leftPaddingVw
        self.leftViewMode = .always

    }
    
    
    
    
    func addRightPadding() -> Void {

        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.rightView = leftPaddingVw
        self.leftViewMode = .always

    }
    
    
    func addRightPaddingWithValue(paddingValue:Int = 50) -> Void {

        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: paddingValue, height: paddingValue)
        self.rightView = leftPaddingVw
        self.rightViewMode = .always

    }
    
    
    func addRightIconToTextFieldWithImg(iconName:NSString) -> Void {

        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.leftView = leftPaddingVw
        self.leftViewMode = .always

        let rightPaddingVw = UIView()
        rightPaddingVw.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        self.rightView = rightPaddingVw
        self.rightViewMode = .always


        let rightIconImg = UIImageView()
        rightIconImg.frame = CGRect(x:10,y:15,width:20,height:20)
        if iconName.length > 0{
        rightIconImg.image = UIImage(imageLiteralResourceName: iconName as String)
        }
        rightIconImg.contentMode = .scaleAspectFit
        rightPaddingVw.addSubview(rightIconImg)


    }
    
    func addLeftIconToTextFieldWithImg(iconName:NSString) -> Void {
        
        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        self.leftView = leftPaddingVw
        self.leftViewMode = .always
        
        let rightPaddingVw = UIView()
        rightPaddingVw.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.rightView = rightPaddingVw
        self.rightViewMode = .always
        
        
        let rightIconImg = UIImageView()
        rightIconImg.frame = CGRect(x:10,y:15,width:20,height:20)
        if iconName.length > 0{
            rightIconImg.image = UIImage(imageLiteralResourceName: iconName as String)
        }
        rightIconImg.contentMode = .scaleAspectFit
        leftPaddingVw.addSubview(rightIconImg)
        
        
    }
    
    func setAttributedPlaceHolder(text:String,color:UIColor) -> Void {
       
        self.attributedPlaceholder = NSAttributedString(string: text,
                                                                       attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func setAttributedPlaceHolder(frstText:String,color:UIColor,secondText:String,secondColor:UIColor) -> Void {
       
        
//        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
//        let myAttribute1 = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
        
        // Initialize with a string only
        let attrStar = NSAttributedString(string: secondText, attributes: [NSAttributedString.Key.foregroundColor: secondColor])
        
        // Initialize with a string and inline attribute(s)
        let attrString2 = NSAttributedString(string: frstText, attributes: [NSAttributedString.Key.foregroundColor: color])
        
        
        let attr1: NSMutableAttributedString = NSMutableAttributedString()
        attr1.append(attrString2)
        attr1.append(attrStar)
        self.attributedPlaceholder = attr1
        
       
    }
    
    
}

//MARK: UIIMageview

extension UIImageView{
    
    func setImageViewTintColor(color: UIColor)  {
        let templateImage =  self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}





// As an extension
extension Int {
    var asFormatted_k_String: String {
        let num = abs(Double(self))
        let sign = self < 0 ? "-" : ""

        switch num {
        case 1_000_000_000...:
            return "\(sign)\((num / 1_000_000_000).reduceScale(to: 1))B".replacingOccurrences(of: ".0", with: "")
        case 1_000_000...:
            return "\(sign)\((num / 1_000_000).reduceScale(to: 1))M".replacingOccurrences(of: ".0", with: "")
        case 1_000...:
            return "\(sign)\((num / 1_000).reduceScale(to: 1))K".replacingOccurrences(of: ".0", with: "")
        case 0...:
            return "\(self)"
        default:
            return "\(sign)\(self)"
        }
    }
}

extension UInt {
    var asFormatted_k_String: String {
        let num = abs(Double(self))
        
        let sign = self < 0 ? "-" : ""

        switch num {
        case 1_000_000_000...:
            return "\(sign)\((num / 1_000_000_000).reduceScale(to: 1))B".replacingOccurrences(of: ".0", with: "")
        case 1_000_000...:
            return "\(sign)\((num / 1_000_000).reduceScale(to: 1))M".replacingOccurrences(of: ".0", with: "")
        case 1_000...:
            return "\(sign)\((num / 1_000).reduceScale(to: 1))K".replacingOccurrences(of: ".0", with: "")
        case 0...:
            return "\(self)"
        default:
            return "\(sign)\(self)"
        }
    }
}


extension Int16{
    
    var asFormatted_k_String: String {
        let num = abs(Double(self))
        let sign = self < 0 ? "-" : ""

        switch num {
        case 1_000_000_000...:
            return "\(sign)\((num / 1_000_000_000).reduceScale(to: 1))B".replacingOccurrences(of: ".0", with: "")
        case 1_000_000...:
            return "\(sign)\((num / 1_000_000).reduceScale(to: 1))M".replacingOccurrences(of: ".0", with: "")
        case 1_000...:
            
            return "\(sign)\((num / 1_000).reduceScale(to: 1))K".replacingOccurrences(of: ".0", with: "")
        case 0...:
            return "\(self)"
        default:
            return "\(sign)\(self)"
        }
    }
}


extension Int64{
    
    var asFormatted_k_String: String {
        let num = abs(Double(self))
        let sign = self < 0 ? "-" : ""

        switch num {
        case 1_000_000_000...:
            return "\(sign)\((num / 1_000_000_000).reduceScale(to: 1))B".replacingOccurrences(of: ".0", with: "")
        case 1_000_000...:
            return "\(sign)\((num / 1_000_000).reduceScale(to: 1))M".replacingOccurrences(of: ".0", with: "")
        case 1_000...:
            return "\(sign)\((num / 1_000).reduceScale(to: 1))K".replacingOccurrences(of: ".0", with: "")
        case 0...:
            return "\(self)"
        default:
            return "\(sign)\(self)"
        }
    }
}



extension Double {
     func reduceScale(to places: Int) -> Double {
        var multiplier = pow(10, Double(places))
        var newDecimal = (multiplier * self).rounded() // move the decimal right
        var truncated = Double(Int(newDecimal)) // drop the fraction
        var originalDecimal = (truncated / multiplier) // move the decimal back
         return originalDecimal
    }
}





extension String{
    
    func trim() -> String {
        let replaced = String(self.filter {$0 != " "})
        return replaced
        
    }
   
}


extension UIView {

    func roundSelectedCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
    }
    
    func roundGivenCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}
