import 'package:flutter/material.dart';

import 'action_button.dart';

class Demobuoi4 extends StatelessWidget {
  const Demobuoi4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 450,
          height: 520, // cố định chiều cao giống poster
          padding: const  EdgeInsets.only(top: 80,bottom: 100),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 130,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=600&q=60",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 30),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Price : 1000\$",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 28),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 0,
                            left: 30,
                            right: 0,
                            bottom: 0,
                          ),
                          child: const Text(
                            "Samsung Galaxy Note 9\n"
                                "Dimension: 1200x1200\n"
                                "Published on: Aug 24th, 2018\n"
                                "Category: Electronics\n"
                                "Tags: Samsung Galaxy Note",
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],

                    ),
                  ),
                ],
              ),

              const Spacer(), // đẩy nút xuống gần đáy card
              // ===== BUTTON AREA =====
              Row(
                children: [
                  Expanded(
                    child: ActionButton(label: "HOME", onTap: () {}),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ActionButton(label: "BUY NOW", onTap: () {}),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ActionButton(label: "DETAIL", onTap: () {}),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}