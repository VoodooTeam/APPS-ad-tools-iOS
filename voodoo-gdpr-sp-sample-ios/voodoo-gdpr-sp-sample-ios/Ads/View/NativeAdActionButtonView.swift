//
//  NativeAdActionButtonView.swift
//  Drop
//
//  Created by Loïc Saillant on 04/06/2024.
//

import UIKit

final class NativeAdActionButtonView: UIView {
    
    enum PublicConstants {
        static let height: CGFloat = 48
    }
    
    private struct Constants {
        static let imageViewSize: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let firstBackgroundColor: UIColor = .clear
        static let firstForegroundColor: UIColor = .white
        static let secondBackgroundColor: UIColor = .white
        static let secondForegroundColor: UIColor = .black
    }
    
    // MARK: - Subviews
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.firstForegroundColor
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let disclosureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = Constants.firstForegroundColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        configureViews()
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Instance
    
    func refreshTitle() {
        titleLabel.text = button.titleLabel?.text
        button.setTitle(nil, for: .normal)
    }
    
    private func configureViews() {
        backgroundColor = Constants.firstBackgroundColor
        [titleLabel, disclosureImageView, button].forEach { addSubview($0)}
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.backgroundColor = Constants.secondBackgroundColor
                self?.titleLabel.textColor = Constants.secondForegroundColor
                self?.disclosureImageView.tintColor = Constants.secondForegroundColor
            }
        })
    }
    
    private func setLayout() {
        constraint([.height], constant: PublicConstants.height)

        titleLabel.pinToSuperview([.centerY])
        titleLabel.pinToSuperview([.left], constant: Constants.horizontalPadding)
        
        disclosureImageView.pinToSuperview([.centerY])
        disclosureImageView.pinToSuperview([.right], constant: Constants.horizontalPadding)
        disclosureImageView.pin(.left, to: titleLabel, otherViewAttribute: .right)
        disclosureImageView.constraint([.height, .width], constant: Constants.imageViewSize)
        
        button.pinToSuperview()
    }
}
