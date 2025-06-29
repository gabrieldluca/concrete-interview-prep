//
//  PopularMoviesCoordinator.swift
//  Movs
//
//  Created by Gabriel D'Luca on 06/12/19.
//  Copyright © 2019 Gabriel D'Luca. All rights reserved.
//

import UIKit
import Combine

class MovieDetailsCoordinator: ModalCoordinator {
    
    // MARK: - Typealiases
    
    typealias Presenter = UIViewController
    typealias Controller = MovieDetailsViewController
    
    // MARK: - Properties
    
    internal let dependencies: Dependencies
    internal var coordinatedViewController: Controller
    internal var presenter: Presenter
    
    // MARK: - Publishers and Subscribers
    
    @Published var coordinatorDidFinish: Bool = false
    internal var finishingPublisher: Published<Bool>.Publisher {
        return $coordinatorDidFinish
    }
    
    // MARK: - Initializers and Deinitializers
    
    init<Parent: Coordinator>(parent: Parent, movie: Movie) {
        self.presenter = parent.coordinatedViewController
        self.dependencies = parent.dependencies
                
        let movieViewModel = MovieViewModel(movie: movie, dependencies: self.dependencies)
        let viewModel = MovieDetailsControllerViewModel(movieViewModel: movieViewModel)
        self.coordinatedViewController = MovieDetailsViewController(viewModel: viewModel)
        
        viewModel.coordinator = self
    }
    
    // MARK: - Coordinator
    
    func start() {
        self.presenter.present(self.coordinatedViewController, animated: true)
    }
    
    func finish() {
        self.coordinatorDidFinish = true
    }
}
