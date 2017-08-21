//
//  JeepTypeView.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/3/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

protocol JeepTypeViewDelegate {
    func didTap(_ view: JeepTypeView)
}

class JeepTypeView: UIView {

    @IBOutlet private var jeepTypeImageView: UIImageView!
    @IBOutlet private var jeepLabel: UILabel!

    var delegate: JeepTypeViewDelegate?
    var selected = false {
        didSet {
            updateState()
        }
    }
    var type: JeepModel! {
        didSet {
            image = Jeep(withType: type).image
            jeepLabel.text = type.shortDescription
        }
    }

    private var image: UIImage? {
        didSet {
            jeepTypeImageView.image = image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        roundCorners(radius: 8.0)

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSelected))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)

        updateState()
    }

    @objc func toggleSelected() {
        if !selected {
            selected = !selected
            delegate?.didTap(self)
        }
    }

    private func updateState() {
        if selected {
            backgroundColor = .waveRed
            jeepTypeImageView.tintColor = .white
            jeepLabel.textColor = .white
        } else {
            backgroundColor = .white
            jeepTypeImageView.tintColor = #colorLiteral(red: 0.168627451, green: 0.1921568627, blue: 0.2352941176, alpha: 1)
            jeepLabel.textColor = #colorLiteral(red: 0.168627451, green: 0.1921568627, blue: 0.2352941176, alpha: 1)
        }
    }

}
