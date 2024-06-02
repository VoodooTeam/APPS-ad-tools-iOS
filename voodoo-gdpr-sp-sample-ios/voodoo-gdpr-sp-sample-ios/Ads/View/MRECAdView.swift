//
//  NativeAdView.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Gautier Gedoux on 23/05/2024.
//

import UIKit
import AppLovinSDK
import GoogleMobileAds
import SnapKit

final class MRECAdView: UIView {
    
    private enum Constants {
        static let iconViewSize: CGFloat = 35
        static let smallPadding: CGFloat = 5
        static let verticalPadding: CGFloat = 10
        static let horizontalPadding: CGFloat = 24
        static let horizontalSpacing: CGFloat = 10
        static let adWidth: CGFloat = 300
        static let adHeight: CGFloat = 250
    }

    // MARK: - subviews
    
    private let topContainerView = UIView()
    
    private let iconView: UIImageView = {
        let iconView = UIImageView(image: UIImage(named: "AppIcon"))
        iconView.layer.cornerRadius = Constants.iconViewSize/2
        iconView.backgroundColor = .clear
        iconView.clipsToBounds = true
        return iconView
    }()
    
    private let labelsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.spacing = 0
        return view
    }()
    
    private let adTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.text = "Sponsored"
        return label
    }()

    private let adDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Thanks for helping us making voodoo-gdpr-sp-sample-ios a better app"
        return label
    }()
    
    private let mediaView: UIView = {
        let mediaView = UIView()
        mediaView.layer.cornerRadius = 15
        mediaView.layer.cornerCurve = .continuous
        mediaView.clipsToBounds = true
        mediaView.backgroundColor = UIColor(white: 14/255, alpha: 1)
        return mediaView
    }()
    
    let mrecView: MAAdView
    
    // MARK: - init
    
    init(mrecView: MAAdView, frame: CGRect = .zero) {
        self.mrecView = mrecView
        super.init(frame: frame)
        
        configureViews()
        setLayout()
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        addSubview(topContainerView)
        addSubview(mediaView)
        topContainerView.addSubview(iconView)
        topContainerView.addSubview(labelsStackView)
        labelsStackView.addArrangedSubview(adTitleLabel)
        labelsStackView.addArrangedSubview(adDescriptionLabel)
        mediaView.addSubview(mrecView)
    }
    
    private func setLayout() {
        topContainerView.setContentHuggingPriority(.required, for: .vertical)
        topContainerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(45)
        }
        
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(Constants.horizontalSpacing)
            make.width.height.equalTo(Constants.iconViewSize)
            make.top.equalToSuperview()
        }
        
        labelsStackView.snp.makeConstraints { make in
            make.centerY.equalTo(iconView.snp.centerY)
            make.left.equalTo(iconView.snp.right).offset(10)
            make.right.equalToSuperview().inset(Constants.horizontalSpacing)
        }
        
        mediaView.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(mediaView.snp.width).multipliedBy(1.33)
        }
        
        mrecView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(Constants.adWidth)
            make.height.equalTo(Constants.adHeight)
        }
    }
}
