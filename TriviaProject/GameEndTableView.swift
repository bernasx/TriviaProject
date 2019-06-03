//
//  GameEndTableView.swift
//  TriviaProject
//
//  Created by Bernardo Ribeiro on 26/05/2019.
//  Copyright © 2019 Bernardo Ribeiro. All rights reserved.
//

import UIKit

class GameEndTableView: UITableView {

    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        let cell = dequeueReusableCell(withIdentifier: "gameEnd")
        return cell
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
