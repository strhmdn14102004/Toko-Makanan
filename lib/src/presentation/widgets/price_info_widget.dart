import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_ninja/src/data/repositories/order_repository.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';
import 'package:food_ninja/src/presentation/utils/app_styles.dart';
import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/secondary_button.dart';
import 'package:intl/intl.dart';

class PriceInfoWidget extends StatefulWidget {
  final VoidCallback onTap;
  const PriceInfoWidget({
    super.key,
    required this.onTap,
  });

  @override
  State<PriceInfoWidget> createState() => _PriceInfoWidgetState();
}

class _PriceInfoWidgetState extends State<PriceInfoWidget> {
  @override
  void initState() {
    super.initState();
    loadDiscount();
  }

  void loadDiscount() async {
    await OrderRepository.fetchDiscount();
    print('Discount: ${OrderRepository.discount}');
    setState(() {});
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppStyles.largeBorderRadius,
          boxShadow: [AppStyles.boxShadow7],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: SvgPicture.asset(
                'assets/svg/pattern-card.svg',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                      Text(
                        formatCurrency(OrderRepository.subtotal),
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Biaya Pengiriman',
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                      Text(
                        formatCurrency(OrderRepository.deliveryFee),
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Diskon',
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                      Text(
                        formatCurrency(OrderRepository.discount),
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: CustomTextStyle.size22Weight600Text(
                          Colors.white,
                        ),
                      ),
                      Text(
                        formatCurrency(OrderRepository.total),
                        style: CustomTextStyle.size22Weight600Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: "Buat Orderan",
                          onTap: widget.onTap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
