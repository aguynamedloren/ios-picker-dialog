//
//  PickerDialog.swift
//
//  Created by Loren Burton on 02/08/2016.
//

import Foundation
import UIKit
import QuartzCore

class PickerDialog: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    typealias PickerCallback = (_ value: String) -> Void

    /* Constants */
    fileprivate let kPickerDialogDefaultButtonHeight:       CGFloat = 50
    fileprivate let kPickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    fileprivate let kPickerDialogCornerRadius:              CGFloat = 7
    fileprivate let kPickerDialogDoneButtonTag:             Int     = 1

    /* Views */
    fileprivate var dialogView:   UIView!
    fileprivate var titleLabel:   UILabel!
    fileprivate var picker:       UIPickerView!
    fileprivate var cancelButton: UIButton!
    fileprivate var doneButton:   UIButton!

    /* Variables */
    fileprivate var pickerData =         [[String: String]]()
    fileprivate var selectedPickerValue: String?
    fileprivate var callback:            PickerCallback?

    public var itemsFont: UIFont?
    
    /* Overrides */
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

        setupView()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.dialogView = createContainerView()

        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.main.scale

        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale

        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)

        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)

        picker.delegate = self

        self.addSubview(self.dialogView!)
    }

    /* Handle device orientation changes */
    func deviceOrientationDidChange(_ notification: Notification) {
        close() // For now just close it
    }

    /* Required UIPickerView functions */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    //old
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return pickerData[row]["display"]
//    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        
        if (itemsFont != nil) {
            label.font = itemsFont
        } else {
            label.font = UIFont.systemFont(ofSize: 30)
        }
        
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = pickerData[row]["display"]
        
        return label
    }

    /* Helper to find row of selected value */
    func findIndexForValue(_ value: String, array: [[String: String]]) -> Int? {
        for (index, dictionary) in array.enumerated() {
            if dictionary["value"] == value {
                return index
            }
        }

        return nil
    }

    /* Create the dialog view, and animate opening the dialog */
    func show(_ title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", options: [[String: String]], selected: String? = nil, callback: @escaping PickerCallback) {
        self.titleLabel.text = title
        self.pickerData = options
        
        self.doneButton.setTitle(doneButtonTitle, for: UIControlState.normal)
        self.cancelButton.setTitle(cancelButtonTitle, for: UIControlState.normal)
        self.callback = callback
        
//        self.doneButton.tintColor = UIColor.blue
//        self.cancelButton.tintColor = UIColor.blue

        if selected != nil {
            self.selectedPickerValue = selected
            let selectedIndex = findIndexForValue(selected!, array: options) ?? 0
            self.picker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }

        /* */
        UIApplication.shared.windows.first!.addSubview(self)
        UIApplication.shared.windows.first!.endEditing(true)

        NotificationCenter.default.addObserver(self, selector: #selector(PickerDialog.deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        /* Anim */
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }

    /* Dialog close animation then cleaning and removing the view from the parent */
    fileprivate func close() {
        NotificationCenter.default.removeObserver(self)

        let currentTransform = self.dialogView.layer.transform

        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + M_PI * 270 / 180), 0, 0, 0)

        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.opacity = 0
            }) { (finished: Bool) -> Void in
                for v in self.subviews {
                    v.removeFromSuperview()
                }

                self.removeFromSuperview()
        }
    }

    /* Creates the container view here: create the dialog, then add the custom content and buttons */
    fileprivate func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        let dialogSize = CGSize(
            width: 300,
            height: 230
                + kPickerDialogDefaultButtonHeight
                + kPickerDialogDefaultButtonSpacerHeight)

        // For the black background
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)

        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRect(x: (screenSize.width - dialogSize.width) / 2, y: (screenSize.height - dialogSize.height) / 2, width: dialogSize.width, height: dialogSize.height))

        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor,
            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor,
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor]

        let cornerRadius = kPickerDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, at: 0)

        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSize(width: 0 - (cornerRadius + 5) / 2, height: 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.black.cgColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).cgPath

        // There is a line above the button
        let lineView = UIView(frame: CGRect(x: 0, y: dialogContainer.bounds.size.height - kPickerDialogDefaultButtonHeight - kPickerDialogDefaultButtonSpacerHeight, width: dialogContainer.bounds.size.width, height: kPickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        // ˆˆˆ

        //Title
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 280, height: 30))
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.textColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        dialogContainer.addSubview(self.titleLabel)

        self.picker = UIPickerView(frame: CGRect(x: 0, y: 30, width: 0, height: 0))
        self.picker.setValue(UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0), forKeyPath: "textColor")
        self.picker.autoresizingMask = UIViewAutoresizing.flexibleRightMargin
        self.picker.frame.size.width = 300
        
        dialogContainer.addSubview(self.picker)

        // Add the buttons
        addButtonsToView(dialogContainer)

        return dialogContainer
    }

    /* Add buttons to container */
    fileprivate func addButtonsToView(_ container: UIView) {
        let buttonWidth = container.bounds.size.width / 2

        self.cancelButton = UIButton(type: UIButtonType.custom) as UIButton
        self.cancelButton.frame = CGRect(
            x: 0,
            y: container.bounds.size.height - kPickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kPickerDialogDefaultButtonHeight
        )
        self.cancelButton.setTitleColor(UIColor(red: 22/255.0, green: 131/255.0, blue: 251/255.0, alpha: 1.0), for: UIControlState.normal)
        self.cancelButton.setTitleColor(UIColor(red: 22/255.0, green: 131/255.0, blue: 251/255.0, alpha: 1.0), for: UIControlState.highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.cancelButton.layer.cornerRadius = kPickerDialogCornerRadius
        self.cancelButton.addTarget(self, action: #selector(PickerDialog.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        container.addSubview(self.cancelButton)

        self.doneButton = UIButton(type: UIButtonType.custom) as UIButton
        self.doneButton.frame = CGRect(
            x: buttonWidth,
            y: container.bounds.size.height - kPickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kPickerDialogDefaultButtonHeight
        )
        self.doneButton.tag = kPickerDialogDoneButtonTag
        self.doneButton.setTitleColor(UIColor(red: 22/255.0, green: 131/255.0, blue: 251/255.0, alpha: 1.0), for: UIControlState.normal)
        self.doneButton.setTitleColor(UIColor.blue, for: UIControlState.highlighted)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.doneButton.layer.cornerRadius = kPickerDialogCornerRadius
        self.doneButton.addTarget(self, action: #selector(PickerDialog.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        container.addSubview(self.doneButton)
    }

    func buttonTapped(_ sender: UIButton!) {
        if sender.tag == kPickerDialogDoneButtonTag {
            let selectedIndex = self.picker.selectedRow(inComponent: 0)
            let selectedValue = self.pickerData[selectedIndex]["value"]
            self.callback?(selectedValue!)
        }

        close()
    }

    /* Helper function: count and return the screen's size */
    func countScreenSize() -> CGSize {
    
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height

        return CGSize(width: screenWidth, height: screenHeight)
    }
}
