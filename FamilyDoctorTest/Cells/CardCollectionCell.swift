//
//  CardCollectionCell.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 23/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit
import Gemini

private let aspectRatio: CGFloat = 305/250

final class CardCollectionCellViewModel {
    let imageUrlString: String
    init(img: String) {
        self.imageUrlString = img
    }
}

final class CardCollectionCell: GeminiCell, Reusable {
    private let imageView = UIImageView()
    private var viewModel: CardCollectionCellViewModel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutImageview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }
}

extension CardCollectionCell: ConfigurableCollectionCell {
    func bind(viewModel: CardCollectionCellViewModel) {
        self.viewModel = viewModel
        self.imageView.setImageAsync(link: self.viewModel.imageUrlString,
                                     size: CardCollectionCell.estimatedSize(),
                                     until: self.reactive.prepareForReuse,
                                     recoveryImage: UIImage())

    }
    
    static func estimatedSize(viewModel: CardCollectionCellViewModel? = nil) -> CGSize {
        let navigationBarHeight = Constants.UI.Sizes.navigationBarHeight
        let verticalMargin: CGFloat = 10
        let height = (UIScreen.height - UIDevice.current.topSafeAreaInset - UIDevice.current.bottomSafeAreaInset - navigationBarHeight)/2 - verticalMargin*2
        let width = height/aspectRatio
        let size = CGSize(width: width, height: height)
        return size
    }
}

private extension CardCollectionCell {
    func setupImageView() {
        self.imageView.contentMode = .scaleToFill
        self.imageView.backgroundColor = .gray
        self.imageView.clipsToBounds = true
//        self.imageView.layer.borderColor = UIColor.gray.cgColor
//        self.imageView.layer.borderWidth = 1
        self.imageView.layer.cornerRadius = Constants.UI.Sizes.cornerRadius
        self.contentView.addSubview(self.imageView)
    }
    
    func layoutImageview() {
        self.imageView.frame = self.contentView.bounds
    }
}
