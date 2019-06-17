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
                let err = error! as NSError
                //erros do Firebase
                if let errCode = AuthErrorCode(rawValue: err.code ) {
                    
                    switch errCode {
                    case .invalidEmail:
                        self.alerts(message: "Invalid Email!")
                    case .wrongPassword:
                        self.alerts(message: "Wrong Password!")
                    case .userNotFound:
                        self.alerts(message: "Email/User not found!")
                    default:
                        self.alerts(message: "Possible Network Failure.")
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.hidesBackButton = true //tabBar porque primeiro tenho um nav controller e aseguir um tab bar controller
        if FirebaseApp.app() == nil{
            FirebaseApp.configure()
        }
        // fecha os campos de texto se clicarmos fora
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard (){
        view.endEditing(true)
    }
    //constroi alerta
    func alerts(message: String){
        let alert = UIAlertController(title: "Invalid Register", message: message, preferredStyle: .alert)
        // number of lines
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        if user != nil{
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
}
