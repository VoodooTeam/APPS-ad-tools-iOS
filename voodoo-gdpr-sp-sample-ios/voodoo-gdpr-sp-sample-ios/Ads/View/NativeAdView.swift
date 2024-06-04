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

final class NativeAdView: MANativeAdView {
//mettre des multiples de 8
    private enum Constants {
        static let iconViewSize: CGFloat = 36
        static let smallPadding: CGFloat = 8
        static let horizontalSpacing: CGFloat = 8
        static let topContainerHeight: CGFloat = 48
        static let bottomContainerHeight: CGFloat = 48
        static let mediaViewHorizontalPadding: CGFloat = 4
        static let mediaCornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 8
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
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Sponsored"
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
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.tag = 14
        label.numberOfLines = 0
        return label
    }()

    private let mediaAndButtonContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.mediaCornerRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 14/255, alpha: 1)
        return view
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
    
    private let actionButtonView: NativeAdActionButtonView = {
        let view = NativeAdActionButtonView()
        view.button.tag = 17
        return view
    }()
    
    private let bottomContainerView = UIView()
    
    // MARK: - Properties
    
    private var aspectRatio: CGFloat = 1.33
    private var mediaViewHeight: CGFloat {
        (UIScreen.main.bounds.width - 2 * Constants.mediaViewHorizontalPadding) * aspectRatio
    }
    
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
    
    // MARK: - UIView
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: Constants.topContainerHeight + mediaViewHeight + NativeAdActionButtonView.PublicConstants.height + Constants.bottomContainerHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        if let appLovinMediaView = mediaView.subviews.first, let imageView = appLovinMediaView.subviews.first as? UIImageView {
            aspectRatio = imageView.intrinsicContentSize.height / imageView.intrinsicContentSize.width
        }
        actionButtonView.refreshTitle()
    }
    
    // MARK: - Instance
    
    func prepare(for ad: MAAd) {
        ad.nativeAd?.prepare(
            forInteractionClickableViews: [topContainerView, iconView, mediaView, actionButtonView].compactMap { $0 },
            withContainer: self
        )
    }
    
    func handleBidMachine() {
        guard let titleLabelGestureRecognizer = actionButtonView.button.titleLabel?.gestureRecognizers?.first else { return }
        actionButtonView.button.addGestureRecognizer(titleLabelGestureRecognizer)
    }
    
    // MARK: - Private
    
    private func configureViews() {
        addSubview(googleContainerView)
        
        [topContainerView, mediaAndButtonContainerView, hiddenAdvertiserLabel, adOptionView, bottomContainerView].forEach { googleContainerView.addSubview($0) }
        [mediaView, actionButtonView].forEach { mediaAndButtonContainerView.addSubview($0) }
        topContainerView.addSubview(iconView)
        topContainerView.addSubview(labelsStackView)
        labelsStackView.addArrangedSubview(adTitleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)
        bottomContainerView.addSubview(adDescriptionLabel)

        titleLabel = adTitleLabel
        bodyLabel = adDescriptionLabel
        optionsContentView = adOptionView
        callToActionButton = actionButtonView.button
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
            builder.callToActionButtonTag = self.actionButtonView.button.tag
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
            make.height.equalTo(Constants.topContainerHeight)
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
        
        mediaAndButtonContainerView.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom)
            make.left.right.equalToSuperview().inset(Constants.mediaViewHorizontalPadding)
        }
        
        mediaView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        actionButtonView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(mediaView.snp.bottom)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(mediaAndButtonContainerView.snp.bottom)
            make.height.equalTo(Constants.bottomContainerHeight)
        }
        
        adDescriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.horizontalPadding)
            make.centerY.equalToSuperview()
        }
    }
}
