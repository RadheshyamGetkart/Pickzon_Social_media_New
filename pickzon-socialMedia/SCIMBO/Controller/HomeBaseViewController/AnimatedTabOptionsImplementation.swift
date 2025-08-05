//
//  AnimatedTabOptionsImplementation.swift
//  TabTestApp
//
//  Created by Narek Simonyan on 10/31/20.
//

import UIKit


class DefaultTabAnimationOptions: NSVTabAnimationOptions {


    var mainAnimationDuration: Double = 0.5
    var options: UIView.AnimationOptions = [.curveEaseInOut, .allowUserInteraction]
    var usingSpringWithDamping: CGFloat = 0.7
    var initialSpringVelocity: CGFloat = 1
    var delay: Double = 0
    var tabMovePercentage: CGFloat? = 0.9
    var centerItemMovePercentage: CGFloat? = 0.2
    var subOptionsAnimationtype: SubOptionsAnimationType = .basic//.movingByOne(duration: 0.3, withScaling: true)
    var tabSelectionAnimationType: TabSelectionAnimationType = .none // .custom(duration: 0.3, animation: [.transitionFlipFromLeft])
    var shouldAnimateScreenChanges: Bool = false
     
}

class DefaultTabItemOptions: NSVTabItemOptions {
    var badgeString: String?
    

    var title: String?
    var image: UIImage?
    var selectedImage: UIImage?
    var itemInsets: UIEdgeInsets
    var spacing: CGFloat?
    var font: UIFont?

    init(title: String?, image: UIImage?, selectedImage: UIImage? = nil, itemInsets: UIEdgeInsets = .init(top: 3, left: 3, bottom: 3, right: 3), spacing: CGFloat? = 2, font: UIFont? = UIFont.systemFont(ofSize: 13)) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage ?? image
        self.itemInsets = itemInsets
        self.spacing = spacing
        self.font = font
    }
}

class DefaultCenterItemOptions: NSVCenterItemOptions {

    var size: CGSize = .init(width: 35, height: 35)
    var subOptionsSize: CGSize = .init(width: 40, height: 40)
    //var insets: UIEdgeInsets = .init(top: 20, left: 5, bottom: 10, right: 5)
    var insets: UIEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
    var options: NSVTabItemOptions = DefaultTabItemOptions(title: nil, image: UIImage(named: "plusGrey"), selectedImage: UIImage(named: "addBlue"), itemInsets: .init(top: 0, left: 8, bottom: 0, right: 8), spacing: 2, font: nil)
//    var options: NSVTabItemOptions = DefaultTabItemOptions(title: nil, image: UIImage(named: "addBlue"), selectedImage: UIImage(named: "addBlue")!, itemInsets: .init(top: 10, left: 10, bottom: 10, right: 10), spacing: 2, font: nil)
    var subOptions: [NSCenterItemSubOptions] = [
//        DefaultCenterItemSubOptions(image: UIImage(named: "mallWhite")!, backgroundColor: .white, cornerRadius: 25),
//        DefaultCenterItemSubOptions(image: UIImage(named: "mallWhite")!, backgroundColor: .white, cornerRadius: 25),
//        DefaultCenterItemSubOptions(image: UIImage(named: "mallWhite")!, backgroundColor: .white, cornerRadius: 25)
    ]
    var itemInsets:  UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
    var backgroundColor: UIColor = .clear
    //var cornerRadius: CGFloat = 25
    var cornerRadius: CGFloat = 0
   // var shadowInfo: ShadowInfo? = ShadowInfo(shadowRadius: 1, shadowOpacity: 1, shadowColor: UIColor.black.withAlphaComponent(0.15), shadowOffset: .zero)
    var shadowInfo: ShadowInfo? = nil
//    var distributionType: SubOptionsDistributionType = .custom(itemsSpacing: 0, minYOffset: 0, maxYOffset: 60)
    var distributionType: SubOptionsDistributionType = .custom(itemsSpacing: 0, minYOffset: 0, maxYOffset: 0)

    //var curveType: CurveType = .bottom
    
    var curveType: CurveType = .none
  
    
//    func updateSizeToSmaller(){
//        self.size = .init(width: 35, height: 35)
//        self.subOptionsSize = .init(width: 25, height: 25)
//        self.cornerRadius = 17.5
//    }
//    
    func updateSizeToSize(){
        self.size = .init(width: 35, height: 35)
        self.subOptionsSize = .init(width: 45, height: 45)
       // self.cornerRadius = 27.5
        self.cornerRadius = 0.0
    }

}

class DefaultCenterItemSubOptions: NSCenterItemSubOptions {
    
    var image: UIImage
    var backgroundColor: UIColor
    var cornerRadius: CGFloat
    var shadowInfo: ShadowInfo? = ShadowInfo(shadowRadius: 1, shadowOpacity: 1, shadowColor: UIColor.black.withAlphaComponent(0.15), shadowOffset: .zero)

    public init(image: UIImage, backgroundColor: UIColor, cornerRadius: CGFloat) {
        self.image = image
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
}

class DefaultAnimatedTabOptions: NSVAnimatedTabOptions {
    
    
    var tabHeight: CGFloat = 0
    var tabInsets: UIEdgeInsets = .zero
    var tabBackgroundColor: UIColor = .systemBackground
    var selectedItemColor: UIColor = .black
    var unselectedItemColor: UIColor = .systemBlue
    var cornerRadius: CGFloat = 5
    var corners: [RadiusCorners] = [.topLeft, .topRight]
    var shadowInfo: ShadowInfo? = ShadowInfo(shadowRadius: 5, shadowOpacity: 0.05, shadowColor: .black, shadowOffset: .init(width: 0, height: -5))
   
     var options: [NSVTabItemOptions] = [
        DefaultTabItemOptions(title: "", image: UIImage(named: "feed"),selectedImage: UIImage(named: "FeedBlue"), itemInsets: .init(top: 20, left: 5, bottom: 0, right: 5)),
        DefaultTabItemOptions(title: "", image: UIImage(named: "goLiveTab")!,selectedImage: UIImage(named: "goLiveTabSel"), itemInsets: .init(top: 20, left: -5, bottom: 0, right: 15)),

       /* DefaultTabItemOptions(title: "Pages", image: UIImage(named: "PagesUnselect")!,selectedImage: UIImage(named: "pagesSelect"), itemInsets: .init(top: 8, left: 5, bottom: 5, right: 5)),*/
    DefaultTabItemOptions(title: "", image: UIImage(named: "clipIcon"),selectedImage: UIImage(named: "clipSelColor"), itemInsets: .init(top: 20, left: 15, bottom: 0, right: -5)),
        /*  DefaultTabItemOptions(title: "Notification", image: UIImage(named: "notificationUnSelect")!,selectedImage: UIImage(named: "notificationSelect"), itemInsets: .init(top: 8, left: 0, bottom: 5, right: 0)),*/
     /* DefaultTabItemOptions(title: "Jobs", image: UIImage(named: "uim_bag")!,selectedImage: UIImage(named: "uim_bag_selected"), itemInsets: .init(top: 8, left: 0, bottom: 5, right: 0)),*/
       // DefaultTabItemOptions(title: "More", image: UIImage(named: "moreGreen")!.imageWithColor(color1: .systemBlue),selectedImage: UIImage(named: "MoreBlue"), itemInsets: .init(top: 5, left: 5, bottom: 5, right: 5))
        DefaultTabItemOptions(title: "", image: UIImage(named: "searchTab"),selectedImage: UIImage(named: "searchTabSelected"), itemInsets: .init(top: 20, left: 5, bottom: 0, right: 5))
    ]
    var animationOptions: NSVTabAnimationOptions = DefaultTabAnimationOptions()
    var centerItemOptions: NSVCenterItemOptions = DefaultCenterItemOptions()
    var coverAlpha: CGFloat = 0.1
    var mainBackgroundColor: UIColor? =  nil
    
    init(tabHeight:CGFloat){
        self.tabHeight = tabHeight
        if (UIDevice().hasNotch){
            (self.centerItemOptions as! DefaultCenterItemOptions).updateSizeToSize()
        }
    }
     
     
//     func updateCenterTo(isSmall:Bool = false){
//         
//         if isSmall{
//             (self.centerItemOptions as! DefaultCenterItemOptions).updateSizeToSmaller()
//         }else{
//             (self.centerItemOptions as! DefaultCenterItemOptions).updateSizeToSize()
//         }
//     }
    
}

extension UIImage {
    
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
