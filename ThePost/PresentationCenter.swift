//
//  PresentationCenter.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/18/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class PresentationCenter: NSObject {
    
    static let manager = PresentationCenter()
    
    private var stack: [ModalPresentationViewController] = []
    
    func present(viewController vc: ModalPresentationViewController, sender: UIViewController) {
        if stack.count == 0 {
            stack.append(vc)
            sender.present(vc, animated: false, completion: nil)
        } else {
            let previousIndex = stack.count - 1
            stack.append(vc)
            
            vc.shouldAnimateBackgroundColor = false
            
            let previousVc = stack[previousIndex]
            let previousFrame = previousVc.modalContainer.frame
            
            previousVc.modalContainer.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                previousVc.modalContainer.frame = CGRect(x: previousFrame.origin.x + 10, y: previousFrame.origin.y - 10, width: previousFrame.width - 20, height: previousFrame.height - 20)
                previousVc.modalContainer.layoutIfNeeded()
            })
            
            sender.present(vc, animated: false, completion: nil)
        }
    }
    
    func popPresentationStack() {
        if stack.count > 0 {
            stack.removeLast()
            
            if let last = stack.last {
                let currentTopStackVc = last
                let currentFrame = currentTopStackVc.modalContainer.frame
                
                currentTopStackVc.modalContainer.layoutIfNeeded()
                UIView.animate(withDuration: 0.25, animations: {
                    currentTopStackVc.modalContainer.frame = CGRect(x: currentFrame.origin.x - 10, y: currentFrame.origin.y + 10, width: currentFrame.width + 20, height: currentFrame.height + 20)
                    currentTopStackVc.modalContainer.layoutIfNeeded()
                })
            }
        }
    }
    
}
