# PickerDialog
I add update for display callback
PickerDialog is a customizable class that displays a UIPickerView in a dialog
for iOS apps.  This project builds on [DatePickerDialog-iOS-Swift](https://github.com/squimer/DatePickerDialog-iOS-Swift),
a date picker dialog developed by [Squimer](https://github.com/squimer).

![Demo screen](example.png)

## Swift Version
This project is using swift version 5

## Adding to your project

Copy the `PickerDialog.swift` file into your project.  Modify to fit your needs.

## Example Usage

```swift
func buttonTapped() {
    let pickerData = [
        ["value": "mile", "display": "Miles (mi)"],
        ["value": "kilometer", "display": "Kilometers (km)"]
    ]
    PickerDialog().show("Distance units", options: pickerData, selected: "kilometer") {
        (value, display) -> Void in

        print("Unit selected: \(value), display: \(display)")
    }
}
```

## Parameters

* title: String (Required)
* doneButtonTitle: String
* cancelButtonTitle: String
* selected: String (Default picker value)
* callback: ((value: String, display: String) -> Void) (Required)

## Forked from
* [@aguynamedloren](https://github.com/aguynamedloren) 

## Special thanks to

* [@Squimer](https://github.com/squimer) for the [DatePickerDialog-iOS-Swift](https://github.com/squimer/DatePickerDialog-iOS-Swift) project.

* [@wimagguc](https://github.com/wimagguc) for the work with [ios-custom-alertview](https://github.com/wimagguc/ios-custom-alertview) library.

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
