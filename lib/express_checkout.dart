/// Express Checkout Package
export 'package:cirilla/widgets/cirilla_express_checkout_dev.dart';

class ApplePayConfig {
  /// Merchant identifier
  static const String merchantIdentifier = 'merchant.io.rnlab.cirilla';

  /// Display name
  static const String displayName = 'Example Merchant';

  /// Country code
  static const String countryCode = 'US';

  /// Currency code
  static const String currencyCode = 'USD';

  /// Payment method [stripe, hyperpay_applepay]
  static const String paymentMethod = 'hyperpay_applepay';
}
