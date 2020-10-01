//
//  SeparatorView.swift
//  zro
//
//  Created by rfl3 on 29/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import UIKit

class SeparatorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    func setupLayout() {
        self.layer.cornerRadius = self.frame.height / 2
        self.backgroundColor = UIColor(named: "orange")
    }

}
