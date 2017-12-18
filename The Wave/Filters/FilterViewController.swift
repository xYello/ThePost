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

    private var filter: Filter

    init(with filter: Filter) {
        self.filter = filter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        var string = filter.model.shortDescription
        if filter.model == .all { string = "All" }

        return sliderItems.index(of: string) ?? 0
    }

    func sliderSelectionDidUpdate(atIndex index: Int) {
        filter.model = JeepModel.enumFrom(shortDescription: sliderItems[index])
    }
}
