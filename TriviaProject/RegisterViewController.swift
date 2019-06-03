//
//  RegisterViewController.swift
//  TriviaProject

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmarTextField: UITextField!
    
    
    @IBAction func registerButton(_ sender: UIButton) {
        
        let email = emailTextField.text!
        let pass = passwordTextField.text!
        
        //validar password e email
        if verificarDados() == true{
            Auth.auth().createUser(withEmail: email, password: pass){
                (user,error) in
                if error == nil{
                    print("Registado com sucesso")
                    self.registerData(email: email, pass: pass)
                    self.tabBarController?.selectedIndex = 0
                }else{
                    print(error?.localizedDescription)
                }
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //registar dados na firebase
    func registerData(email: String,pass: String){
        Auth.auth().signIn(withEmail: email, password: pass){
            (user,error) in
            if error == nil{
                let databaseReference = Database.database().reference()
                let user = Auth.auth().currentUser
                let email = user?.email
                let uid = user?.uid
                let username = self.usernameTextField.text!
                databaseReference.child("utilizadores").child(uid!).child("username").setValue(username)
                databaseReference.child("utilizadores").child(uid!).child("email").setValue(email)
                databaseReference.child("utilizadores").child(uid!).child("correct_answers").setValue(0)
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    //----------
    
    //verifica se os dados sao corretos para criar conta
    func verificarDados()-> Bool{
        
        let pass = passwordTextField.text!
        let passConf = confirmarTextField.text!
        let email = emailTextField.text!
        
        if emailTextField.text! == "" || passwordTextField.text! == "" || confirmarTextField.text! == "" || usernameTextField.text! == ""{
            print("preenche tudo")
            return false
        }
        else if pass != passConf{
            print("pass nao e igual")
            return false
        }
        else if pass.count < 8 {
            print("pass curta")
            return false
        }
        else if !email.contains("@") && !email.contains("."){
            print("email mal formatado")
            return false
        }
        else{
            return true
        }
    }
    //-----
}
