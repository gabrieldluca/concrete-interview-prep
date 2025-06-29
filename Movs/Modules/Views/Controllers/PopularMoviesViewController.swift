//
//  PopularMoviesViewController.swift
//  Movs
//
//  Created by Gabriel D'Luca on 02/12/19.
//  Copyright © 2019 Gabriel D'Luca. All rights reserved.
//

import UIKit
import Combine

class PopularMoviesViewController: UIViewController {

    // MARK: - Properties
    
    internal let searchController = UISearchController(searchResultsController: nil)
    internal let screen = PopularMoviesViewScreen()
    internal let errorScreen = ErrorViewScreen()
    internal let viewModel: PopularMoviesControllerViewModel
    internal var displayedError: AppError = .none
    
    // MARK: - Publishers and Subscribers
    
    internal var subscribers: [AnyCancellable?] = []
    
    // MARK: - Initializers and Deinitializers
    
    init(viewModel: PopularMoviesControllerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "Popular"
        self.errorScreen.retryButton.addTarget(self, action: #selector(self.retryConnection(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        for subscriber in self.subscribers {
            subscriber?.cancel()
        }
    }
    
    // MARK: - ViewController life cycle
    
    override func loadView() {
        super.loadView()
        self.view = self.screen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind(to: self.viewModel)
        
        self.screen.moviesCollectionView.delegate = self
        self.screen.moviesCollectionView.dataSource = self
        self.screen.moviesCollectionView.prefetchDataSource = self
        self.configureSearchBar()
    }
    
    // MARK: - Binding
    
    func bind(to viewModel: PopularMoviesControllerViewModel) {
        self.subscribers.append(viewModel.$numberOfPopularMovies
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in
                let section = IndexSet(integer: 0)
                self.screen.moviesCollectionView.reloadSections(section)
            })
        )
        
        self.subscribers.append(viewModel.$numberOfFavoriteMovies
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in
                let section = IndexSet(integer: 0)
                self.screen.moviesCollectionView.reloadSections(section)
            })
        )
        
        self.subscribers.append(viewModel.$hasSearchResults
            .receive(on: RunLoop.main)
            .sink(receiveValue: { hasResults in
                if !hasResults && self.displayedError == .none {
                    self.showSearchError()
                } else if hasResults && self.displayedError == .searchError {
                    self.displayedError = .none
                    self.view = self.screen
                }
            })
        )
        
        self.subscribers.append(viewModel.$fetchStatus
            .receive(on: RunLoop.main)
            .sink(receiveValue: { status in
                if status == .completedFetchWithError {
                    self.showNetworkError()
                } else if [.fetchingGenres, .fetchingMovies].contains(status) {
                    self.showLoadingIndicator()
                } else if !self.screen.loadingIndicatorView.isHidden {
                    self.hideLoadingIndicator()
                }
            })
        )
    }
}
