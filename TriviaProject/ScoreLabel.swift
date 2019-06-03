//
//  ScoreLabel.swift
//  TriviaProject


import UIKit

class ScoreLabel: UILabel {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Text
        self.textColor = .white
        self.backgroundColor = .darkGray
        self.layer.cornerRadius = 8;
        self.clipsToBounds = true;
        
    }

}
