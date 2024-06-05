//
//  NativeAdView.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Gautier Gedoux on 23/05/2024.
//

import UIKit
import AppLovinSDK
import GoogleMobileAds

final class NativeAdView: MANativeAdView {

    private enum Constants {
        static let iconViewSize: CGFloat = 36
        static let smallPadding: CGFloat = 8
        static let horizontalSpacing: CGFloat = 8
        static let topContainerHeight: CGFloat = 48
        static let mediaViewHorizontalPadding: CGFloat = 4
        static let mediaCornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 16
        static let descriptionLabelFont: UIFont = .systemFont(ofSize: 12, weight: .semibold)
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
    
    private let adDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Constants.descriptionLabelFont
        label.tag = 14
        label.numberOfLines = 0
        return label
    }()
        
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
        CGSize(width: 0, height: Constants.topContainerHeight
               + mediaViewHeight
               + NativeAdActionButtonView.PublicConstants.height
               + Constants.descriptionLabelFont.calculateHeight(text: adDescriptionLabel.text ?? "", width: UIScreen.main.bounds.width - 2 * Constants.horizontalPadding)
               + Constants.verticalPadding
               + Constants.smallPadding
        )
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
        
        [topContainerView, mediaAndButtonContainerView, hiddenAdvertiserLabel, adOptionView, adDescriptionLabel].forEach { googleContainerView.addSubview($0) }
        [mediaView, actionButtonView].forEach { mediaAndButtonContainerView.addSubview($0) }
        topContainerView.addSubview(iconView)
        topContainerView.addSubview(labelsStackView)
        labelsStackView.addArrangedSubview(adTitleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)

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
        
        googleContainerView.pinToSuperview()

        topContainerView.setContentHuggingPriority(.required, for: .vertical)
        topContainerView.pinToSuperview([.left, .right, .top])
        topContainerView.constraint([.height], constant: Constants.topContainerHeight)

        iconView.pinToSuperview([.left], constant: Constants.horizontalSpacing)
        iconView.pinToSuperview([.top])
        iconView.constraint([.height, .width], constant: Constants.iconViewSize)

        
        adOptionView.setContentHuggingPriority(.required, for: .horizontal)
        adOptionView.pinToSuperview([.right], constant: Constants.smallPadding)
        adOptionView.pin(.centerY, to: topContainerView)
        
        labelsStackView.pin(.centerY, to: iconView)
        labelsStackView.pin(.left, to: iconView, otherViewAttribute: .right, constant: Constants.horizontalSpacing)
        labelsStackView.pinToSuperview([.right], constant: Constants.horizontalSpacing)

        mediaAndButtonContainerView.pin(.top, to: topContainerView, otherViewAttribute: .bottom)
        mediaAndButtonContainerView.pinToSuperview([.left, .right], constant: Constants.mediaViewHorizontalPadding)

        mediaView.pinToSuperview([.top, .left, .right])

        actionButtonView.pinToSuperview([.bottom, .left, .right])
        actionButtonView.pin(.top, to: mediaView, otherViewAttribute: .bottom)
        
        adDescriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        adDescriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        adDescriptionLabel.pin(.top, to: mediaAndButtonContainerView, otherViewAttribute: .bottom, constant: Constants.smallPadding)
        adDescriptionLabel.pinToSuperview([.left, .right], constant: Constants.horizontalPadding)
        adDescriptionLabel.pinToSuperview([.bottom], constant: Constants.verticalPadding)
    }
}

private extension UIFont {
    func calculateHeight(text: String, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin],
                                            attributes: [NSAttributedString.Key.font: self],
                                            context: nil)
        return boundingBox.height.rounded(.up)
    }
}
