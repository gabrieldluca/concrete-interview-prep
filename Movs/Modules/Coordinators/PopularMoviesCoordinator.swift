//
//  PopularMoviesCoordinator.swift
//  Movs
//
//  Created by Gabriel D'Luca on 06/12/19.
//  Copyright © 2019 Gabriel D'Luca. All rights reserved.
//

import UIKit
import Combine

class PopularMoviesCoordinator: Coordinator {
    
    // MARK: - Typealiases
    
    typealias Presenter = UITabBarController
    typealias Controller = UINavigationController
    
    // MARK: - Properties
    
    internal let dependencies: Dependencies
    internal let coordinatedViewController: Controller
    internal let presenter: Presenter
    
    // MARK: - Child Coordinators
    
    internal var movieDetailsCoordinator: MovieDetailsCoordinator!
    
    // MARK: - Publishers and Subscribers
    
    internal var subscribers: [AnyCancellable?] = []
    
    // MARK: - Initializers and Deinitializers
    
    init(parent: AppCoordinator) {
        self.presenter = parent.coordinatedViewController
        self.dependencies = parent.dependencies
        
        let viewModel = PopularMoviesControllerViewModel(dependencies: self.dependencies)
        let controller = PopularMoviesViewController(viewModel: viewModel)
        self.coordinatedViewController = UINavigationController(rootViewController: controller)
        self.coordinatedViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        viewModel.modalPresenter = self
    }
    
    deinit {
        for subscriber in self.subscribers {
            subscriber?.cancel()
        }
    }
    
    // MARK: - Coordinator
    
    func start() { }
    
    func finish() {
        self.movieDetailsCoordinator = nil
    }
    
    // MARK: - Binding
    
    func bind(to coordinator: MovieDetailsCoordinator) {
        self.subscribers.append(coordinator.$coordinatorDidFinish
            .sink(receiveValue: { finished in
                if finished {
                    self.movieDetailsCoordinator = nil
                }
            })
        )
    }
}

extension PopularMoviesCoordinator: ModalPresenterDelegate {
    func showMovieDetails(movie: Movie) {
        self.movieDetailsCoordinator = MovieDetailsCoordinator(parent: self, movie: movie)
        self.movieDetailsCoordinator.start()
        self.bind(to: self.movieDetailsCoordinator)
    }
}
