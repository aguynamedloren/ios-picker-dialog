# PickerDialog

PickerDialog is a customizable class that displays a UIPickerView in a dialog
for iOS apps.  This project builds on [DatePickerDialog-iOS-Swift](https://github.com/squimer/DatePickerDialog-iOS-Swift]),
a date picker dialog developed by [Squimer](https://github.com/squimer).

## Adding to your project

Copy the `PickerDialog.swift` file into your project.  Modify to fit your needs.

## Example Usage

```swift
func buttonTapped() {
    let pickerData = [
        ["value": "mile", "display": "Miles (mi)"],
        ["value": "kilometer", "display": "Kilometers (km)"]
    ]

    PickerDialog().show("Distance units", options: pickerData, selected: settings.distance_unit) {
        (value) -> Void in

        print("Unit selected: \(value)")
    }
}
```

## Parameters

* title: String (Required)
* doneButtonTitle: String
* cancelButtonTitle: String
* selected: String (Default picker value)
* callback: ((value: String) -> Void) (Required)


## Special thanks to

* [@Squimer](https://github.com/squimer) for the [DatePickerDialog-iOS-Swift](https://github.com/squimer/DatePickerDialog-iOS-Swift) project.
* [@wimagguc](https://github.com/wimagguc) for the work with [ios-custom-alertview](https://github.com/wimagguc/ios-custom-alertview) library.

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
