//
//  StatManager.swift
//  TriviaProject

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class StatManager{
    
    let databaseReference: DatabaseReference
    let user: User
    let uid: String
    
    init(){

        databaseReference = Database.database().reference()
        user = Auth.auth().currentUser!
        uid = user.uid
    }
    
    //retorna o username em String
    func displayUsername(completionHandler:@escaping (String, Error?)-> Void){
        var username: String = ""
        databaseReference.child("utilizadores").child(uid).observeSingleEvent(of: .value, with: {snapshot in
            let dict = snapshot.value as! [String : Any]
            username = dict["username"] as! String
            completionHandler(username,nil)
        })
    }
    //retorn o numero de jogos jogados em String
    func getGamesPlayed(completionHandler:@escaping (String, Error?)-> Void){
        var gamesPlayed: NSNumber = 0
        databaseReference.child("utilizadores").child(uid).observeSingleEvent(of: .value, with: {snapshot in
            let dict = snapshot.value as! [String : Any]
            gamesPlayed = dict["games_played"] as! NSNumber
            completionHandler(gamesPlayed.stringValue,nil)
        })
    }
    
    //soma o total de jogos e adiciona um
    func updateGamesPlayed(){
        getGamesPlayed { (gamesPlayed, error) in
            let newGamesPlayed = Int(gamesPlayed)! + 1
            self.databaseReference.child("utilizadores").child(self.uid).child("games_played").setValue(newGamesPlayed)
        }
    }
    
    func getTotalAnswers(completionHandler:@escaping (String, Error?)-> Void){
        var totalAnswers: NSNumber = 0
        databaseReference.child("utilizadores").child(uid).observeSingleEvent(of: .value, with: {snapshot in
            let dict = snapshot.value as! [String : Any]
            totalAnswers = dict["total_answers"] as! NSNumber
            completionHandler(totalAnswers.stringValue,nil)
        })
    }
    
    func updateTotalAnswers(){
        getTotalAnswers { (totalAnswers, error) in
            let newTotalAnswers = Int(totalAnswers)! + 1
            self.databaseReference.child("utilizadores").child(self.uid).child("total_answers").setValue(newTotalAnswers)
        }
    }
    
    func getCorrectAnswers(completionHandler:@escaping (String, Error?)-> Void){
        var correctAnswers: NSNumber = 0
        databaseReference.child("utilizadores").child(uid).observeSingleEvent(of: .value, with: {snapshot in
            let dict = snapshot.value as! [String : Any]
            correctAnswers = dict["correct_answers"] as! NSNumber
            completionHandler(correctAnswers.stringValue,nil)
        })
    }
    
    func updateCorrectAnswers(){
        getCorrectAnswers { (correctAnswers, error) in
            let newCorrectAnswers = Int(correctAnswers)! + 1
            self.databaseReference.child("utilizadores").child(self.uid).child("correct_answers").setValue(newCorrectAnswers)
        }
    }
    

//    var catDict:[String: Int] = [:]
    func getFavoriteCategory(completionHandler:@escaping (String, Error?)-> Void){
        databaseReference.child("utilizadores").child(uid).observeSingleEvent(of: .value, with: {snapshot in
            let dict = snapshot.value as! [String : Any]
            var maxKey = ""
            var maxValue = 0
            let categories = dict["categories"] as! [String: Int]
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async{
                categories.forEach{
                    element in
                    if element.value > maxValue{
                        maxValue = element.value
                        maxKey = element.key
                    }
                }
                group.leave()
            }
            group.notify(queue: .main) {
                if maxValue == 0{
                    completionHandler("N/A",nil)
                }else{
                    completionHandler(maxKey,nil)
                }
            }
        })
    }
    
    func updateCategory(category: String){
        var newValue: Int = 0
        self.databaseReference.child("utilizadores").child(self.uid).child("categories").observeSingleEvent(of: .value, with: {snapshot in
            let dict = snapshot.value as! [String : Any]
            let value = dict[category] as! Int
            newValue = value + 1
             self.databaseReference.child("utilizadores").child(self.uid).child("categories").child(category).setValue(newValue)
        })
    }
}
