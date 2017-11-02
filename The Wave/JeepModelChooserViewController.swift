//
//  JeepModelChooserViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/3/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

protocol JeepModelChooserDelegate {
    func didChange(model: JeepModel)
}

class JeepModelChooserViewController: SeletectedImageViewController, JeepTypeViewDelegate {

    @IBOutlet var typeViews: [JeepTypeView]!
    
    private var product: Product!
    private var options = [JeepModel]()

    var delegate: JeepModelChooserDelegate?
    var selectedProduct: JeepModel?

    // MARK: - Init

    init(withProduct product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        options = [.wranglerJK,
                   .wranglerTJ,
                   .wranglerYJ,
                   .cherokeeCJ,
                   .cherokeeXJ,
                   .all]

        var i = 0
        for view in typeViews {
            view.type = options[i]
            view.delegate = self
            i += 1
        }

        if let model = selectedProduct {
            let index = options.index(of: model)
            typeViews[index!].selected = true
        } else if let currentlySelected = KeychainWrapper.standard.string(forKey: UserInfoKeys.UserSelectedJeep) {
            let model = JeepModel.enumFromString(string: currentlySelected)
            let index = options.index(of: model)
            typeViews[index!].selected = true
            product.jeepModel = model
        } else {
            typeViews.last!.selected = true
            product.jeepModel = typeViews.last!.type
        }
    }

    // MARK: - Actions

    @IBAction func nextButtonPressed(_ sender: BigRedShadowButton) {
        if let model = selectedProduct {
            product.jeepModel = model
        }

        if let delegate = delegate {
            delegate.didChange(model: product.jeepModel)
            dismiss(animated: true, completion: nil)
        } else {
            let vc = ProductExtraDetailsViewController(withProduct: product)
            vc.handler = handler
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func xButtonPressed(_ sender: UIButton) {
        if let _ = delegate {
            dismiss(animated: true, completion: nil)
        } else {
            handler.dismiss()
        }
    }

    // MARK: - JeepTypeView delegate

    func didTap(_ view: JeepTypeView) {
        selectedProduct = view.type
        for v in typeViews {
            if v.type != view.type {
                v.selected = false
            }
        }
    }

}
