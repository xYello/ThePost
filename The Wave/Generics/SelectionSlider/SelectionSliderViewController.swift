//
//  SelectionSliderViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 12/17/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

@objc protocol SelectionSliderDelegate {
    func selectionSliderItems() -> [String]
    func sliderSelectionDidUpdate(atIndex index: Int)
    @objc optional func sliderInitialSelectionIndex() -> Int
}

private class SliderButton: UIButton {
    var index: Int!

    private let defaultFontSize: CGFloat = 18.0
    private var sliderSelected = true

    func create(text: String, index: Int) {
        self.index = index

        setTitle(text, for: .normal)
        sizeToFit()
        changeSelectedState()
        translatesAutoresizingMaskIntoConstraints = false
    }

    func changeSelectedState() {
        if sliderSelected {
            // Changing to unselected
            titleLabel?.font = UIFont(name: "Avenir-Light", size: defaultFontSize)
            setTitleColor(.white, for: .normal)
            alpha = 0.5
        } else {
            // Changing to selected
            titleLabel?.font = UIFont(name: "Avenir-Heavy", size: defaultFontSize)
            setTitleColor(.waveBrightRed, for: .normal)
            alpha = 1.0
        }

        sliderSelected = !sliderSelected
    }
}

private class SliderView: UIView {
    private let height: CGFloat = 1.0

    private var leftConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!

    func create(on button: SliderButton) {
        backgroundColor = .waveBrightRed

        translatesAutoresizingMaskIntoConstraints = false

        leftConstraint = leftAnchor.constraint(equalTo: button.leftAnchor)
        rightConstraint = rightAnchor.constraint(equalTo: button.rightAnchor)
        heightAnchor.constraint(equalToConstant: height).isActive = true
        bottomAnchor.constraint(equalTo: button.bottomAnchor).isActive = true

        leftConstraint.isActive = true
        rightConstraint.isActive = true
    }

    func moveTo(button: SliderButton) {
        superview?.removeConstraints([leftConstraint, rightConstraint])

        leftConstraint = leftAnchor.constraint(equalTo: button.leftAnchor)
        rightConstraint = rightAnchor.constraint(equalTo: button.rightAnchor)

        leftConstraint.isActive = true
        rightConstraint.isActive = true

        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
}

class SelectionSliderView: UIView {

    private let distanceBetween: CGFloat = 10.0

    var delegate: SelectionSliderDelegate?

    private var totalNumberOfItems: Int {
        get {
            return items?.count ?? 0
        }
    }

    private var items: [String]?

    private var lastSelectedButton: SliderButton?
    private var sliderView: SliderView?

    override func awakeFromNib() {
        super.awakeFromNib()

        items = delegate?.selectionSliderItems()

        backgroundColor = .clear

        if let items = items, totalNumberOfItems >= 2 {
            var initialButton: SliderButton?

            var leftMidButton = SliderButton()
            var rightMidButton = SliderButton()
            var isOdd = false
            if totalNumberOfItems % 2 == 0 {
                let leftMidIndex = totalNumberOfItems / 2 - 1
                let rightMidIndex = leftMidIndex + 1

                let leftButton = createButton(title: items[leftMidIndex], at: leftMidIndex)
                let leftMidConstraint = NSLayoutConstraint(item: leftButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: -distanceBetween / 2)

                let rightButton = createButton(title: items[rightMidIndex], at: rightMidIndex)
                let rightMidConstraint = NSLayoutConstraint(item: rightButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: distanceBetween / 2)
                addConstraints([leftMidConstraint, rightMidConstraint])

                if let initial = delegate?.sliderInitialSelectionIndex?() {
                    if leftMidIndex == initial { initialButton = leftButton }
                    else if rightMidIndex == initial { initialButton = rightButton }
                } else if leftMidIndex == 0 {
                    initialButton = leftButton
                }

                leftMidButton = leftButton
                rightMidButton = rightButton
            } else {
                isOdd = true

                let midIndex = totalNumberOfItems / 2
                let midButton = createButton(title: items[midIndex], at: midIndex)
                let midConstraint = NSLayoutConstraint(item: midButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                addConstraint(midConstraint)

                if let initial = delegate?.sliderInitialSelectionIndex?(), midIndex == initial {
                    initialButton = midButton
                }

                leftMidButton = midButton
                rightMidButton = midButton
            }

            // Left side buttons
            var lastLeftButton: SliderButton?
            let rightBound = isOdd ? totalNumberOfItems / 2 - 1 : totalNumberOfItems / 2 - 2
            for i in 0...rightBound {
                let index = rightBound - i
                let button = createButton(title: items[index], at: index)

                var constraint: NSLayoutConstraint
                if let last = lastLeftButton {
                    constraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: last, attribute: .left, multiplier: 1.0, constant: -distanceBetween)
                } else {
                    constraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: leftMidButton, attribute: .left, multiplier: 1.0, constant: -distanceBetween)
                }
                addConstraint(constraint)

                if let initial = delegate?.sliderInitialSelectionIndex?() {
                    if index == initial { initialButton = button }
                } else if index == 0 {
                    initialButton = button
                }

                lastLeftButton = button
            }

            // Right side buttons
            var lastRightButton: SliderButton?
            for i in totalNumberOfItems / 2 + 1...totalNumberOfItems - 1 {
                let button = createButton(title: items[i], at: i)

                var constraint: NSLayoutConstraint
                if let last = lastRightButton {
                    constraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: last, attribute: .right, multiplier: 1.0, constant: distanceBetween)
                } else {
                    constraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: rightMidButton, attribute: .right, multiplier: 1.0, constant: distanceBetween)
                }
                addConstraint(constraint)

                if let initial = delegate?.sliderInitialSelectionIndex?(), i == initial {
                    initialButton = button
                }

                lastRightButton = button
            }

            if let left = initialButton {
                left.changeSelectedState()
                lastSelectedButton = left

                sliderView = SliderView()
                addSubview(sliderView!)
                sliderView!.create(on: left)
            }
        }
    }

    @objc private func buttonPressed(button: SliderButton) {
        lastSelectedButton?.changeSelectedState()
        button.changeSelectedState()
        lastSelectedButton = button

        sliderView?.moveTo(button: button)

        delegate?.sliderSelectionDidUpdate(atIndex: button.index)
    }

    private func createButton(title: String, at index: Int) -> SliderButton {
        let button = SliderButton()
        button.create(text: title, index: index)
        button.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
        addSubview(button)

        let top = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        addConstraints([top, bottom])

        return button
    }

}
