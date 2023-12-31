//
//  ConfigurationViewController.swift
//  ScannerApp-Swift
//
//  Created by Zheren Xiao on 2020-02-09.
//  Copyright © 2020 jx16. All rights reserved.
//

import UIKit

/// manage the configuration activity for the app
class ConfigurationViewController: UIViewController {
    
    private let sceneTypes = Constants.sceneTypes
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var hostTextField: UITextField!
    
    @IBOutlet weak var debugModeSwitch: UISwitch!
	
	@IBOutlet weak var deleteEnableSwitch: UISwitch!
	
    /// load the UI for the configuration activity
	override func viewDidLoad() {
        super.viewDidLoad()

        // setup text fields
        firstNameTextField.delegate = self
        firstNameTextField.text = UserDefaults.firstName
        firstNameTextField.autocorrectionType = .no
        
        lastNameTextField.delegate = self
        lastNameTextField.text = UserDefaults.lastName
        lastNameTextField.autocorrectionType = .no
        
        hostTextField.delegate = self
        hostTextField.text = UserDefaults.host
        hostTextField.placeholder = Constants.Server.defaultHost
        hostTextField.autocorrectionType = .no
        
        debugModeSwitch.isOn = UserDefaults.debugFlag
		deleteEnableSwitch.isOn = UserDefaults.deleteFlag
        
        // dismiss keyboard when tap elsewhere
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @IBAction func debugModeSwitchValueChanged(_ sender: Any) {
        UserDefaults.set(debugFlag: debugModeSwitch.isOn)
    }
	
	@IBAction func deleteEnableSwitchValueChanged(_ sender: Any) {
		UserDefaults.set(deleteFlag: deleteEnableSwitch.isOn)
	}
	
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ConfigurationViewController: UITextFieldDelegate {
    /// Save user input data such as user name and host
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text: String = (textField.text ?? "").trimmingCharacters(in: .whitespaces)
        
        switch textField {
        case firstNameTextField:
            print("setting first name to '\(text)'.")
            UserDefaults.set(firstName: text)
        case lastNameTextField:
            print("setting last name to '\(text)'.")
            UserDefaults.set(lastName: text)
        case hostTextField:
            print("setting host to '\(text)'.")
            UserDefaults.set(host: text)
        default:
            print("text field with tag \(textField.tag) is not found.")
        }
    }
    
    /// dismiss keyboard when user finishes input data
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("dismiss keyboard.")
        textField.resignFirstResponder()
        return true
    }
    
}
