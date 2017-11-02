//
//  SlidingSelectionTabBarController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/28/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase

class SlidingSelectionTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var selectionBar: UIView?
    
    private var interactionViews: [UIView]?
    
    private var shadowLayer: CALayer!
    
    private var isViewingAddOptions = false
    private var backgroundCover: UIView!
    private var socialButton: UIButton!
    private var socialLabel: UILabel!
    private var productButton: UIButton!
    private var productLabel: UILabel!
    private var plusButton: UIButton!
    
    private var animator: UIDynamicAnimator!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = UIColor.black
        delegate = self
                
        shadowLayer = CALayer()
        shadowLayer.frame = CGRect(x: -tabBar.frame.width / 2.0, y: tabBar.frame.origin.y, width: 2 * tabBar.frame.size.width, height: 10.0)
        shadowLayer.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.1647058824, blue: 0.2117647059, alpha: 1).cgColor
        shadowLayer.shadowRadius = 5.0
        shadowLayer.shadowColor = #colorLiteral(red: 0.02352941176, green: 0.04705882353, blue: 0.09019607843, alpha: 1).cgColor
        shadowLayer.shadowOpacity = 0.25
        
        tabBar.superview!.layer.insertSublayer(shadowLayer, at: 1)
        
        if let items = tabBar.items {
            items[2].image = #imageLiteral(resourceName: "NewPostTabBarIcon").withRenderingMode(.alwaysOriginal)
            
            for item in tabBar.items! {
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
                item.image = item.image?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(openChatTab(notification:)), name: NSNotification.Name(rawValue: openChatControllerNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchToHomeTab(notification:)), name: NSNotification.Name(rawValue: logoutNotificationKey), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        interactionViews = tabBar.subviews.filter({$0.isUserInteractionEnabled})
        
        if selectionBar == nil {
            
            if let views = interactionViews {
                
                let circle = UIView()
                circle.isUserInteractionEnabled = false
                circle.frame = CGRect(x: views[2].frame.midX, y: views[2].frame.midY, width: 0, height: 0)
                circle.backgroundColor = .waveRed
                circle.roundCorners()
                circle.alpha = 0.0
                tabBar.insertSubview(circle, belowSubview: views[2])
                
                selectionBar = UIView()
                selectionBar!.frame = CGRect(x: tabBar.frame.width, y: tabBar.frame.height - 2, width: views[0].frame.width, height: 2)
                selectionBar!.backgroundColor = .waveRed
                selectionBar!.isUserInteractionEnabled = false
                selectionBar!.alpha = 0.0
                tabBar.insertSubview(selectionBar!, belowSubview: circle)
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.selectionBar!.alpha = 1.0
                    self.selectionBar!.frame = CGRect(x: 0, y: views[0].frame.origin.y + views[0].frame.height - 2, width: views[0].frame.width, height: 2)
                    
                    let size = views[2].frame.height + 15
                    
                    circle.frame = CGRect(x: views[2].frame.midX - size / 2,
                                          y: views[2].frame.midY - size / 2,
                                          width: size,
                                          height: size)
                    
                    circle.roundCorners()
                    circle.alpha = 1.0
                })
                
            }
        }
        
    }
    
    // MARK: - Tab Bar overrides
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        let index = tabBar.items!.index(of: item)
        
        if index != 2 && Auth.auth().currentUser != nil {
            if let views = interactionViews {
                let selectedFrame = views[index!].frame
                
                UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
                    self.selectionBar!.frame = CGRect(x: selectedFrame.origin.x, y: selectedFrame.height - 1, width: self.selectionBar!.frame.width, height: self.selectionBar!.frame.height)
                }, completion: nil)
            }
        }
    }
    
    // MARK: - Tab bar controller delegates
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        var shouldSelect = false
        
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "SignInUp", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SignInUpPrompt")
            vc.modalPresentationStyle = .overCurrentContext
            
            present(vc, animated: false, completion: nil)
        } else if viewController.title == "addNewPostTabBarViewController" {
            if !isViewingAddOptions {
                createAndDisplayAddButtons()
            } else {
                dismissAddButtons()
            }
        } else {
            shouldSelect = true
            
            if isViewingAddOptions {
                dismissAddButtons()
            }
        }
        
        return shouldSelect
    }
    
    // MARK: - Show/hide shadow layer
    
    func showShadow() {
        shadowLayer.isHidden = false
    }
    
    func hideShadow() {
        shadowLayer.isHidden = true
    }
    
    // MARK: - Notifications
    
    @objc private func openChatTab(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String: String] {
            if childViewControllers.count >= 1 {
                if let navBar = childViewControllers[1] as? UINavigationController {
                    if navBar.childViewControllers.count >= 1 {
                        if let conversationVC = navBar.childViewControllers[0] as? ChatConversationViewController {
                            let conversation = Conversation(id: "",
                                                            otherPersonId: userInfo["productOwnerID"]!,
                                                            otherPersonName: userInfo["productOwnerName"]!,
                                                            productID: userInfo["productID"]!)
                            
                            if let preMessage = userInfo["preformattedMessage"] {
                                conversation.firstMessage = preMessage
                            }
                            
                            conversationVC.newConversation = conversation

                            selectedIndex = 1
                            
                            // Move selection bar
                            if let views = interactionViews {
                                let selectedFrame = views[1].frame
                                UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
                                    self.selectionBar!.frame = CGRect(x: selectedFrame.origin.x, y: selectedFrame.height - 1, width: self.selectionBar!.frame.width, height: self.selectionBar!.frame.height)
                                }, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func switchToHomeTab(notification: NSNotification) {
        selectedIndex = 0
        
        // Move selection bar
        if let views = interactionViews {
            let selectedFrame = views[0].frame
            UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
                self.selectionBar!.frame = CGRect(x: selectedFrame.origin.x, y: selectedFrame.height - 1, width: self.selectionBar!.frame.width, height: self.selectionBar!.frame.height)
            }, completion: nil)
        }
    }
    
    // MARK: - Actions
    
    @objc private func openProductPost() {
        dismissAddButtons()
        
        let postVc = PriceChooseViewController()
        present(ImageSelectorViewController(vcToPresentAfterUpload: postVc), animated: true, completion: nil)
    }
    
    @objc private func openSocialPost() {
        dismissAddButtons()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "uploadSocialPostViewController")
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Add Buttons
    
    private func createAndDisplayAddButtons() {
        
        isViewingAddOptions = true
        
        if let vc = selectedViewController {
            backgroundCover = UIView()
            backgroundCover.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.1647058824, blue: 0.2117647059, alpha: 0.98)
            backgroundCover.frame = CGRect(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.height)
            backgroundCover.alpha = 0.0
            vc.view.addSubview(backgroundCover)

            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAddButtons))
            backgroundCover.addGestureRecognizer(tap)
        }
        
        if let views = interactionViews {
            let middleButtonFrame = tabBar.convert(views[2].frame, to: view)
            let middleButtonCenter = tabBar.convert(views[2].center, to: view)
            
            
            plusButton = UIButton()
            plusButton.frame = middleButtonFrame
            plusButton.center = middleButtonCenter
            plusButton.alpha = 1.0
            plusButton.addTarget(self, action: #selector(dismissAddButtons), for: .touchUpInside)
            plusButton.backgroundColor = .clear
            view.insertSubview(plusButton, aboveSubview: views[2])
            
            socialButton = UIButton()
            socialButton.frame = CGRect(x: middleButtonFrame.origin.x, y: middleButtonFrame.origin.y, width: 60, height: 60)
            socialButton.alpha = 0.0
            socialButton.setImage(#imageLiteral(resourceName: "NewPostSocial"), for: .normal)
            socialButton.addTarget(self, action: #selector(openSocialPost), for: .touchUpInside)
            socialButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
            view.insertSubview(socialButton, belowSubview: tabBar)
            
            socialLabel = UILabel()
            socialLabel.text = "Show off your Jeep!"
            socialLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
            socialLabel.textColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
            socialLabel.textAlignment = .center
            socialLabel.frame = CGRect(x: 0, y: 0, width: 240, height: 20)
            socialLabel.center = CGPoint(x: views[2].center.x - middleButtonFrame.width, y: middleButtonFrame.origin.y - 2.0 * middleButtonFrame.height + 40)
            socialLabel.alpha = 0.0
            view.insertSubview(socialLabel, belowSubview: tabBar)
            
            productButton = UIButton()
            productButton.frame = CGRect(x: middleButtonFrame.origin.x, y: middleButtonFrame.origin.y, width: 60, height: 60)
            productButton.alpha = 0.0
            productButton.setImage(#imageLiteral(resourceName: "NewPostProduct"), for: .normal)
            productButton.addTarget(self, action: #selector(openProductPost), for: .touchUpInside)
            view.insertSubview(productButton, belowSubview: tabBar)
            
            productLabel = UILabel()
            productLabel.text = "Sell product"
            productLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
            productLabel.textColor = .waveGreen
            productLabel.textAlignment = .center
            productLabel.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
            productLabel.center = CGPoint(x: views[2].center.x + middleButtonFrame.width, y: middleButtonFrame.origin.y - 2.0 * middleButtonFrame.height + 40)
            productLabel.alpha = 0.0
            view.insertSubview(productLabel, belowSubview: tabBar)
            
            animator = UIDynamicAnimator()
            
            let leftPoint = CGPoint(x: views[2].center.x - middleButtonFrame.width, y: middleButtonFrame.origin.y - 2.0 * middleButtonFrame.height)
            let leftSnap = UISnapBehavior(item: socialButton, snapTo: leftPoint)
            leftSnap.damping = 1.0
            
            let rightPoint = CGPoint(x: views[2].center.x + middleButtonFrame.width, y: middleButtonFrame.origin.y - 2.0 * middleButtonFrame.height)
            let rightSnap = UISnapBehavior(item: productButton, snapTo: rightPoint)
            rightSnap.damping = 1.0
            
            animator.addBehavior(leftSnap)
            animator.addBehavior(rightSnap)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.socialButton.alpha = 1.0
                self.productButton.alpha = 1.0
                
                self.backgroundCover.alpha = 1.0
                
                self.socialButton.transform = CGAffineTransform(rotationAngle: 0.0)
                views[2].transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            }, completion: { done in
                UIView.animate(withDuration: 0.25, animations: {
                    self.socialLabel.alpha = 1.0
                    self.productLabel.alpha = 1.0
                })
            })
        }
        
    }
    
    @objc private func dismissAddButtons() {
        isViewingAddOptions = false
        animator.removeAllBehaviors()
        
        if let views = interactionViews {
            plusButton.removeFromSuperview()
            let convertedPoint = tabBar.convert(views[2].center, to: view)
            let point = CGPoint(x: convertedPoint.x, y: convertedPoint.y)
            
            let leftSnap = UISnapBehavior(item: socialButton, snapTo: point)
            leftSnap.damping = 1.0
            
            let rightSnap = UISnapBehavior(item: productButton, snapTo: point)
            rightSnap.damping = 1.0
            
            animator.addBehavior(leftSnap)
            animator.addBehavior(rightSnap)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundCover.alpha = 0.0
                
                self.socialButton.alpha = 0.0
                self.socialLabel.alpha = 0.0
                
                self.productButton.alpha = 0.0
                self.productLabel.alpha = 0.0
                
                views[2].transform = CGAffineTransform(rotationAngle: 0.0)
            }, completion: { done in
                self.backgroundCover.removeFromSuperview()
                
                self.socialButton.removeFromSuperview()
                self.socialLabel.removeFromSuperview()
                
                self.productButton.removeFromSuperview()
                self.productLabel.removeFromSuperview()
            })
            
        }
        
    }

}
