import 'package:contact_book/controller/sqfController.dart';
import 'package:contact_book/view/addContact.dart';
import 'package:contact_book/view/contactDetails.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;

  void _refreshContacts() async {
    final data = await SqlController.getData('contacts');
    setState(() {
      _contacts = data;
      _isLoading = false;
      searchController.clear();
    });
  }

  void search() async {
    final data = await SqlController.searchData(
        'contacts', searchController.text.trim());
    setState(() {
      _contacts = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  void _deleteContact(int id) async {
    await SqlController.delete('contacts', id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Contact deleted")),
    );
    _refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          title: const Text("My Contacts"),
          actions: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: search,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _contacts.isEmpty
              ? const Center(
                  child: Text("No contacts yet"),
                )
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: contact['isFavorite'] == 1
                              ? const Icon(Icons.star, color: Colors.green)
                              : null,
                        ),
                        title: Text(contact['name']),
                        subtitle:
                            Text(contact['phone'] + '\n' + contact['email']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ContactDetailPage(contact: contact),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddContactPage()),
          ).then((_) => _refreshContacts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
