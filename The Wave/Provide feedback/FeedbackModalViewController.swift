//
//  FeedbackModalViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 7/21/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase

class FeedbackModalViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var messageLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerMidConstraint: NSLayoutConstraint!

    private var animator: UIDynamicAnimator!

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        animator = UIDynamicAnimator()

        container.alpha = 0.0
        container.roundCorners(radius: 8.0)

        textView.delegate = self

        submitButton.roundCorners()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        view.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if container.alpha != 1.0 {
            let point = CGPoint(x: container.frame.midX, y: container.frame.midY)
            let snap = UISnapBehavior(item: container, snapTo: point)
            snap.damping = 1.0

            container.frame = CGRect(x: container.frame.origin.x + view.frame.width, y: -container.frame.origin.y - view.frame.height, width: container.frame.width, height: container.frame.height)
            container.alpha = 1.0

            animator.addBehavior(snap)

            UIView.animate(withDuration: 0.25, animations: {
                self.view.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.1647058824, blue: 0.2117647059, alpha: 0.8025639681)
            })
        }
    }

    // MARK: - Textview delegate

    func textViewDidBeginEditing(_ textView: UITextView) {
        messageLabelHeightConstraint.priority = 999
        textView.text = ""

        UIView.animate(withDuration: 0.25, animations: { self.view.layoutIfNeeded() })
    }

    // MARK: - Actions

    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if textView.text != "", textView.text != "Type here...", let uid = FIRAuth.auth()?.currentUser?.uid {
            let feedbackToSet = ["userID": uid,
                                 "message": textView.text] as [String: Any]

            let ref = FIRDatabase.database().reference().child("feedback").childByAutoId()
            ref.updateChildValues(feedbackToSet)

            textView.text = "Thanks for the feedback! Uploading now..."
            textView.isEditable = false
            textView.isSelectable = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.prepareForDismissal {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            prepareForDismissal {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Dismissal

    func prepareForDismissal(dismissCompletion: @escaping () -> Void) {
        animator.removeAllBehaviors()

        let gravity = UIGravityBehavior(items: [container])
        gravity.gravityDirection = CGVector(dx: 0.0, dy: 9.8)
        animator.addBehavior(gravity)

        let item = UIDynamicItemBehavior(items: [container])
        item.addAngularVelocity(-CGFloat.pi / 2, for: container)
        animator.addBehavior(item)

        UIView.animate(withDuration: 0.25, animations: {
            self.container.alpha = 0.0
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }, completion: { done in
            dismissCompletion()
        })
    }

    // MARK: - Helpers

    @objc private func tappedOnView() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()

            if textView.text == "" {
                textView.text = "Type here..."
            }
        } else {
            prepareForDismissal {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }

}
