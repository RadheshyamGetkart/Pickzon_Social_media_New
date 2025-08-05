//
//  Navigator.swift
//  Coravida
//
//  Created by Sachtech on 08/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//

import Foundation
import UIKit

extension SwiftBaseViewController {

    func changeRootViewController<T>(storyBoardIdentifier: String = "Main") -> T where T: UIViewController {

        return delegate.changeRootViewController(storyBoardIdentifier: storyBoardIdentifier)

    }
    func changeRootViewControllerWithAnimation<T>(storyBoardIdentifier: String = "Main") -> T where T: UIViewController {

        return delegate.changeRootWithAnim(storyBoardIdentifier: storyBoardIdentifier)
    }

    func open<T>(_ storyBoardIdentifier: String = "Main",_ animate: Bool = true,_ attacher: (T) -> Void = {_ in } ) -> T where T: UIViewController{
        return navigationController!.open(storyBoardIdentifier: storyBoardIdentifier, animate: animate, attacher)
    }
 
    func customPresent<T>(storyBoardIdentifier: String = "Main",animate: Bool = true,_ attacher: (T) -> Void = {_ in } ) -> T where T: UIViewController{
        
        let destVc: T
        destVc = instantiateViewController(storyBoardIdentifier: storyBoardIdentifier)
        
        destVc.modalPresentationStyle = .overCurrentContext
        destVc.modalTransitionStyle = .coverVertical
        attacher(destVc)
        self.present(destVc, animated: animate, completion: nil)
        return destVc
    }
    
    private func instantiateViewController<T>(storyBoardIdentifier: String) -> T{

        return delegate.instantiateViewController(storyBoardIdentifier: storyBoardIdentifier)
    }
}

extension UINavigationController {

    func transparentNavBar(){
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor(named: "Gradient1")
        self.navigationBar.isTranslucent = true
    }

    func open<T>(storyBoardIdentifier: String = "Main",animate: Bool = true,_ attacher: (T) -> Void = {_ in } ) -> T where T: UIViewController{

        var destVc: T

        let controller =  viewControllers.first(where: ({$0 is T}))

        if(controller ==  nil) {
            destVc = instantiateViewController(storyBoardIdentifier: storyBoardIdentifier)

            
            attacher(destVc)
            pushViewController(destVc, animated: animate)
        }else {

            destVc = controller as! T
            
            attacher(destVc)
            popToViewController(controller!, animated: true)
        }
        return destVc
    }

    private func instantiateViewController<T>(storyBoardIdentifier: String) -> T{

        return AppDelegate.sharedInstance.instantiateViewController(storyBoardIdentifier: storyBoardIdentifier)

    }

}

extension AppDelegate {

    func changeRootWithAnim<T>(storyBoardIdentifier: String = "Main") -> T where T: UIViewController{
        
        let vc : T = instantiateViewController(storyBoardIdentifier: storyBoardIdentifier)
       // vc.viewDidLayoutSubviews()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.setRootViewController(vc, options: .init(direction: .fade, style: .easeOut))
        return vc
    }
    func changeRootViewController<T>(storyBoardIdentifier: String = "Main") -> T where T: UIViewController {

        let vc : T = instantiateViewController(storyBoardIdentifier: storyBoardIdentifier)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        appDelegate.window?.rootViewController = UINavigationController(rootViewController: vc)

        return vc
    }

    fileprivate func instantiateViewController<T>(storyBoardIdentifier: String) -> T{

        let vcId = String(describing:  T.self)
        let board = storyBord(withIdentifier: storyBoardIdentifier)
        return board.instantiateViewController(withIdentifier: vcId) as! T

    }

    func storyBord(withIdentifier: String) -> UIStoryboard{
        return UIStoryboard(name: withIdentifier, bundle: nil)
    }

}

extension UINavigationController{
    func fadeInOutViewController(_ push:Bool,_ vc:UIViewController){
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
        self.view.layer.add(transition, forKey: nil)
        if push{
            self.pushViewController(vc, animated: false)
        }
        else{
            self.popToViewController(vc, animated: false)
        }
    }
    func setVCwithAnim(_ vc:UIViewController){
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
        self.view.layer.add(transition, forKey: nil)
        viewControllers = [vc]
    }

}
