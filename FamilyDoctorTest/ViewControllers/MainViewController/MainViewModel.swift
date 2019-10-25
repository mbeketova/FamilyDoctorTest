//
//  MainViewModel.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 23/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift

protocol MainViewModelDelegate: class {
    func reload()
    func show(error: Error)
}

final class MainViewModel {
    var numberOfItems: Int {
        return self.results.count
    }
    
    var informationViewModel: InformationViewModel!
    weak var delegate: MainViewModelDelegate?
    let isLoading = MutableProperty<Bool>(false)
    
    private let service = PillsService(config: Constants.RealmConfigurations.pills)
    private var results = Realm.instance(with: Constants.RealmConfigurations.pills).objects(Pill.self)
    private var notificationToken: NotificationToken!
    private var disposable: [Disposable] = []

    init() {
        setupNotificationToken()
    }
    
    deinit {
        self.disposable.forEach{ $0.dispose() }
        guard self.notificationToken != nil else { return }
        self.notificationToken.invalidate()
    }
    
    func configureTitles(for index: Int) {
        self.informationViewModel.pill.value = self.results[index]
    }
    
    func imageViewModel(for index: Int)  -> CardCollectionCellViewModel{
        return CardCollectionCellViewModel(image: self.results[index].img)
    }
}

//MARK: - Requests
extension MainViewModel {
    func loadPills(){
        self.isLoading.value = true
        let dispose = self.service.loadPills().startWithResult { [weak self](result) in
            if let error = result.error {
                self?.delegate?.show(error: error)
            }
            self?.isLoading.value = false
        }
        self.disposable.append(dispose)
    }
}

//MARK: - Configure
private extension MainViewModel {
    func configureInformationViewModel() {
        guard let firstPill = self.results.first else { return }
        self.informationViewModel = InformationViewModel(pill: firstPill)
    }
}

//MARK: - Setup Notification Tokens
private extension MainViewModel {
    func setupNotificationToken() {
        self.notificationToken = self.results.observe({ [unowned self] (changes) in
            switch changes {
            case .initial:
                self.configureInformationViewModel()
                self.delegate?.reload()
                self.isLoading.value = false
                break
            case .update(_, _,_, _):
                self.configureInformationViewModel()
                self.delegate?.reload()
                self.isLoading.value = false
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        })
    }
}
