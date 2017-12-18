//
//  FilterViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 12/17/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var radiusView: UIView!

    @IBOutlet weak var sliderView: SelectionSliderView! {
        didSet {
            sliderView.delegate = self
        }
    }
    
    @IBOutlet weak var mileageSlider: UISlider!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var mileageContainer: UIView!

    private var sliderItems = [JeepModel.wranglerJK.shortDescription,
                               JeepModel.wranglerTJ.shortDescription,
                               JeepModel.wranglerYJ.shortDescription,
                               JeepModel.cherokeeCJ.shortDescription,
                               JeepModel.cherokeeXJ.shortDescription,
                               "All"]

    private var filter: Filter

    // MARK: - Init

    init(with filter: Filter) {
        self.filter = filter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .waveDarkBlue
        
        radiusView.roundCorners()
        modelImageView.image = Jeep(withType: filter.model).image

        mileageSlider.minimumTrackTintColor = .waveBrightRed
        mileageSlider.maximumTrackTintColor = .white
        mileageSlider.thumbTintColor = .waveBrightRed
        mileageSlider.maximumValue = Float(filter.maximumRadius)
        mileageSlider.minimumValue = Float(filter.minimumRadius)
        mileageSlider.value = Float(filter.radius)
        mileageSlider.addTarget(self, action: #selector(sliderValueChange(slider:)), for: .valueChanged)

        mileageLabel.textColor = .white
        mileageLabel.text = milesString()
        mileageContainer.backgroundColor = .clear
        mileageContainer.roundCorners(radius: 10.0)
        mileageContainer.addBorder(withWidth: 2.0, color: .white)
    }

    // MARK: - Actions

    @IBAction func doneButtonPressed(_ sender: BigRedShadowButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func sliderValueChange(slider: UISlider) {
        filter.radius = Int(slider.value)
        mileageLabel.text = milesString()
    }

    // MARK: - Helpers

    private func milesString() -> String  {
        if filter.radius == 1 {
            return "\(filter.radius) mile"
        } else {
            return "\(filter.radius) miles"
        }
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
        modelImageView.image = Jeep(withType: filter.model).image
    }
}
