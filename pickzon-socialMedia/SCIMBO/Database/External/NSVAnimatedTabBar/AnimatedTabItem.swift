//
//  AnimatedTabItem.swift
//  TabTestApp
//
//  Created by Narek Simonyan on 10/29/20.
//

import UIKit

public class AnimatedTabItem: ShadowView {

    private let stackContainerView = BackgroundStackView(frame: .zero)
    private let imageView = UIImageView(frame: .zero)
   // private let titleLabel = UILabel(frame: .zero)
    private var animationType: TabSelectionAnimationType?
    let badgebtn = MIBadgeButton(frame: .zero)

    private var options: NSVTabItemOptions?

    var onTap: (() -> Void)?

    @objc private func handleTap() {
        onTap?()
    }
    
    var onLongPressed : ((_ sender: UILongPressGestureRecognizer) -> Void)?
    @objc private func handleLongPressed(sender: UILongPressGestureRecognizer) {
        onLongPressed?(sender)
    }

    
    
    private func addTapGesture() {
        isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(gesture)
        
        //add long press gesture, set to start after 0.2 seconds
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:  #selector(handleLongPressed(sender:)))
            //longPressRecognizer.minimumPressDuration = 0.2
            addGestureRecognizer(longPressRecognizer)
    }

    private func configureSubviews() {
        stackContainerView.axis = .vertical
        stackContainerView.isLayoutMarginsRelativeArrangement = true
        stackContainerView.insetsLayoutMarginsFromSafeArea = false
       // titleLabel.textAlignment = .center
        badgebtn.titleLabel?.textAlignment = .center
        badgebtn.titleLabel?.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        //titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        imageView.contentMode =  .center
        containerView.addArrangedSubview(stackContainerView)
        badgebtn.isUserInteractionEnabled = false
        badgebtn.badgeBackgroundColor = .red
        badgebtn.badgeTextColor = .white
       // badgebtn.badgeString = ""
       // badgebtn.edgeInsetLeft = 20
    }

    func set(cornerRadius: CGFloat, shadowInfo: ShadowInfo?) {
        self.cornerRadius = cornerRadius
        self.shadowInfo = shadowInfo
    }

    func configure(with options: NSVTabItemOptions, animationType: TabSelectionAnimationType) {
        self.animationType = animationType
        self.options = options
        configureSubviews()
        stackContainerView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: options.itemInsets.top, leading: options.itemInsets.left, bottom: options.itemInsets.bottom, trailing: options.itemInsets.right)
        if let image = options.image {
            stackContainerView.addArrangedSubview(imageView)
            imageView.image = image
        }
        if let title = options.title, let font = options.font {
//            stackContainerView.addArrangedSubview(titleLabel)
//            titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
//            titleLabel.font = font
//            titleLabel.text = title
            
            stackContainerView.addArrangedSubview(badgebtn)
            badgebtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
            badgebtn.titleLabel?.font  = font
           // badgebtn.titleLabel?.text = title
            self.badgebtn.setTitle(title, for: .normal)
        }
        stackContainerView.spacing = options.spacing ?? 0
        addTapGesture()
    }

    func select(color: UIColor) {
        animate(image: options?.selectedImage, color: color)
    }

    func unselect(color: UIColor) {
        animate(image: options?.image, color: color)
    }

    private func animate(image: UIImage?, color: UIColor) {
        switch animationType {
        case .custom(let duration, let options):
            UIView.transition(with: imageView,
                              duration: duration,
                              options: options,
                              animations: {
                                self.imageView.image = image
                                self.imageView.tintColor = color
                              },
                              completion: nil)
            UIView.transition(with: badgebtn,
                              duration: duration,
                              options: options,
                              animations: {
//                                self.titleLabel.textColor = color
                self.badgebtn.setTitleColor(color, for: .normal)

                              },
                              completion: nil)
        default:
           // titleLabel.textColor = color
           // self.badgebtn.titleLabel?.textColor = color
            self.badgebtn.setTitleColor(color, for: .normal)

            imageView.image = image
            imageView.tintColor = color
        }
    }
}
