//
//  FilterViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 12/17/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import DottedLineView

class FilterViewController: UIViewController {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var radiusView: UIView!
    @IBOutlet weak var radiusMileageLabel: UILabel!
    @IBOutlet weak var dottedView: DottedLineView!

    @IBOutlet weak var sliderView: SelectionSliderView! {
        didSet {
            sliderView.delegate = self
        }
    }
    
    @IBOutlet weak var mileageSlider: UISlider!
    @IBOutlet weak var maxMileageLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var mileageContainer: UIView!
    
    @IBOutlet weak var modelImageViewWidthConstraint: NSLayoutConstraint!

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
        radiusView.backgroundColor = #colorLiteral(red: 0.01647708192, green: 0.624725759, blue: 1, alpha: 1).withAlphaComponent(0.25)
        radiusView.addBorder(withWidth: 2.0, color: #colorLiteral(red: 0.01647708192, green: 0.624725759, blue: 1, alpha: 1))
        radiusMileageLabel.text = "\(filter.radius)"
        radiusMileageLabel.textColor = #colorLiteral(red: 0.01647708192, green: 0.624725759, blue: 1, alpha: 1)
        dottedView.lineColor = #colorLiteral(red: 0.01647708192, green: 0.624725759, blue: 1, alpha: 1)
        modelImageView.image = Jeep(withType: filter.model).image?.withRenderingMode(.alwaysTemplate)
        modelImageView.tintColor = .white
        modelLabel.textColor = .white

        var string = filter.model.shortDescription
        if filter.model == .all { string = "All" }
        modelLabel.text = string

        mileageSlider.minimumTrackTintColor = .waveBrightRed
        mileageSlider.maximumTrackTintColor = .white
        mileageSlider.thumbTintColor = .waveBrightRed
        mileageSlider.maximumValue = Float(filter.maximumRadius)
        mileageSlider.minimumValue = Float(filter.minimumRadius)
        mileageSlider.value = Float(filter.radius)
        mileageSlider.addTarget(self, action: #selector(sliderValueChange(slider:)), for: .valueChanged)

        modelImageViewWidthConstraint.constant = sizeOfModelImage(for: mileageSlider.value)
        radiusView.alpha = alphaOfRadius(for: mileageSlider.value)
        radiusMileageLabel.alpha = radiusView.alpha
        dottedView.alpha = radiusView.alpha
        dottedView.lineWidth = lineWidth(for: mileageSlider.value)

        mileageLabel.textColor = .white
        mileageLabel.text = milesString()
        maxMileageLabel.text = "\(filter.maximumRadius)"
        mileageContainer.backgroundColor = .clear
        mileageContainer.roundCorners(radius: 10.0)
        mileageContainer.addBorder(withWidth: 2.0, color: .white)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        radiusView.roundCorners()
    }

    // MARK: - Actions

    @IBAction func doneButtonPressed(_ sender: BigRedShadowButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func sliderValueChange(slider: UISlider) {
        filter.radius = Int(slider.value)
        mileageLabel.text = milesString()
        radiusMileageLabel.text = "\(filter.radius)"

        modelImageViewWidthConstraint.constant = sizeOfModelImage(for: slider.value)
        radiusView.alpha = alphaOfRadius(for: slider.value)
        radiusMileageLabel.alpha = radiusView.alpha
        dottedView.alpha = radiusView.alpha
        dottedView.lineWidth = lineWidth(for: slider.value)
        view.layoutIfNeeded()
    }

    // MARK: - Helpers

    private func milesString() -> String  {
        if filter.radius == 1 {
            return "\(filter.radius) mile"
        } else {
            return "\(filter.radius) miles"
        }
    }

    private func sizeOfModelImage(for value: Float) -> CGFloat {
        let multiple = 1 - radiusView.frame.width / view.frame.width
        if value >= Float(filter.maximumRadius / 5) {
            return CGFloat(150 - (value * Float(multiple)) - 10)
        }

        return 150 - CGFloat(filter.maximumRadius / 5) * multiple - 10
    }

    private func alphaOfRadius(for value: Float) -> CGFloat {
        if value <= Float(filter.maximumRadius / 6) {
            return CGFloat(value / Float(filter.maximumRadius / 6))
        }

        return 1.0
    }

    private func lineWidth(for value: Float) -> CGFloat {
        return 3.5
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
        modelLabel.text = sliderItems[index]

        filter.model = JeepModel.enumFrom(shortDescription: sliderItems[index])
        UIView.transition(with: modelImageView, duration: 0.25, options: .transitionFlipFromTop, animations: {
            self.modelImageView.image = Jeep(withType: self.filter.model).image?.withRenderingMode(.alwaysTemplate)
        }, completion: nil)
    }
}
