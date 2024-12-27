import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';


class MidtransService {
  Future<void> startTransaction({
    required String orderId,
    required double amount,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createTransaction');
      final response = await callable.call({
        'orderId': orderId,
        'amount': amount,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      });

      final redirectUrl = response.data['redirect_url'];

      if (await canLaunchUrl(Uri.parse(redirectUrl))) {
        await launchUrl(Uri.parse(redirectUrl));
        await launch(redirectUrl);
      } else {
        throw 'Could not launch $redirectUrl';
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
