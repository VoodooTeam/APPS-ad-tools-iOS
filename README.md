# APPS-ad-tools-iOS

Wrapping library around AppLovin and Sourcepoint SDK to simplify the integration of consents and ads and not waste time debugging

For any questions regarding the integration, slack **@Loic Saillant, Sarra Srairi or Gautier Gédoux**

## installation

* copy/paste the podfile or the element in it in at the root of your app folder and change the Target name inside it by your app name
* Add the Common, Ads and Privacy folder to your project
* Update the Config.swift file with the proper credential present in this file https://docs.google.com/spreadsheets/d/10GfnMXMkHk4YTUA1xX9oIcqg-vzzLkAdiWUDXRK9lU8/edit?pli=1#gid=0
* Run `pod repo update` then `pod install` in your terminal

## Integration steps

Ask for consent in you `AppDelegate.swift` file in the `didFinishLaunchingWithOptions` method

```swift
        PrivacyManager.shared.configure { analyticsEnabled, adsEnabled in
            if analyticsEnabled {
                //TODO: configure analytics
            } else {
                //TODO: stop analytics
            }
            
            if adsEnabled {
                AdInitializer.launchAdsSDK(
                    hasUserConsent: PrivacyManager.shared.hasUserConsent,
                    doNotSell: PrivacyManager.shared.doNotSellEnabled,
                    isAgeRestrictedUser: PrivacyManager.shared.isAgeRestrictedUser
                )
            } else {
                AdInitializer.resetAdsSDK()
            }
        }
```

You will also need to ad a CTA in the settings view to display consent and allowing him to opt out

```swift
        if PrivacyManager.shared.shouldPrivacyApplicable() {
                //Add your CTA in Setting with the following trigger
                PrivacyManager.shared.loadAndDisplayConsentUI()     
        }
```

* Add SDK dependencies (see Setup section above)
* Check sample `AdsInitiliazer` + https://developers.applovin.com/en/ios/overview/integration/
  for reference
* Add the dependency for each network in your app module (not in the `ads` module, cf above)
    * Check https://developers.applovin.com/en/ios/preparing-mediated-networks for each network
      to see if you need additional steps
    * Note: by calling `ALSdk.shared().showMediationDebugger()`
      you can launch the mediation debugger and check that every integration is working properly
      (and enable test mode to test a specific network,
      see https://developers.applovin.com/en/ios/testing-networks/mediation-debugger/)
* Configure the ad review plugin by following the steps
  here https://developers.applovin.com/en/ios/overview/integration#enable-ad-review
* Initialize AppLovin (+ Apphrbr, Amazon, ...) SDKs by following the official documentation and the
  demo app in `AdsInitiliazer`

To display the ad properly in your app, check the demo app (see README Demo app section)

## Updating AppLovin/network adapter

To update applovin or a network adapter, you first need to check that apphrbr is supporting this
version (they tend to be very slow to support new versions). Check apphrbr support
here https://helpcenter.appharbr.com/hc/en-us/articles/17039424125457-Before-Starting

Once you checked the latest supported version of a network SDK, you'll need to check the latest
applovin adapter for this network. The easiest way is to check on 


## Cool tips

* To test a specific network:
    * you might need to change your location with a VPN
    * some free VPN won't work, NordVPN seems to work
    * the location will depend of the network (some networks only serve in a few countries)
  * in the `configureSettings` block add the following call:

```kotlin
setExtraParameter("test_mode_network", "ADMOB_BIDDING")
```

* If loading ads starts to get slow or you get a lot of no-fill, try to reset your advertising ID

## Network specific

Some networks might require passing extra info when fetching an ad.
This can be done via the `localExtras`:

* When using `LazyListAdMediator` (and `DefaultScrollAdBehaviorEffect`) you can pass
  a `localExtrasProvider` to build this array when a request will be made.
* You can directly pass a `LocalExtrasProvider` instance to
  your `MaxNativeAdClient`/`MaxMRECAdClient` if it's more convenient than forwarding parameters to
  your ui

#### Bigo

* Bigo requires extra parameters when fetching an ad,
  see https://www.bigossp.com/guide/sdk/android/mediation/maxAdapter#5-load-and-show-an-ad
