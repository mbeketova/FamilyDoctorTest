//
//  InformationView.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

private let horizontalMargin: CGFloat = 30
private let verticalMargin: CGFloat = 30

final class InformationView: UIView {

    var changedTitles = MutableProperty<Pill?>(nil)

    private var viewModel: InformationViewModel!
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        setupSubtitleLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTitleLabel()
        layoutSubtitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(viewModel: InformationViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = self.viewModel.pill.value.name
        self.subtitleLabel.text = self.viewModel.pill.value.displayDescription
        self.reactive.changedTitles <~ self.viewModel.pill
        setNeedsLayout()
    }
    
    func configure(newTitle: String) {
        hide(label: self.titleLabel, newText: newTitle) { [weak self] in
            self?.setNeedsLayout()
            self?.show(label: self?.titleLabel ?? UILabel())
        }
    }
    
    func configure(newSubtitle: String) {
        hide(label: self.subtitleLabel, newText: newSubtitle) { [weak self] in
            self?.setNeedsLayout()
            self?.show(label: self?.subtitleLabel ?? UILabel())
        }
    }
    
}

//MARK: - Setup
private extension InformationView {
    func setupTitleLabel() {
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        self.titleLabel.textColor = .black
        self.titleLabel.numberOfLines = 2
        addSubview(self.titleLabel)
    }

    func setupSubtitleLabel() {
        self.subtitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        self.subtitleLabel.textColor = .placeholderText
        self.subtitleLabel.numberOfLines = 3
        addSubview(self.subtitleLabel)
    }
}

//MARK: - Layout
private extension InformationView {
    func layoutTitleLabel() {
        let origin = CGPoint(x: horizontalMargin, y: verticalMargin)
        let maxSize = labelMaxSize()
        let size = self.titleLabel.sizeThatFits(maxSize)
        self.titleLabel.frame = CGRect(origin: origin, size: CGSize(width: maxSize.width, height: size.height))
    }
    
    func layoutSubtitleLabel() {
        let origin = CGPoint(x: horizontalMargin,
                             y: self.titleLabel.frame.maxY + verticalMargin)
        let maxSize = labelMaxSize()
        let size = self.subtitleLabel.sizeThatFits(maxSize)
        self.subtitleLabel.frame = CGRect(origin: origin, size: CGSize(width: maxSize.width, height: size.height))
    }
    
    func labelMaxSize() -> CGSize {
        return CGSize(width: self.bounds.width - horizontalMargin*2, height: (self.bounds.height - verticalMargin*2)/2)
    }
}

//MARK: - Animations
private extension InformationView {
    func hide(label: UILabel, newText: String, closure:@escaping ()->()) {
        let alpha: CGFloat = 0
        UIView.animate(withDuration: 0.2, animations: {
            label.alpha = alpha
        }) { (isComplete) in
            label.text = newText
            closure()
        }
    }
    
    func show(label: UILabel) {
        let alpha: CGFloat = 1
        UIView.animate(withDuration: 0.2) {
            label.alpha = alpha
        }
    }
}

//MARK: - Reactive
extension Reactive where Base: InformationView {
    var changedTitles: BindingTarget<Pill?> {
        return makeBindingTarget({ (view, newPill: Pill?) in
            guard let pill = newPill else { return  }
            view.configure(newTitle: pill.name)
            view.configure(newSubtitle: pill.displayDescription)
        })
    }
    
}
