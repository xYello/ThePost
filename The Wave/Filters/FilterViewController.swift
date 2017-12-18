//
//  FilterViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 12/17/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    @IBOutlet weak var sliderView: SelectionSliderView! {
        didSet {
            sliderView.delegate = self
        }
    }

    private var sliderItems = [JeepModel.wranglerJK.shortDescription,
                               JeepModel.wranglerTJ.shortDescription,
                               JeepModel.wranglerYJ.shortDescription,
                               JeepModel.cherokeeCJ.shortDescription,
                               JeepModel.cherokeeXJ.shortDescription,
                               "All"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .waveDarkBlue
    }

    // MARK: - Actions

    @IBAction func doneButtonPressed(_ sender: BigRedShadowButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension FilterViewController: SelectionSliderDelegate {
    func selectionSliderItems() -> [String] {
        return sliderItems
    }

    func sliderInitialSelectionIndex() -> Int {
        return 2
    }

    func sliderSelectionDidUpdate(atIndex index: Int) {
        //
    }
}
