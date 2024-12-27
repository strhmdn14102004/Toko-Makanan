import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_ninja/src/bloc/testimonial/testimonial_bloc.dart';
import 'package:food_ninja/src/data/models/food.dart';
import 'package:food_ninja/src/data/models/order.dart';
import 'package:food_ninja/src/data/models/testimonial.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';
import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';
import 'package:food_ninja/src/presentation/widgets/items/testimonial_item.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  final Order order;

  const OrderPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Testimonial> testimonials = [];
  double rating = 0;

  @override
  void initState() {
    super.initState();
    firestore.DocumentReference restaurantRef = firestore.FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.order.restaurant.id);
    BlocProvider.of<TestimonialBloc>(context).add(
      FetchTestimonials(target: restaurantRef),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TestimonialBloc, TestimonialState>(
      listener: (context, state) {
        if (state is TestimonialsFetched) {
          setState(() {
            testimonials = state.testimonials;
            rating = testimonials.isNotEmpty
                ? testimonials.map((e) => e.rating).reduce((a, b) => a + b) /
                    testimonials.length
                : 0;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Detail Pesanan"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ringkasan Pesanan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Nama Pemesan : ${widget.order.userEmail}"),
                Text("Restoran : ${widget.order.restaurant.id}"),
                Text(
                  "Dibuat Pada Tanggal : ${DateFormat('dd MMMM yyyy').format(widget.order.createdAt)}",
                ),
                Text("Status Pesanan : ${widget.order.status.name}"),
                Text("Metode Pembayaran : ${widget.order.paymentMethod.name}"),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "Item Pembelian",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.order.cart.length,
                  itemBuilder: (context, index) {
                    Food food = widget.order.cart[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          food.image ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(food.name),
                        subtitle: Text("Kuantitas: ${food.quantity}"),
                        trailing: Text("Harga: Rp ${food.price * food.quantity}"),
                      ),
                    );
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "Rincian Pembayaran",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("Subtotal : "),
                    Text(formatCurrency(widget.order.subtotal)),  
                  ],
                ),
                Row(
                  children: [
                    Text("Biaya Perjalanan : "),
                    Text(formatCurrency(widget.order.deliveryFee)),  
                  ],
                ),
                Row(
                  children: [
                    Text("Diskon : "),
                    Text(formatCurrency(widget.order.discount)),  
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Total : ",

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(formatCurrency(widget.order.total)),  
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "Ulasan Restoran",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (testimonials.isEmpty)
                  Center(
                    child: Text(
                      "No testimonials available",
                      style: CustomTextStyle.size14Weight400Text(
                        AppColors().secondaryTextColor,
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rating: ${rating.toStringAsFixed(1)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: testimonials.length,
                        itemBuilder: (context, index) {
                          return TestimonialItem(
                            testimonial: testimonials[index],
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
 String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}
