import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../providers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.bookingId,
  });

  final int bookingId;

  @override
  ConsumerState<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends ConsumerState<PaymentScreen> {
  late final Razorpay _razorpay;

  bool _isStartingPayment = false;
  bool _isVerifyingPayment = false;
  bool _paymentSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _startPayment() async {
    if (_isStartingPayment || _isVerifyingPayment) {
      return;
    }

    setState(() {
      _isStartingPayment = true;
      _errorMessage = null;
    });

    ref.read(paymentErrorProvider.notifier).state = null;

    try {
      final paymentService =
      ref.read(paymentServiceProvider);

      final response =
      await paymentService.createOrder(
        bookingId: widget.bookingId,
      );

      if (!mounted) {
        return;
      }

      final success =
          response['success'] == true;

      if (!success) {
        throw Exception(
          response['message'] ??
              response['detail'] ??
              'Unable to create payment order.',
        );
      }

      final orderId =
      response['order_id']?.toString();

      final keyId =
      response['key_id']?.toString();

      final currency =
          response['currency']?.toString() ?? 'INR';

      final amount =
      _parseAmount(response['amount']);

      if (orderId == null ||
          orderId.isEmpty) {
        throw Exception(
          'Payment order ID was not received.',
        );
      }

      if (keyId == null || keyId.isEmpty) {
        throw Exception(
          'Razorpay Key ID was not received.',
        );
      }

      if (amount <= 0) {
        throw Exception(
          'Invalid payment amount received.',
        );
      }

      final options = <String, dynamic>{
        'key': keyId,
        'amount': amount,
        'currency': currency,
        'name': 'RentKaro',
        'description':
        'Vehicle rental booking payment',
        'order_id': orderId,
        'timeout': 300,
        'prefill': <String, dynamic>{},
        'notes': <String, dynamic>{
          'booking_id':
          widget.bookingId.toString(),
        },
        'theme': <String, dynamic>{
          'color': '#1565C0',
        },
      };

      _razorpay.open(options);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            _cleanErrorMessage(error);
      });

      ref.read(paymentErrorProvider.notifier).state =
          _cleanErrorMessage(error);
    } finally {
      if (mounted) {
        setState(() {
          _isStartingPayment = false;
        });
      }
    }
  }

  Future<void> _handlePaymentSuccess(
      PaymentSuccessResponse response,
      ) async {
    final paymentId =
        response.paymentId;

    final orderId =
        response.orderId;

    final signature =
        response.signature;

    if (paymentId == null ||
        paymentId.isEmpty ||
        orderId == null ||
        orderId.isEmpty ||
        signature == null ||
        signature.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
        'Payment was received, but verification details are incomplete.';
      });

      return;
    }

    setState(() {
      _isVerifyingPayment = true;
      _errorMessage = null;
    });

    ref.read(paymentErrorProvider.notifier).state = null;

    try {
      final paymentService =
      ref.read(paymentServiceProvider);

      final verification =
      await paymentService.verifyPayment(
        bookingId: widget.bookingId,
        razorpayOrderId: orderId,
        razorpayPaymentId: paymentId,
        razorpaySignature: signature,
      );

      if (!mounted) {
        return;
      }

      if (verification['success'] != true) {
        throw Exception(
          verification['message'] ??
              verification['detail'] ??
              'Payment verification failed.',
        );
      }

      setState(() {
        _paymentSuccess = true;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            _cleanErrorMessage(error);
      });

      ref.read(paymentErrorProvider.notifier).state =
          _cleanErrorMessage(error);
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingPayment = false;
        });
      }
    }
  }

  void _handlePaymentError(
      PaymentFailureResponse response,
      ) {
    if (!mounted) {
      return;
    }

    final message =
    response.message?.toString();

    setState(() {
      _errorMessage =
      message != null && message.isNotEmpty
          ? message
          : 'Payment failed. Please try again.';
    });

    ref.read(paymentErrorProvider.notifier).state =
        _errorMessage;
  }

  void _handleExternalWallet(
      ExternalWalletResponse response,
      ) {
    if (!mounted) {
      return;
    }

    final walletName =
    response.walletName?.toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          walletName != null &&
              walletName.isNotEmpty
              ? 'External wallet selected: $walletName'
              : 'External wallet selected.',
        ),
      ),
    );
  }

  int _parseAmount(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return double.tryParse(value)?.round() ?? 0;
    }

    return 0;
  }

  String _cleanErrorMessage(Object error) {
    final message =
    error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  void _goBackToBooking() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentSuccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment Successful'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color:
                      Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Payment Successful',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your payment has been verified and your booking is confirmed.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goBackToBooking,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'View Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final isLoading =
        _isStartingPayment ||
            _isVerifyingPayment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete Payment',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Booking #${widget.bookingId}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Secure Payment',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'You will be redirected to Razorpay Checkout to complete your payment securely.',
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  margin:
                  const EdgeInsets.only(bottom: 20),
                  padding:
                  const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                    Colors.red.withOpacity(0.08),
                    borderRadius:
                    BorderRadius.circular(12),
                    border: Border.all(
                      color:
                      Colors.red.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isVerifyingPayment)
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(16),
                  margin:
                  const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(12),
                    color:
                    Colors.blue.withOpacity(0.08),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Verifying your payment. Please wait...',
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  isLoading
                      ? null
                      : _startPayment,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'Pay Now',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Amount is calculated securely by RentKaro.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}