//
//  RegisterViewController.swift
//  zro
//
//  Created by rfl3 on 29/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var name: TextFieldView!
    @IBOutlet weak var email: TextFieldView!
    @IBOutlet weak var password: TextFieldView!
    @IBOutlet weak var confirmPassword: TextFieldView!
    @IBOutlet weak var birthdate: TextFieldView!
    @IBOutlet weak var errorLabel: UILabel!

    var textFields: [TextFieldView] = []

    var selectedTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textFields = [name, email, password, confirmPassword]

        let tap = UITapGestureRecognizer(target: self, action: #selector(outOfKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    @objc
    func outOfKeyboard() {
        self.view.endEditing(false)
    }

    @IBAction func singup(_ sender: Any) {

        if !self.textFields.isEmpty {
            self.textFields.forEach { $0.shake() }
        } else if self.confirmPassword.textField.text != self.password.textField.text {
            self.password.shake()
            self.confirmPassword.shake()
            self.showError(message: "Passwords must match!")
        } else {
            APIFacade.shared.signup(email: self.email.textField.text!,
                                    password: self.password.textField.text!,
                                    name: self.name.textField.text!,
                                    birthdate: self.birthdate.textField.text!) { response in
                                        switch response.response?.statusCode {
                                            case 422:
                                                self.email.shake()
                                                guard let errors = try? JSONDecoder().decode(SignupError.self,
                                                                                             from: response.data!),
                                                    let error = errors.errors.first
                                                    else { return }

                                                self.showError(message: error.message)
                                                break
                                            case 201:
                                                self.dismiss(animated: true) {
                                                    guard let token = try? JSONDecoder().decode(Signin.self,
                                                                                                from: response.data!)
                                                        else { return }
                                                    APIFacade.shared.token = token.token
                                                    NotificationCenter.default.post(name: NSNotification.Name("SignedIn"), object: nil)
                                                }
                                                break
                                            default:
                                                self.showError(message: "Sorry, try again later")
                                                break
                                        }
            }
        }

    }

    func showError(message: String) {
        self.errorLabel.text = message
        UIView.animate(withDuration: 0.3, animations: {
            self.errorLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2, animations: {
                self.errorLabel.alpha = 0
            })
        })
    }

}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            self.textFields = self.textFields.filter { $0.textField != textField }
        }
    }
}
