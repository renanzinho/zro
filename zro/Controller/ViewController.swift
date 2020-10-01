//
//  ViewController.swift
//  zro
//
//  Created by rfl3 on 14/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var email: TextFieldView!
    @IBOutlet weak var password: TextFieldView!
    @IBOutlet weak var registerButton: UIButton!

    var textFields: [TextFieldView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textFields = [email, password]

        let tap = UITapGestureRecognizer(target: self, action: #selector(outOfKeyboard))
        self.view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.signedIn(_:)),
                                               name: NSNotification.Name("SignedIn"),
                                               object: nil)
        self.setupLayout()
    }

    func setupLayout() {

        // Register custom layout
        let newHere = NSMutableAttributedString(string: "New here? ",
                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "gray") as Any])
        let register = NSMutableAttributedString(string: "Create an account",
                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "orange") as Any])
        newHere.append(register)
        self.registerButton.setAttributedTitle(newHere, for: .normal)

    }

    @objc
    func outOfKeyboard() {
        self.view.endEditing(false)
    }

    @objc
    func signedIn(_ notification: Notification) {
        performSegue(withIdentifier: "login", sender: self)
    }

    @IBAction func signin(_ sender: Any) {

        if !self.textFields.isEmpty {
            self.textFields.forEach { $0.shake() }
        } else {
            APIFacade.shared.signin(email: email.textField.text!,
                                    password: password.textField.text!) { response in
                                        switch response.response?.statusCode {

                                            case 401:

                                                guard let error = try? JSONDecoder().decode(SigninError.self,
                                                                                            from: response.data!)
                                                    else { return }

                                                self.showError(message: error.message)
                                                
                                                break

                                            case 200:

                                                guard let token = try? JSONDecoder().decode(Signin.self,
                                                                                            from: response.data!)
                                                    else { return }

                                                APIFacade.shared.token = token.token
                                                self.performSegue(withIdentifier: "login", sender: self)

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

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            self.textFields = self.textFields.filter { $0.textField != textField }
        }
    }
}
