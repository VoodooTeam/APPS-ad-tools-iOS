# APPS-ad-tools-iOS

Wrapping library around AppLovin and Sourcepoint SDK to simplify the integration of consents and ads and not waste time debugging

For any questions regarding the integration, slack **@Loic Saillant, Sarra Srairi or Gautier Gédoux**

## installation

* copy/paste the podfile or the element in it in your apps folder
* Add the Common, Ads and Privacy folder to your project

## Demo app

The sampe module is a demo app with integration of ads in a list (`LazyColumn`) of posts like
instagram.

* Add your GAID in `AdsInitiliazer` to the `setTestDeviceAdvertisingIds` call
* [MainActivity](sample/src/main/java/io/voodoo/apps/ads/MainActivity.kt) handles getting user's
  consent to use collect data/use ads. Only after this consent is given we can initialize the
  various ads SDK.
* AppLovin SDK + Apphrbr (moderation) initialization
  in [AdsInitializer](sample/src/main/java/io/voodoo/apps/ads/feature/ads/AdsInitiliazer.kt) class
  (called from `MainActivity` after the consent is given)
* [AdArbitrageurFactory](sample/src/main/java/io/voodoo/apps/ads/feature/ads/AdArbitrageurFactory.kt):
  `AdClient` + `AdArbitrageur` instantiation
* [AdTracker](sample/src/main/java/io/voodoo/apps/ads/feature/ads/AdTracker.kt):
  Base tracking implementation that you probably need to implement
* [FeedScreen](sample/src/main/java/io/voodoo/apps/ads/feature/feed/FeedScreen.kt): main screen,
  list of post
* [FeedAdItem](sample/src/main/java/io/voodoo/apps/ads/feature/feed/component/FeedAdItem.kt):
  composable to display the ad item
    * For native ads, you need to implement the whole layout in an XML layout file with views for
      each element (title, body, icon, ...) (applovin requirement). You'll need to pass a view
      factory instance to your `MaxNativeAdClient`.
      See [MaxNativeAdViewFactory](sample/src/main/java/io/voodoo/apps/ads/feature/ads/MaxNativeAdViewFactory.kt)
      for sample.
      see https://developers.applovin.com/en/android/ad-formats/native-ads#manual
    * For MREC ads, the applovin SDK provides us with a 300x250 view, and we can use it as we want.
      We can integrate this in a composable, like we do in the `FeedMRECAdItem` comopsable.
      see https://developers.applovin.com/en/android/ad-formats/banner-mrec-ads#mrecs

Because ads are loaded and can take time to be available, it creates a lot of edge cases, and we
need to insert them dynamically once loaded into the LazyList.

The [LazyListAdMediator](ads-compose/src/main/java/io/voodoo/apps/ads/compose/lazylist/LazyListAdMediator.kt)
class available in the `ads-compose` artifact provides a default integration of this behavior and
tries to handle most edge cases for the behavior wanted in an app like this.

For a seemless integration in an existing LazyList, you can use the overloads
of `LazyListScope.items` that takes a `adMediator: LazyListAdMediator` parameter
(see `FeedScreenContent` composable).

## Artifacts

* `ads-api`: abstraction layer with no dependency to applovin/any network
* `ads-compose`: provides some useful classes/extensions to use the lib with compose.
    * `LazyListAdMediator` is a basic integration of the ads into a LazyList (used in sample app)
* `ads-applovin`: the implementation of the API with applovin SDK dependency
    * apphrbr is included until we find a clean API to extract it in another module like we did for
      amazon's integration
* `ads-applovin-plugin-*`: every extension plugin that might be required for a network to be
  integrated (eg: amazon for mrec in `AmazonMRECAdClientPlugin`)
* TODO `ads-noop`: a dummy implementation of `ads-api` to build your app without ads (eg: for faster
  debug build)

## Integration steps

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
applovin adapter for this network. The easiest way is to check on mvnrepository.com
(eg for amazon: https://mvnrepository.com/artifact/com.applovin.mediation/amazon-tam-adapter).

To see the latest adreview plugin version, check
here https://artifacts.applovin.com/android/com/applovin/quality/AppLovinQualityServiceGradlePlugin/maven-metadata.xml

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
