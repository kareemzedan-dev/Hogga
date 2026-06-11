import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/utils/app_colors.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String caseNumber;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.caseNumber,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkUrl(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkUrl(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkUrl(String url) {
    final lowerUrl = url.toLowerCase();
    // Assuming backend returns a URL containing 'success' or 'status=paid' on success
    // Modify these keywords if backend uses different return URLs
    if (lowerUrl.contains('success') || lowerUrl.contains('status=paid') || lowerUrl.contains('callback?status=1')) {
      _navigateToSuccess();
    } else if (lowerUrl.contains('fail') || lowerUrl.contains('cancel') || lowerUrl.contains('status=unpaid') || lowerUrl.contains('callback?status=0')) {
      _showCancelDialog(isFromFailUrl: true);
    }
  }

  void _navigateToSuccess() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.orderConfirmed,
      (route) => false,
      arguments: {'caseNumber': widget.caseNumber},
    );
  }

  Future<bool> _onWillPop() async {
    return await _showCancelDialog() ?? false;
  }

  Future<bool?> _showCancelDialog({bool isFromFailUrl = false}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isFromFailUrl ? 'فشل عملية الدفع' : 'إلغاء الدفع'),
        content: Text(isFromFailUrl 
            ? 'يبدو أن عملية الدفع لم تكتمل. هل تريد المحاولة مرة أخرى أو العودة للخلف؟'
            : 'هل أنت متأكد من التراجع؟ سيتم إلغاء عملية الدفع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isFromFailUrl ? 'المحاولة مرة أخرى' : 'استكمال الدفع'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context, true); // Pop the dialog
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                (route) => false,
              );
            },
            child: Text(isFromFailUrl ? 'العودة للخلف' : 'نعم، قم بالإلغاء', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          title: const Text('إتمام عملية الدفع', style: TextStyle(fontSize: 16)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onWillPop,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.golden),
              ),
          ],
        ),
      ),
    );
  }
}
