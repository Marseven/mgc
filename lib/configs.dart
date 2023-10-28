import 'package:country_picker/country_picker.dart';

/// App Name
const APP_NAME = "Manga Golf Club";

/// App Icon src
const APP_ICON = "assets/app_icon.png";

/// Splash screen image src
const SPLASH_SCREEN_IMAGE = 'assets/images/splash_image.png';

/// OneSignal Notification App Id
const ONESIGNAL_APP_ID = '3df95624-b87e-43a7-a3fe-0c367b788c06';

/// NOTE: Do not add slash (/) or (https://) or (http://) at the end of your domain.
const WEB_SOCKET_DOMAIN = "mangagolfclub.com";

/// NOTE: Do not add slash (/) at the end of your domain.
const DOMAIN_URL = 'https://mangagolfclub.com';
const BASE_URL = '$DOMAIN_URL/wp-json/';

/// AppStore Url
const IOS_APP_LINK = 'https://mangagolfclub.com/';

/// Terms and Conditions URL
const TERMS_AND_CONDITIONS_URL = '$DOMAIN_URL/terms-condition/';

/// Privacy Policy URL
const PRIVACY_POLICY_URL = '$DOMAIN_URL/privacy-policy-2/';

/// Support URL
const SUPPORT_URL = 'https://mangagolfclub.com';

/// AdMod Id
// Android
const mAdMobAppId = '';
const mAdMobBannerId = '';

// iOS
const mAdMobAppIdIOS = '';
const mAdMobBannerIdIOS = '';

const mTestAdMobBannerId = 'ca-app-pub-3940256099942544/630438111';

/// Woo Commerce keys

// live
const CONSUMER_KEY = 'ck_4baced5b61461927067acca27f000d8d7fa587c1';
const CONSUMER_SECRET = 'cs_e74206f22e804ae35e4452e6078012310d5815fa';

/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';
const STRIPE_CURRENCY_CODE = 'INR';

/// RAZORPAY PAYMENT DETAIL
const RAZORPAY_CURRENCY_CODE = 'INR';

Country defaultCountry() {
  return Country(
    phoneCode: '241',
    countryCode: 'GA',
    e164Sc: 241,
    geographic: true,
    level: 1,
    name: 'Gabon',
    example: '9123456789',
    displayName: 'Gabon (GA) [+241]',
    displayNameNoCountryCode: 'Gabon (GA)',
    e164Key: '241-GA-0',
    fullExampleWithPlusSign: '+24174228306',
  );
}
