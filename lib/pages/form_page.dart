import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../contracts/form_contract.dart';
import '../presenters/form_presenter.dart';
import '../models/contact_model.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class FormPage extends StatefulWidget {
  static const String routeName = 'form';
  final ContactModel contactModel;

  const FormPage({super.key, required this.contactModel});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> implements FormView {
  final _formKey = GlobalKey<FormState>();
  final FormPresenter _presenter = FormPresenterImpl();

  late final TextEditingController nameController;
  late final TextEditingController mobileController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  late final TextEditingController companyController;
  late final TextEditingController designationController;
  late final TextEditingController webController;

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
    nameController = TextEditingController(text: widget.contactModel.name);
    mobileController = TextEditingController(text: widget.contactModel.mobile);
    emailController = TextEditingController(text: widget.contactModel.email);
    addressController = TextEditingController(text: widget.contactModel.address);
    companyController = TextEditingController(text: widget.contactModel.company);
    designationController = TextEditingController(text: widget.contactModel.designation);
    webController = TextEditingController(text: widget.contactModel.website);
  }

  @override
  void dispose() {
    _presenter.detachView();
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    companyController.dispose();
    designationController.dispose();
    webController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    final contact = ContactModel(
      id: widget.contactModel.id,
      firebaseId: widget.contactModel.firebaseId,
      name: nameController.text,
      mobile: mobileController.text,
      email: emailController.text,
      address: addressController.text,
      company: companyController.text,
      designation: designationController.text,
      website: webController.text,
      imageLocal: widget.contactModel.imageLocal,
      imageUrl: widget.contactModel.imageUrl,
      favorite: widget.contactModel.favorite,
    );

    try {
      await _presenter.saveContact(contact);
    } catch (e) {
      showMsg(context, 'Error saving contact: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Page'),
        backgroundColor: const Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTextField(nameController, 'Contact Name', isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(
              mobileController,
              'Mobile Number',
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(emailController, 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(addressController, 'Street Address'),
            const SizedBox(height: 16),
            _buildTextField(companyController, 'Company Name'),
            const SizedBox(height: 16),
            _buildTextField(designationController, 'Designation'),
            const SizedBox(height: 16),
            _buildTextField(webController, 'Website'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        bool isRequired = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (v) {
        if (isRequired && (v == null || v.isEmpty)) {
          return emptyFieldErrMsg;
        }
        return null;
      },
    );
  }

  @override
  void showSuccess(String message) {
    showMsg(context, message);
    Navigator.of(context).pop(true);
  }

  @override
  void showError(String message) {
    showMsg(context, message);
  }
}
