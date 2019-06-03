//
//  LoginViewController.swift
//  TriviaProject

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBAction func loginButton(_ sender: UIButton) {
        let email = emailTextField.text!
        let pass = passTextField.text!
        
        Auth.auth().signIn(withEmail: email, password: pass){
            (user,error) in
            if error == nil{
                self.performSegue(withIdentifier: "loginSegue", sender: self)
                self.emailTextField.text = ""
                self.passTextField.text = ""
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        // Do any additional setup after loading the view.
    }
    
    


}
