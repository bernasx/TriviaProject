//
//  CustomUITextField.swift
//  TriviaProject


import Foundation
import UIKit  // don't forget this


//desativa opçoes de copiar/colar/cortar nos textfields 
class CustomUITextField: UITextField {
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            return false
    }
}
