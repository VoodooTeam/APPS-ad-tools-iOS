//
//  NativeAdView.swift
//  Drop
//
//  Created by Gautier Gedoux on 23/05/2024.
//

import UIKit
import AppLovinSDK
import GoogleMobileAds
import SnapKit

final class NativeAdView: MANativeAdView {
    

    private enum Constants {
        static let iconViewSize: CGFloat = 35
        static let smallPadding: CGFloat = 5
        static let verticalPadding: CGFloat = 10
        static let horizontalPadding: CGFloat = 24
        static let horizontalSpacing: CGFloat = 10
    }

    // MARK: - subviews
    
    // ???: (Loic Saillant) 2023/10/19 According to doc https://dash.applovin.com/documentation/mediation/ios/ad-formats/native-manual
    // we should ad a wrapper view to enable google to render ads
    private let googleContainerView: GADNativeAdView = {
        let view = GADNativeAdView()
        view.tag = AdConfig.gadNativeAdViewTag
        return view
    }()
    
    private let topContainerView = UIView()
    
    private let iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.layer.cornerRadius = Constants.iconViewSize/2
        iconView.tag = 11
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
        label.tag = 12
        return label
    }()
    
    private let hiddenAdvertiserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.tag = 13
        label.isHidden = true
        return label
    }()
    
    private let adDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.tag = 14
        return label
    }()

    
    private let mediaView: UIView = {
        let mediaView = UIView()
        mediaView.tag = 15
        return mediaView
    }()
    
    private let adOptionView: UIView = {
        let adOptionView = UIView()
        adOptionView.tag = 16
        return adOptionView
    }()

    private let actionContainerView = UIView()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 22/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 12
        button.layer.borderColor = UIColor(white: 68/255, alpha: 1).cgColor
        button.layer.borderWidth = 2
        button.tag = 17
        return button
    }()
    
    // MARK: - init
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        configureViews()
        setLayout()
        bindViews()
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(for ad: MAAd) {
        ad.nativeAd?.prepare(
            forInteractionClickableViews: [topContainerView, iconView, mediaView, actionButton].compactMap { $0 },
            withContainer: self
        )
    }
    
    func handleBidMachine() {
        guard let titleLabelGestureRecognizer = actionButton.titleLabel?.gestureRecognizers?.first else { return }
        actionButton.addGestureRecognizer(titleLabelGestureRecognizer)
    }
    
    private func configureViews() {
        addSubview(googleContainerView)
        
        [topContainerView, mediaView, actionContainerView, hiddenAdvertiserLabel, adOptionView].forEach { googleContainerView.addSubview($0) }
        topContainerView.addSubview(iconView)
        topContainerView.addSubview(labelsStackView)
        labelsStackView.addArrangedSubview(adTitleLabel)
        labelsStackView.addArrangedSubview(adDescriptionLabel)
        actionContainerView.addSubview(actionButton)

        titleLabel = adTitleLabel
        bodyLabel = adDescriptionLabel
        optionsContentView = adOptionView
        callToActionButton = actionButton
        iconImageView = iconView
        mediaContentView = mediaView
        advertiserLabel = hiddenAdvertiserLabel
    }
    
    private func bindViews() {
        let adViewBinder = MANativeAdViewBinder.init { [weak self] builder in
            guard let self = self else { return }
            builder.titleLabelTag = self.adTitleLabel.tag
            builder.optionsContentViewTag = self.adOptionView.tag
            builder.bodyLabelTag = self.adDescriptionLabel.tag
            builder.callToActionButtonTag = self.actionButton.tag
            builder.iconImageViewTag = self.iconView.tag
            builder.mediaContentViewTag = self.mediaView.tag
            builder.advertiserLabelTag = self.hiddenAdvertiserLabel.tag
        }
        bindViews(with: adViewBinder)
    }
    
    private func setLayout() {
        
        googleContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
        
        adOptionView.setContentHuggingPriority(.required, for: .horizontal)
        adOptionView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(Constants.smallPadding)
            make.centerY.equalTo(topContainerView)
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

        actionContainerView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(mediaView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        actionButton.snp.makeConstraints { make in
            make.top.equalTo(actionContainerView).offset(10)
            make.height.equalTo(40)
            make.width.equalTo(250)
            make.centerX.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bringSubviewToFront(actionButton)

        //HACK for updating the AppLovin mediaView
        guard let appLovinMediaView = mediaView.subviews.first, appLovinMediaView.layer.cornerCurve != .continuous else { return }
        appLovinMediaView.layer.cornerRadius = 15
        appLovinMediaView.layer.cornerCurve = .continuous
        appLovinMediaView.clipsToBounds = true
        appLovinMediaView.backgroundColor = UIColor(white: 14/255, alpha: 1)
    }
}
