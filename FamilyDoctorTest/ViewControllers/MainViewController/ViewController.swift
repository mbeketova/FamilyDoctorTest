//
//  ViewController.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 23/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit
import Gemini
import ReactiveSwift

private let scale: CGFloat = 0.8
private let verticalMargin: CGFloat = 20
private let horizontalMargin: CGFloat = 20

final class ViewController: UIViewController {

    private let viewModel = MainViewModel()
    private lazy var collectionView = GeminiCollectionView(frame: .zero, collectionViewLayout: flowLayout())
    private let pageControl = UIPageControl()
    private let button = UIButton()
    private let labelsView = InformationView()
    private var isFirstLoad = true
    private var rightButtonItem: UIBarButtonItem!
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        configureCollectionView()
        configureAnimation()
        setupPageControl()
        setupButton()
        setupLabelsView()
        setupRightButton()
        setupActivityIndicator()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutCollectionView()
        layoutButton()
        layoutPageControl()
        layoutLabelsView()
        layoutActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.isFirstLoad else { return }
        self.isFirstLoad = false
        loadPills()
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(indexPath: indexPath) as CardCollectionCell
        cell.bind(viewModel: self.viewModel.imageViewModel(for: indexPath.row))
        self.collectionView.animateCell(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeminiCell {
            self.collectionView.animateCell(cell)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.collectionView.animateVisibleCells()
        let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = self.collectionView.indexPathForItem(at: visiblePoint) {
            configureNextViewsIfNeeded(visibleIndexPath)
            configureFirstViewsIfNeeded(visibleIndexPath)
        }
    }
}

//MARK: - MainViewModelDelegate
extension ViewController: MainViewModelDelegate {
    func reload() {
        self.pageControl.numberOfPages = self.viewModel.numberOfItems
        self.pageControl.currentPage = 0
        if self.viewModel.informationViewModel != nil {
            self.labelsView.bind(viewModel: self.viewModel.informationViewModel)
            self.viewModel.configureTitles(for: self.pageControl.currentPage)
            self.collectionView.reloadData()
        }
    }
    
    func show(error: Error) {
        showMessage(title: error.title ?? "Error", msg: error.message)
    }
}

//MARK: - Requests
private extension ViewController {
    func loadPills() {
        self.viewModel.loadPills()
    }
}

//MARK: - Setup
private extension ViewController {
    func setupPageControl() {
        self.pageControl.currentPageIndicatorTintColor = .blue
        self.pageControl.pageIndicatorTintColor = .lightGray
        self.pageControl.currentPage = 0
        self.view.addSubview(self.pageControl)
        self.view.bringSubviewToFront(self.pageControl)
    }
    
    func setupButton() {
        self.button.layer.cornerRadius = 22
        self.button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        self.button.setTitle("Далее", for: .normal)
        self.button.backgroundColor = .blue
        self.view.addSubview(self.button)
        self.view.bringSubviewToFront(self.button)
    }
    
    func setupLabelsView() {
        self.view.addSubview(self.labelsView)
        self.view.sendSubviewToBack(self.labelsView)
    }
    
    func setupRightButton() {
        self.rightButtonItem = UIBarButtonItem(image: UIImage(named: "rightButtonIcon")?.withRenderingMode(.alwaysOriginal),
                                               style: .plain,
                                               target: self,
                                               action: #selector(rightButtonAction))
        self.rightButtonItem.reactive.isEnabled <~ self.viewModel.isLoading.negate()
        self.navigationItem.rightBarButtonItem = self.rightButtonItem
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.color = .blue
        self.activityIndicator.reactive.isAnimating <~ self.viewModel.isLoading
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubviewToFront(self.activityIndicator)
    }
}

//MARK: - Configure
private extension ViewController {
    func configureViewModel() {
        self.viewModel.delegate = self
    }
    
    func configureCollectionView() {
        self.collectionView.backgroundColor = .white
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.register(CardCollectionCell.self, forCellWithReuseIdentifier: CardCollectionCell.reuseIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
    }

    func configureAnimation() {
        self.collectionView.gemini
        .customAnimation()
        .scaleEffect(.scaleUp)
        .scale(x: scale, y: scale, z: 0)
        .rotationAngle(x: 0, y: 0, z: 0)
        .ease(.easeOutExpo)
        .shadowEffect(.fadeIn)
        .maxShadowAlpha(0.3)
    }
    
    func configureNextViewsIfNeeded(_ visibleIndexPath: IndexPath) {
        if self.pageControl.currentPage != visibleIndexPath.row && self.pageControl.currentPage != self.viewModel.numberOfItems-1 && self.pageControl.currentPage < visibleIndexPath.row {
            self.pageControl.currentPage = visibleIndexPath.row
            self.viewModel.configureTitles(for: visibleIndexPath.row)
        }
    }
    
    func configureFirstViewsIfNeeded(_ visibleIndexPath: IndexPath) {
        if self.pageControl.currentPage != visibleIndexPath.row && self.pageControl.currentPage == self.viewModel.numberOfItems-1 && visibleIndexPath.row == 0 {
            self.pageControl.currentPage = 0
            self.viewModel.configureTitles(for: 0)
        }
    }
}

//MARK: - Actions
private extension ViewController {
    @objc func nextAction() {
        if self.pageControl.currentPage == self.viewModel.numberOfItems-1 {
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            let index = self.pageControl.currentPage + 1
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc func rightButtonAction() {
        loadPills()
    }
    
    func showMessage(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Layout
private extension ViewController {
    func layoutCollectionView() {
        let itemHeight = CardCollectionCell.estimatedSize(viewModel: nil).height
        let size = CGSize(width: self.view.bounds.width, height: itemHeight)
        let origin = CGPoint(x: 0,
                             y: Constants.UI.Sizes.navigationBarHeight + UIDevice.current.topSafeAreaInset)
        self.collectionView.frame = CGRect(origin: origin, size: size)
    }
    
    func flowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let itemSize = CardCollectionCell.estimatedSize(viewModel: nil)
        layout.itemSize = CGSize(width: itemSize.width, height: itemSize.height)
        layout.minimumLineSpacing = CGFloat.leastNormalMagnitude
        let horizontalMargin: CGFloat = (UIScreen.width - itemSize.width)/2
        layout.sectionInset = UIEdgeInsets(top: verticalMargin, left: horizontalMargin, bottom: verticalMargin, right: horizontalMargin)
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func layoutButton() {
        let size = CGSize(width: 100, height: 44)
        let origin = CGPoint(x: self.view.bounds.width - size.width - horizontalMargin,
                             y: self.view.bounds.height - UIDevice.current.bottomSafeAreaInset - size.height - verticalMargin)
        self.button.frame = CGRect(origin: origin, size: size)
    }
    
    func layoutPageControl() {
        let size = CGSize(width: 50, height: 30)
        let origin = CGPoint(x: self.collectionView.frame.midX - size.width/2,
                             y: self.collectionView.frame.maxY + verticalMargin/2)
        self.pageControl.frame = CGRect(origin: origin, size: size).integral
    }
    
    func layoutLabelsView() {
        let origin = CGPoint(x: 0, y: self.pageControl.frame.maxY)
        let size = CGSize(width: self.view.bounds.width,
                          height: self.button.frame.minY - self.pageControl.frame.maxY)
        self.labelsView.frame = CGRect(origin: origin, size: size)
    }
    
    func layoutActivityIndicator() {
        self.activityIndicator.center = self.collectionView.center
    }
}
