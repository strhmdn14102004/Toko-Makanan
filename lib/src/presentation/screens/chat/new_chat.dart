import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectUserPage extends StatelessWidget {
  final Function(DocumentReference userRef) onUserSelected;

  const SelectUserPage({Key? key, required this.onUserSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Pengguna'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada pengguna.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userName = userDoc['firstName'] ?? 'Tidak ada nama';
              final userImage = userDoc['image'] ?? '';
              final userEmail = userDoc['email'] ?? 'Tidak ada email';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: userImage.isNotEmpty
                        ? NetworkImage(userImage)
                        : const AssetImage('assets/png/no-image.png')
                            as ImageProvider,
                    radius: 25,
                  ),
                  title: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(userEmail),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    onUserSelected(userDoc.reference);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
