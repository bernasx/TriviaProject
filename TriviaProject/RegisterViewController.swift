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
                    //verifica se escreveu os dados na base de dados 
                    self.registerData(email: email, pass: pass, completionHandler: { (flag, error) in
                        
                        if flag == true{
                             self.tabBarController?.selectedIndex = 0
                        }else{
                            self.alerts(message: "Error writing data")
                        }
                        
                    })
                }else{
                    let err = error! as NSError
                    //erros do Firebase
                    if let errCode = AuthErrorCode(rawValue: err.code ) {
                        
                        switch errCode {
                        case .invalidEmail:
                            self.alerts(message: "Invalid Email!")
                        case .emailAlreadyInUse:
                            self.alerts(message: "Email already in use!")
                        default:
                            self.alerts(message: "Possible Network Failure.")
                        }
                    }
                }
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fecha os campos de texto se clicarmos fora
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard (){
        view.endEditing(true)
    }
    
    //registar dados na firebase
    func registerData(email: String,pass: String, completionHandler:@escaping (Bool, Error?)-> Void){
        Auth.auth().signIn(withEmail: email, password: pass){
            (user,error) in
            if error == nil{
                let databaseReference = Database.database().reference()
                let user = Auth.auth().currentUser
                let email = user?.email
                let uid = user?.uid
                let username = self.usernameTextField.text!
                let categorias = self.reader()
                databaseReference.child("utilizadores").child(uid!).child("username").setValue(username)
                databaseReference.child("utilizadores").child(uid!).child("email").setValue(email)
                databaseReference.child("utilizadores").child(uid!).child("correct_answers").setValue(0)
                databaseReference.child("utilizadores").child(uid!).child("total_answers").setValue(0)
                databaseReference.child("utilizadores").child(uid!).child("games_played").setValue(0)
                databaseReference.child("utilizadores").child(uid!).child("categories").setValue(categorias)
                completionHandler(true,error)
            }else{
                completionHandler(false,error)
            }
            self.usernameTextField.text = ""
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.confirmarTextField.text = ""
        }
    }
    //----------
    
    //verifica se os dados sao corretos para criar conta
    func verificarDados()-> Bool{
        
        let pass = passwordTextField.text!
        let passConf = confirmarTextField.text!
        let email = emailTextField.text!
        let username = usernameTextField.text!
        
        if emailTextField.text! == "" || passwordTextField.text! == "" || confirmarTextField.text! == "" || usernameTextField.text! == ""{
            print("preenche tudo")
            alerts(message: "Please fill in every box!")
            return false
        }
        else if pass != passConf{
            print("pass nao e igual")
            alerts(message: "Passwords do not match!")
            return false
        }
        else if pass.count < 8 {
            print("pass curta")
            alerts(message: "Password must be at least 8 characters long!")
            return false
        }
        else if username.count > 24{
            alerts(message: "Username too long!")
            return false
        }
        else{
            return true
        }
    }
    //-----
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
    
    struct gameConfigArrs: Codable{
        var categoryArray: [String] = []
        var categoryDict: [String:String?] = [:]
        var typeArray: [String] = []
        var typeDict: [String:String?] = [:]
        var difficultyArray: [String] = []
        var difficultyDict: [String:String?] = [:]
    }
    
    //le e converte um Array num Dict de categorias e vezes jogadas
    func reader() -> [String:Int]{
        var arr: gameConfigArrs? = nil
        var categoryArr: [String] = []
        var returnDict: [String:Int] = [:]
        
        if  let path = Bundle.main.path(forResource: "GameConfig", ofType: "plist"),
            let xml  = FileManager.default.contents(atPath: path),
            let gameConfigArrays = try? PropertyListDecoder().decode(gameConfigArrs.self, from: xml){
            arr = gameConfigArrays
        }
        categoryArr = arr!.categoryArray
        for i in 0...categoryArr.count-1{
            
            returnDict[categoryArr[i]] = 0
            
        }
        return returnDict
    }
    
}


