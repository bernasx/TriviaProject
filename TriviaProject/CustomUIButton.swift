//
//  CustomUIButton.swift
//  TriviaProject

import UIKit

class CustomUIButton: UIButton{
    override func layoutSubviews() {
        super.layoutSubviews()

        if self.titleLabel?.text == "Next Question"{
            if self.isEnabled == true{
                self.titleLabel?.textColor = .white
            }
            else{
                self.titleLabel?.textColor = .lightGray
            }
            self.backgroundColor = .darkGray
            self.layer.cornerRadius = 8;
            self.clipsToBounds = true;
        }else{
            //botoes de respostas
            self.setTitleColor(UIColor.darkGray, for: .normal)
            self.setTitleColor(UIColor.white, for: .selected)
            self.tintColor = UIColor.darkGray
            
        }
       
        
  }
    
    
}
