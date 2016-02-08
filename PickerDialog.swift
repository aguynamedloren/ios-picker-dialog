//
//  PickerDialog.swift
//
//  Created by Loren Burton on 02/08/2016.
//

import Foundation
import UIKit
import QuartzCore

class PickerDialog: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    typealias PickerCallback = (value: String) -> Void

    /* Constants */
    private let kPickerDialogDefaultButtonHeight:       CGFloat = 50
    private let kPickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kPickerDialogCornerRadius:              CGFloat = 7
    private let kPickerDialogDoneButtonTag:             Int     = 1

    /* Views */
    private var dialogView:   UIView!
    private var titleLabel:   UILabel!
    private var picker:       UIPickerView!
    private var cancelButton: UIButton!
    private var doneButton:   UIButton!

    /* Variables */
    private var pickerData =         [[String: String]]()
    private var selectedPickerValue: String?
    private var callback:            PickerCallback?


    /* Overrides */
    init() {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))

        setupView()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.dialogView = createContainerView()

        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.mainScreen().scale

        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale

        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)

        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)

        picker.delegate = self

        self.addSubview(self.dialogView!)
    }

    /* Handle device orientation changes */
    func deviceOrientationDidChange(notification: NSNotification) {
        close() // For now just close it
    }

    /* Required UIPickerView functions */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]["display"]
    }

    /* Helper to find row of selected value */
    func findIndexForValue(value: String, array: [[String: String]]) -> Int? {
        for (index, dictionary) in array.enumerate() {
            if dictionary["value"] == value {
                return index
            }
        }

        return nil
    }

    /* Create the dialog view, and animate opening the dialog */
    func show(title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", options: [[String: String]], selected: String? = nil, callback: PickerCallback) {
        self.titleLabel.text = title
        self.pickerData = options
        self.doneButton.setTitle(doneButtonTitle, forState: .Normal)
        self.cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
        self.callback = callback

        if selected != nil {
            self.selectedPickerValue = selected
            let selectedIndex = findIndexForValue(selected!, array: options) ?? 0
            self.picker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }

        /* */
        UIApplication.sharedApplication().windows.first!.addSubview(self)
        UIApplication.sharedApplication().windows.first!.endEditing(true)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)

        /* Anim */
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }

    /* Dialog close animation then cleaning and removing the view from the parent */
    private func close() {
        NSNotificationCenter.defaultCenter().removeObserver(self)

        let currentTransform = self.dialogView.layer.transform

        let startRotation = (self.valueForKeyPath("layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + M_PI * 270 / 180), 0, 0, 0)

        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1

        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.TransitionNone,
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
    private func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        let dialogSize = CGSizeMake(
            300,
            230
                + kPickerDialogDefaultButtonHeight
                + kPickerDialogDefaultButtonSpacerHeight)

        // For the black background
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)

        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height))

        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).CGColor,
            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).CGColor,
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).CGColor]

        let cornerRadius = kPickerDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, atIndex: 0)

        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).CGColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius + 5) / 2, 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.blackColor().CGColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).CGPath

        // There is a line above the button
        let lineView = UIView(frame: CGRectMake(0, dialogContainer.bounds.size.height - kPickerDialogDefaultButtonHeight - kPickerDialogDefaultButtonSpacerHeight, dialogContainer.bounds.size.width, kPickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        // ˆˆˆ

        //Title
        self.titleLabel = UILabel(frame: CGRectMake(10, 10, 280, 30))
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.textColor = UIColor(hex: 0x333333)
        self.titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        dialogContainer.addSubview(self.titleLabel)

        self.picker = UIPickerView(frame: CGRectMake(0, 30, 0, 0))
        self.picker.setValue(UIColor(hex: 0x333333), forKeyPath: "textColor")
        self.picker.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
        self.picker.frame.size.width = 300

        dialogContainer.addSubview(self.picker)

        // Add the buttons
        addButtonsToView(dialogContainer)

        return dialogContainer
    }

    /* Add buttons to container */
    private func addButtonsToView(container: UIView) {
        let buttonWidth = container.bounds.size.width / 2

        self.cancelButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.cancelButton.frame = CGRectMake(
            0,
            container.bounds.size.height - kPickerDialogDefaultButtonHeight,
            buttonWidth,
            kPickerDialogDefaultButtonHeight
        )
        self.cancelButton.setTitleColor(UIColor(hex: 0x555555), forState: UIControlState.Normal)
        self.cancelButton.setTitleColor(UIColor(hex: 0x555555), forState: UIControlState.Highlighted)
        self.cancelButton.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 15)
        self.cancelButton.layer.cornerRadius = kPickerDialogCornerRadius
        self.cancelButton.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(self.cancelButton)

        self.doneButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.doneButton.frame = CGRectMake(
            buttonWidth,
            container.bounds.size.height - kPickerDialogDefaultButtonHeight,
            buttonWidth,
            kPickerDialogDefaultButtonHeight
        )
        self.doneButton.tag = kPickerDialogDoneButtonTag
        self.doneButton.setTitleColor(UIColor(hex: 0x555555), forState: UIControlState.Normal)
        self.doneButton.setTitleColor(UIColor(hex: 0x555555), forState: UIControlState.Highlighted)
        self.doneButton.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 15)
        self.doneButton.layer.cornerRadius = kPickerDialogCornerRadius
        self.doneButton.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(self.doneButton)
    }

    func buttonTapped(sender: UIButton!) {
        if sender.tag == kPickerDialogDoneButtonTag {
            let selectedIndex = self.picker.selectedRowInComponent(0)
            let selectedValue = self.pickerData[selectedIndex]["value"]
            self.callback?(value: selectedValue!)
        }

        close()
    }

    /* Helper function: count and return the screen's size */
    func countScreenSize() -> CGSize {
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height

        return CGSizeMake(screenWidth, screenHeight)
    }
}
