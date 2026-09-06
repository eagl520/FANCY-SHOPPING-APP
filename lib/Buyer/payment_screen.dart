import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class PaymentReceiptDialog extends StatelessWidget {
  final String paymentType;
  final String bank;
  final String mobile;
  final String? email; 
  final String amountPaid;
  final String transactionId;

  const PaymentReceiptDialog({
    Key? key,
    this.paymentType = 'Net banking',
    this.bank = 'HDFC',
    this.mobile = '8897131444',
    this.email, 
    required this.amountPaid, 
    this.transactionId = '125478965698',
  }) : super(key: key);

  
  
  static void show(BuildContext context, {required String amountPaid}) {
    
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? 'No Email Found';

    showDialog(
      context: context,
      barrierColor: Colors.black54, 
      builder: (BuildContext context) => PaymentReceiptDialog(
        email: currentUserEmail,
        amountPaid: amountPaid, 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final userEmail = email ?? FirebaseAuth.instance.currentUser?.email ?? 'N/A';

    return Dialog(
      backgroundColor: Colors.transparent, 
      insetPadding: const EdgeInsets.all(20.0),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),

                
                const Text(
                  'Payment successful',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                
                _buildDetailRow('Payment type', paymentType),
                const SizedBox(height: 14),
                _buildDetailRow('Bank', bank),
                const SizedBox(height: 14),
                _buildDetailRow('Mobile', mobile),
                const SizedBox(height: 14),
                _buildDetailRow('Email', userEmail), 
                
                const SizedBox(height: 20),
                const Divider(color: Colors.grey, thickness: 0.5),
                const SizedBox(height: 16),

                
                _buildDetailRow('Amount paid', '\$$amountPaid', isBold: true),
                const SizedBox(height: 16),
                const Divider(color: Colors.grey, thickness: 0.5),
                const SizedBox(height: 16),

                
                _buildDetailRow('Transaction id', transactionId),
                const SizedBox(height: 40),

                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0089C7),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Printing receipt...')),
                          );
                        },
                        child: const Text(
                          'PRINT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0089C7),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'CLOSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
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

  
  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.black87 : Colors.grey[600],
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}