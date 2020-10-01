//
//  TextFieldView.swift
//  zro
//
//  Created by rfl3 on 30/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import UIKit

class TextFieldView: UIView {

    var textField: UITextField!
    var separator: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    func setup() {
        for view in self.subviews {
            if let textField = view as? UITextField {
                self.textField = textField
            } else {
                self.separator = view
            }
        }
    }
}
