//
//  EndGameSegue.swift
//  TriviaProject
//
//  Created by Bernardo Ribeiro on 26/05/2019.
//  Copyright © 2019 Bernardo Ribeiro. All rights reserved.
//

import Foundation
class EndGameSegue: UIStoryboardSegue {
    override func perform() {
        if let navigationController = self.sourceViewController.navigationController as UINavigationController? {
            var controllers = navigationController.viewControllers
            controllers.removeLast()
            controllers.append(self.destinationViewController)
            navigationController.setViewControllers(controllers, animated: true)
        }
    }
}
