import 'dart:convert';

import 'package:cirilla/mixins/mixins.dart';
import 'package:cirilla/store/auth/auth_store.dart';
import 'package:cirilla/store/cart/cart_store.dart';
import 'package:cirilla/themes/default/checkout/step_success.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cirilla/express_checkout.dart';

class CirillaExpressCheckout extends StatefulWidget {
  final Function? addToCart;
  // If the widget located in the cart page, needAddToCart is false
  final bool? needAddToCart;

  final bool? isFull;

  const CirillaExpressCheckout({super.key, this.addToCart, this.needAddToCart = true, this.isFull = false});

  @override
  State<CirillaExpressCheckout> createState() => _CirillaExpressCheckoutState();
}

class _CirillaExpressCheckoutState extends State<CirillaExpressCheckout> with LoadingMixin, SnackMixin {
  late CartStore _cartStore;
  bool loading = false;

  @override
  void didChangeDependencies() {
    _cartStore = Provider
        .of<AuthStore>(context)
        .cartStore;
    super.didChangeDependencies();
  }

  Future<Map<String, dynamic>?> addToCart() async {
    if ( widget.addToCart == null ) return null;
    return await widget.addToCart!(false, false, false, true);
  }

  String isEmpty(value, String defaultValue) {
    if (value == null || value.isEmpty || value == '') {
      return defaultValue;
    }
    return value;
  }

  Future<void> onApplePayResult(Map<String, dynamic> paymentResult) async {

    if (paymentResult['status'] == 'error') {
      setState(() {
        loading = false;
      });
    }

    String shippingFirstName = paymentResult['shippingContact']?['name']?['givenName'] ?? '';
    String shippingLastName = paymentResult['shippingContact']?['name']?['familyName'] ?? '';
    String shippingEmail = paymentResult['shippingContact']?['emailAddress'] ?? '';
    String shippingPhone = paymentResult['shippingContact']?['phoneNumber'] ?? '';

    String billingFirstName = paymentResult['billingContact']?['name']?['givenName'] ?? '';
    String billingLastName = paymentResult['billingContact']?['name']?['familyName'] ?? '';
    String billingEmail = paymentResult['billingContact']?['emailAddress'] ?? '';
    String billingPhone = paymentResult['billingContact']?['phoneNumber'] ?? '';

    // Country
    // String country = paymentResult['shippingContact']?['postalAddress']?['country'] ?? '';
    String isoCountryCode = paymentResult['shippingContact']?['postalAddress']?['isoCountryCode'] ?? '';
    String postalCode = paymentResult['shippingContact']?['postalAddress']?['postalCode'] ?? '';
    String city = paymentResult['shippingContact']?['postalAddress']?['city'] ?? '';
    String street = paymentResult['shippingContact']?['postalAddress']?['street'] ?? '';
    String state = paymentResult['shippingContact']?['postalAddress']?['state'] ?? '';


    Map<String, dynamic> paymentData = {
      'billing_address': {
        'first_name': isEmpty(billingFirstName, shippingFirstName),
        'last_name': isEmpty(billingLastName, shippingLastName),
        'email': isEmpty(billingEmail, shippingEmail),
        'phone': isEmpty(billingPhone, shippingPhone),
        'country': isoCountryCode,
        'address_1': street,
        'city': city,
        'state': state,
        'postcode': postalCode,
      },
      'shipping_address': {
        'first_name': isEmpty(shippingFirstName, billingFirstName),
        'last_name': isEmpty(shippingLastName, billingLastName),
        'email': isEmpty(shippingEmail, billingEmail),
        'phone': isEmpty(shippingPhone, billingPhone),
        'country': isoCountryCode,
        'address_1': street,
        'city': city,
        'state': state,
        'postcode': postalCode,
      }
    };

    final str = paymentResult['token'];
    final bytes = utf8.encode(str);
    final token = base64.encode(bytes);

    Map<String, dynamic> options = {};

    switch(ApplePayConfig.paymentMethod) {
      case 'stripe':
        options = {
          'payment_method': ApplePayConfig.paymentMethod,
          'payment_method_apple': 'apple',
          'stripe_token': paymentResult['stripe_token'],
          'payment_request_type': 'apple_pay',
        };
        break;
      case 'hyperpay_applepay':
        options = {
          'payment_method': ApplePayConfig.paymentMethod,
          'payment_method_apple': 'apple',
          'token': token,
        };
        break;
    }

    try {
      await _cartStore.checkoutStore.checkout(
        [],
        billingOptions: paymentData['billing_address'],
        shippingOptions: paymentData['shipping_address'],
        options: options,
      );
      setState(() {
        loading = false;
      });
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Success()),
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (mounted) showError(context, e);
    }
    return;
  }

  Future<Map<String, dynamic>?> getCart() async {

    setState(() {
      loading = true;
    });

    Map<String,dynamic>? totals = _cartStore.cartData?.totals;

    if (totals == null) return null;

    return {
      'totals': totals
    };
  }

  Future<Map<String, dynamic>?> addCart() async {
    setState(() {
      loading = true;
    });
    if ( widget.addToCart == null ) return null;
    return await widget.addToCart!(false, false, false, true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          SizedBox(
            height: 48,
            width: widget.isFull == true ? double.infinity : null,
            child: ExpressApplePayButton(
              countryCode: ApplePayConfig.countryCode,
              currencyCode: ApplePayConfig.currencyCode,
              displayName: ApplePayConfig.displayName,
              merchantIdentifier: ApplePayConfig.merchantIdentifier,
              addToCart: widget.needAddToCart == true ? addCart : getCart,
              progressCheckout: onApplePayResult,
            ),
          ),
          if(loading) Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: iOSLoading(context, color: Colors.white, size: 12),
              ),
            ),
          ),
        ]
    );
  }
}

class Success extends StatelessWidget with AppBarMixin {
  const Success({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: baseStyleAppBar(context, title: ''),
        body: const StepSuccess());
  }
}

