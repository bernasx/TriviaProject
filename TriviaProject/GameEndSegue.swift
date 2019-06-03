//
//  GameEndSegue.swift
//  TriviaProject


import UIKit

class GameEndSegue: UIStoryboardSegue {

    override func perform() {
        if let navigationController = source.navigationController as UINavigationController? {
            var controllers = navigationController.viewControllers
            controllers.removeLast()
            controllers.append(destination)
            navigationController.setViewControllers(controllers, animated: true)
        }
    }
}
