//
//  DeepOpenerManager.swift
//  The Wave
//
//  Created by Andrew Robinson on 12/27/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import Foundation
import Firebase

class DeepOpenerManager {

    static let manager = DeepOpenerManager()

    private var savedProductID: String?

    // MARK: - Input

    func handle(link url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }

        let parameters = components.path.split(separator: "/", maxSplits: 10, omittingEmptySubsequences: true)
        if let index = parameters.index(of: "product") {
            savedProductID = String(parameters[index + 1])
        } else {
            return false
        }

        return true
    }

    // MARK: - Openers

    func openSavedProductID() {
        if let id = savedProductID, let top = (UIApplication.shared.delegate as? AppDelegate)?.topViewController() {
            savedProductID = nil

            let ref = Database.database().reference().child("products").child(id)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? [String: AnyObject] {
                    if let product = Product.createProduct(with: value, with: snapshot.key) {
                        if let vc = ProductViewerViewController.vc {
                            vc.product = product
                            PresentationCenter.manager.present(viewController: vc, sender: top)
                        }
                    }
                }
            })
        }
    }

}
