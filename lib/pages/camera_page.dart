import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../contracts/camera_contract.dart';
import '../presenters/camera_presenter.dart';
import '../models/contact_model.dart';
import '../utils/constants.dart';
import 'form_page.dart';

class CameraPage extends StatefulWidget {
  static const String routeName = 'camera';
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> implements CameraView {
  final CameraPresenter _presenter = CameraPresenterImpl();
  bool isScanOver = false;
  List<String> lines = [];
  String imagePath = '';

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
  }

  @override
  void dispose() {
    _presenter.detachView();
    super.dispose();
  }

  Future<void> createContact() async {
    final contact = _presenter.getContact();
    final result = await context.pushNamed(
      FormPage.routeName,
      extra: contact,
    );
    if (result == true) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Page'),
        backgroundColor: const Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _presenter.isFormValid ? createContact : null,
            icon: const Icon(Icons.arrow_forward),
            color: _presenter.isFormValid ? Colors.white : Colors.grey.shade400,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => getImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Camera', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.deepPurple,
                  elevation: 5,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => getImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('Gallery', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.indigo,
                  elevation: 5,
                ),
              ),
            ],
          ),
          if (isScanOver) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    DragTargetItem(property: ContactProperties.name, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.mobile, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.email, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.company, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.designation, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.address, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.website, onDrop: getPropertyValue),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(hint),
            ),
          ],
          Wrap(
            spacing: 8,
            children: lines.map((line) => LineItem(line: line)).toList(),
          )
        ],
      ),
    );
  }

  void getImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) await _presenter.processImage(picked.path);
  }

  void getPropertyValue(String property, String value) {
    _presenter.updatePropertyValue(property, value);
    setState(() {});
  }

  // CameraView implementations:
  @override void updateScannedLines(List<String> lines) => setState(() => this.lines = lines);
  @override void updateScanStatus(bool over) => setState(() => isScanOver = over);
  @override void updateImagePath(String path) => setState(() => imagePath = path);
  @override void showLoading(String msg) => EasyLoading.show(status: msg);
  @override void hideLoading() => EasyLoading.dismiss();
  @override void showError(String msg) => EasyLoading.showError(msg);
}


// ===== widget classes =====

class DragTargetItem extends StatefulWidget {
  final String property;
  final Function(String, String) onDrop;
  const DragTargetItem({Key? key, required this.property, required this.onDrop}) : super(key: key);

  @override
  State<DragTargetItem> createState() => _DragTargetItemState();
}

class _DragTargetItemState extends State<DragTargetItem> {
  List<String> dragItems = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: Text(widget.property, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        Expanded(
          flex: 2,
          child: DragTarget<String>(
            builder: (context, candidate, rejected) => Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: candidate.isNotEmpty ? Border.all(color: Colors.red, width: 2) : null,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(dragItems.isEmpty ? 'Drop here' : dragItems.join(' '))),
                  if (dragItems.isNotEmpty)
                    InkWell(onTap: () {
                      setState(() => dragItems.clear());
                      widget.onDrop(widget.property, '');
                    }, child: const Icon(Icons.clear, size: 15, color: Colors.red)),
                ],
              ),
            ),
            onAccept: (value) {
              setState(() { if (!dragItems.contains(value)) dragItems.add(value); });
              widget.onDrop(widget.property, dragItems.join(' '));
            },
          ),
        ),
      ],
    );
  }
}

class LineItem extends StatelessWidget {
  final String line;
  const LineItem({Key? key, required this.line}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<String>(
      data: line,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Material(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.black38,
          child: Text(line, style: const TextStyle(color: Colors.white)),
        ),
      ),
      child: Chip(label: Text(line)),
    );
  }
}


