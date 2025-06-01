import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../contracts/home_contract.dart';
import '../presenters/home_presenter.dart';
import '../models/contact_model.dart';
import '../utils/helper_functions.dart';
import 'camera_page.dart';
import 'contact_details_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements HomeView {
  final HomePresenter _presenter = HomePresenterImpl();
  List<ContactModel> _contacts = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
    _presenter.loadContacts();
  }

  @override
  void dispose() {
    _presenter.detachView();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: _buildBody(),
      // Ensure the scaffold doesn't try to pad for the navigation
      resizeToAvoidBottomInset: false,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Contact List'),
      backgroundColor: const Color(0xFF6200EE),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          tooltip: 'Profile',
          onPressed: () async {
            final updated = await context.pushNamed(ProfilePage.routeName);
            if (updated == true) {
              _presenter.loadContacts(favorites: _selectedIndex == 1);
            }
          },
        ),
      ],
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final newContact = ContactModel(
          name: '',
          mobile: '',
          imageLocal: '',
          imageUrl: '',
        );
        final result = await context.pushNamed(
          CameraPage.routeName,
          extra: newContact,
        );
        if (result == true) {
          _presenter.loadContacts(favorites: _selectedIndex == 1);
        }
      },
      backgroundColor: Colors.deepPurple,
      child: const Icon(Icons.add),
      elevation: 8,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    // Get the bottom system inset to handle safe area
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Using a Material widget with type BottomNavigationBar directly instead of BottomAppBar
    return Material(
      color: Colors.white,
      elevation: 8.0,
      child: Padding(
        // Add 12 pixels to fix the overflow
        padding: EdgeInsets.only(bottom: bottomInset + 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // All contacts tab
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  _presenter.loadContacts(favorites: false);
                },
                child: SizedBox(
                  height: 56, // Standard height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        color: _selectedIndex == 0
                            ? const Color(0xFF6200EE)
                            : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All',
                        style: TextStyle(
                          color: _selectedIndex == 0
                              ? const Color(0xFF6200EE)
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Space for FAB
            const SizedBox(width: 80),

            // Favorites tab
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  _presenter.loadContacts(favorites: true);
                },
                child: SizedBox(
                  height: 56, // Standard height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: _selectedIndex == 1
                            ? const Color(0xFF6200EE)
                            : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Favorites',
                        style: TextStyle(
                          color: _selectedIndex == 1
                              ? const Color(0xFF6200EE)
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      top: true,
      bottom: false, // We handle bottom padding manually
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? const Center(child: Text('No contacts found'))
          : _buildContactList(),
    );
  }

  Widget _buildContactList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      // Add extra bottom padding to account for the bottom navigation bar plus FAB
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        return _buildContactItem(_contacts[index]);
      },
    );
  }

  Widget _buildContactItem(ContactModel contact) {
    return Dismissible(
      key: ValueKey(contact.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) async {
        await _presenter.deleteContact(contact.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            contact.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          trailing: IconButton(
            icon: Icon(contact.favorite ? Icons.favorite : Icons.favorite_border),
            color: Colors.pink,
            onPressed: () => _presenter.toggleFavorite(contact),
          ),
          onTap: () => context.pushNamed(
            ContactDetailsPage.routeName,
            extra: contact,
          ),
        ),
      ),
    );
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void showContacts(List<ContactModel> contacts) =>
      setState(() { _contacts = contacts; _isLoading = false; });

  @override
  void showEmptyState() => setState(() { _contacts = []; _isLoading = false; });

  @override
  void showError(String message) {
    showMsg(context, message);
    setState(() => _isLoading = false);
  }
}