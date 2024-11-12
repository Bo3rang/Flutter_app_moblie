import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final String currentUserId;
  const SearchScreen({super.key, required this.currentUserId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _userNames = [];
  List<Map<String, dynamic>> _filteredUserNames = [];

  // Hàm tìm kiếm người dùng trong Firestore
  Future<void> _searchUser(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredUserNames = _userNames;
      });
      return;
    }

    var querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    List<Map<String, dynamic>> users = [];
    for (var doc in querySnapshot.docs) {
      users.add({
        'name': doc['name'],
        'userId': doc.id,
        'avatarUrl': doc['avatarUrl'] ?? 'https://via.placeholder.com/150',
      });
    }

    setState(() {
      _filteredUserNames = users;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  // Lấy tất cả người dùng từ Firestore
  Future<void> _fetchAllUsers() async {
    var querySnapshot = await FirebaseFirestore.instance.collection('Users').get();
    List<Map<String, dynamic>> users = [];
    for (var doc in querySnapshot.docs) {
      users.add({
        'name': doc['name'],
        'userId': doc.id,
        'avatarUrl': doc['avatarUrl'] ?? 'https://via.placeholder.com/150',
      });
    }

    setState(() {
      _userNames = users;
      _filteredUserNames = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm người dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (query) => _searchUser(query),
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm người dùng',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchUser(_controller.text);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _filteredUserNames.isEmpty
                  ? const Center(child: Text('Không có kết quả'))
                  : ListView.builder(
                      itemCount: _filteredUserNames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(_filteredUserNames[index]['avatarUrl']),
                          ),
                          title: Text(_filteredUserNames[index]['name']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  currentUserId: widget.currentUserId,
                                  profileUserId: _filteredUserNames[index]['userId'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
