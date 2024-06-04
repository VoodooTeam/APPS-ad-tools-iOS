# APPS-ad-tools-iOS

Wrapping library around AppLovin and Sourcepoint SDK to simplify the integration of consents and ads and not waste time debugging

For any questions regarding the integration, slack **@Loic Saillant, Sarra Srairi or Gautier Gédoux**


## How to use the demo app

* Run `pod repo update` then `pod install` in your terminal
* Ad the [ad-review file](https://www.notion.so/voodoo/Ads-in-BeReal-f56d438a6b6f4d2a8dd36e941a473fad?pvs=4#3aab2b062611417f920eff85e9c1e44f) at the root of the project and run `ruby AppLovinQualityServiceSetup-ios.rb` in your terminal
* Set any developper team in the build setting
* Run the app


## installation

* copy/paste the Podfile or the element in it at the root of your app folder and change the Target name inside it by your app name
* Add the Common, Ads and Privacy folder to your project
* Run `pod repo update` then `pod install` in your terminal
* Update the `Config.swift` file with the proper credential present [in this file](https://docs.google.com/spreadsheets/d/10GfnMXMkHk4YTUA1xX9oIcqg-vzzLkAdiWUDXRK9lU8/edit?pli=1#gid=0)

## Integration steps

Note: If you want to make things faster for this part you can just:
   * Copy/paste the info.plist file of the sample app into your app
   * Override the `GADApplicationIdentifier` key with the credential from [this doc](https://docs.google.com/spreadsheets/d/10GfnMXMkHk4YTUA1xX9oIcqg-vzzLkAdiWUDXRK9lU8/edit?pli=1#gid=0)
   * Ad the [ad-review file](https://www.notion.so/voodoo/Ads-in-BeReal-f56d438a6b6f4d2a8dd36e941a473fad?pvs=4#3aab2b062611417f920eff85e9c1e44f) at the root of the project and run `ruby AppLovinQualityServiceSetup-ios.rb` in your terminal
   * And everything should work magically

Here is the complete and standard installation

* Add SDK dependencies (see Installation section above)
* Add the dependency for each network in your app
    * Check [this doc](https://developers.applovin.com/en/ios/preparing-mediated-networks) for each network
    * To see if you need additional steps [see this](https://developers.applovin.com/en/ios/testing-networks/mediation-debugger/)
    * You will Generate all required SKAdNetwork keys for your info.plist file [`here`](https://developers.applovin.com/en/ios/overview/skadnetwork/)
    * Bigo requires extra parameters when fetching an ad, [see this](https://www.bigossp.com/guide/sdk/ios/mediation/maxAdapter#5-load-and-show-an-ad)
    * `AppHarbr` is an ad moderation provider. It is compatible with all major ad networks but it's mandatory to follow [this documentation](https://helpcenter.appharbr.com/hc/en-us/articles/17047099021329-Before-Starting#h_01HC2T5SAB7QXVTM8R5R04SX0V) to ensure you have compatible versions for your adapters.
    * Note: by calling `ALSdk.shared().showMediationDebugger()`
      you can launch the mediation debugger and check that every integration is working properly
      (and enable test mode to test a specific network)   
* Configure the ad review plugin by following [the steps here](https://developers.applovin.com/en/ios/overview/integration#enable-ad-review)
* 

To display the ad properly in your app see the next section

## Usage

Ask for consent in you `AppDelegate.swift` file in the `didFinishLaunchingWithOptions` method

```swift
PrivacyManager.shared.configure { analyticsEnabled, adsEnabled, doNotSellEnabled in
if analyticsEnabled {
    //TODO: configure analytics
} else {
    //TODO: stop analytics
}

if adsEnabled {
    AdInitializer.launchAdsSDK(
        hasUserConsent: PrivacyManager.shared.hasUserConsent,
        doNotSell: doNotSellEnabled,
        isAgeRestrictedUser: PrivacyManager.shared.isAgeRestrictedUser
    )
} else {
    AdInitializer.resetAdsSDK()
}
}
```

You will also need to ad a CTA in the settings view to display consent and allowing him to opt out

```swift
PrivacyManager.shared.loadAndDisplayConsentUI()     
```

Please make sure the CTA is visible only when necessary by calling the following method
```swift
PrivacyManager.shared.canShowPrivacyPopup()     
```


Once the Ads are properly initialized (you should see a lot of stuff in the logs) you can start the implementation in the feed

* The main class to display and load ads is called the `AdCoordinator` it's should be the only class your app will interract with
* The `AdCoordinator` "dataSource" is composed of indexes, it gives you an index were you should display an ad and not an ad directly because ads can change at any time
* Once you're ready to diplay an ad it give you a `UIView` containing the method `AdCoordinator.shared.getAdView(for: index)`
* Everytime the feed get a full refresh, you should call `AdCoordinator.shared.reload()`
* The `AdCoordinator` can handle low amount of post in the feed by adding a callback at the feed initiation
```swift
AdCoordinator.shared.firstAdLoadedCallback = {
    guard AdCoordinator.shared.shouldDisplayFooterAd(forDataSize: [YOUR DATA SIZE]) else { return }
    //RELOAD THE FEED
}
```

* In order for the `AdCoordinator` to load and index ads dynamically you should call it on every cell display, see the following example:
```swift
func didDisplay(item: FeedItem) {
    Task {
        guard let index = feedItems.firstIndex(where: { $0.id == item.id }) else { return }
        let adIndex = min(index + AdConfig.fetchOffset, feedItems.count) //We need to add an offset in order to not disturb the view generation
        let surroundingIds = [feedItems[safe: adIndex-1], feedItems[safe: adIndex+1]].compactMap { $0?.id } //this is used for Google Ad Mob integration
        guard AdCoordinator.shared.isAdAvailable(for: adIndex, surroundingIds: surroundingIds) else { return }
       //RELOAD YOUR DATA
    }
}
```

* When loading your data source, you should Use the `AdCoordinator` to insert "Ad items" in the data source
```swift
private func handleLoad() {
    feedItems = prefilledItems
    
    AdCoordinator.shared.allAdIndexes.forEach { index in
        guard index < feedItems.count else { return }
        self.feedItems.insert(FeedItem(id: "ad-\(index)", content: FeedItemContent.adIndex(index)), at: index)
    }
}
```

* Finally in order to display a view you should make a UIViewRepresentable class and call the `AdCoordinator` `getAdView` methods
```swift
struct AdView: UIViewRepresentable {
    
    let adIndex: Int
    
    func makeUIView(context: Context) -> UIView {
        return AdCoordinator.shared.getAdView(for: adIndex)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
```

* Bonus: you can add analytics automaticaly by adding amplitude directly in the `AdAnalytics.swift` file 
```swift
func send(params: [String: Any]) {
    //TODO: amplitude.track(eventType: rawValue ,eventProperties: params)
    print("📊 \(rawValue), adUnit \(params["adUnitIdentifier"] ?? "unknown")")
}
```

## Cool tips

* To test a specific network:
    * you might need to change your location with a VPN
    * some free VPN won't work, NordVPN seems to work
    * the location will depend of the network (some networks only serve in a few countries)
* If loading ads starts to get slow or you get a lot of no-fill, try to reset your advertising ID
