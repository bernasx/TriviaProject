//
//  SettingsViewController.swift
//  TriviaProject

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    @IBAction func logOut(){
            do{
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "logOutSegue", sender: self)
            }catch{
                print(error.localizedDescription)
            }
    }
    //apaga as estatisticas da conta
    @IBAction func resetBtn(_ sender: UIButton) {
        //mostra um alerta com "ok" e "cancel"
        let refreshAlert = UIAlertController(title: "Reset Account?", message: "All your statistics will be reset! ", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let databaseReference = Database.database().reference()
            let user = Auth.auth().currentUser
            let uid = user?.uid
            let categorias = self.reader()
            databaseReference.child("utilizadores").child(uid!).child("correct_answers").setValue(0)
            databaseReference.child("utilizadores").child(uid!).child("total_answers").setValue(0)
            databaseReference.child("utilizadores").child(uid!).child("games_played").setValue(0)
            databaseReference.child("utilizadores").child(uid!).child("categories").setValue(categorias)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Auth.auth().currentUser)
        // Do any additional setup after loading the view.
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
