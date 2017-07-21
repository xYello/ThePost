//
//  NewProductDropDownTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/29/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

enum PickerContentType {
    case jeep
    case condition
}

class NewProductDropDownTableViewCell: NewProductBaseTableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerType: PickerContentType = .jeep {
        didSet {
            generatePickerData()
            pickerView.reloadAllComponents()
        }
    }
    
    private var data: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        generatePickerData()
        
        contentLabel.text = ""
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    // MARK: - PickerView datasource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count: Int
        
        switch pickerType {
        case .jeep:
            count = JeepModel.count
        case .condition:
            count = Condition.count
        }
        
        return count
    }
    
    // MARK: - PickerView delegate
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: data[row], attributes: [NSForegroundColorAttributeName:#colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        contentLabel.text = data[row]
        pushValueChanged(with: data[row])
    }
    
    // MARK: - Helpers
    
    private func generatePickerData() {
        data.removeAll()
        
        if pickerType == .jeep {
            data = JeepModel.arrayOfStrings()
        } else if pickerType == .condition {
            data.append(Condition.used.description)
            data.append(Condition.new.description)
            data.append(Condition.damaged.description)
            data.append(Condition.remanufactured.description)
            data.append(Condition.other.description)
        }
    }
    
    func setContentLabelForCurrentlySelectedRow() {
        let value = data[pickerView.selectedRow(inComponent: 0)]
        contentLabel.text = value
        pushValueChanged(with: value)
    }
    
    private func pushValueChanged(with value: String) {
        var pushValue: Any
        
        switch pickerType {
        case .jeep:
            pushValue = JeepModel.enumFromString(string: value)
        case .condition:
            pushValue = Condition.enumFromString(string: value)!
        }
        
        if let delegate = delegate {
            delegate.valueDidChangeInCell(sender: self, value: pushValue)
        }
    }

}
