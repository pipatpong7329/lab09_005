import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Addbookpage extends StatefulWidget {
  final String accessToken;

  const Addbookpage({super.key, required this.accessToken});

  @override
  State<Addbookpage> createState() => _AddbookpageState();
}

class _AddbookpageState extends State<Addbookpage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _yearController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final requestBody = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'published_year': int.tryParse(_yearController.text.trim()) ?? 0,
      };

      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/api/books'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
        body: jsonEncode(requestBody),
      );

      print('Response: ${response.statusCode} - ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มหนังสือสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถเชื่อมต่อได้: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('เพิ่มหนังสือ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'ชื่อหนังสือ', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'กรุณากรอกชื่อหนังสือ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                    labelText: 'ผู้แต่ง', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'กรุณากรอกชื่อผู้แต่ง' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                    labelText: 'ปีที่พิมพ์', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'กรุณากรอกปีที่พิมพ์';
                  if (int.tryParse(v) == null) return 'กรุณากรอกเป็นตัวเลขเท่านั้น';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addBook,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('บันทึก',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}