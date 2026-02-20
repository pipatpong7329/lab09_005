import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab09_005/page/addbookpage.dart';
import 'package:lab09_005/page/editbookpage.dart';

class BookModel {
  final int id;
  final String title;
  final String author;
  final int publishedYear;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.publishedYear,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publishedYear: int.tryParse(
              (json['published_year'] ?? json['year'] ?? 0).toString()) ??
          0,
    );
  }
}

class Showbooks extends StatefulWidget {
  final Map<String, dynamic> payload;
  final String accessToken;
  final String refreshToken;

  const Showbooks({
    super.key,
    required this.payload,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  State<Showbooks> createState() => _ShowbooksState();
}

class _ShowbooksState extends State<Showbooks> {
  late Future<List<BookModel>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = getList();
  }

  void _loadBooks() {
    setState(() {
      _booksFuture = getList();
    });
  }

  Future<List<BookModel>> getList() async {
    var url = Uri.parse("http://10.0.2.2:4000/api/books");
    var response = await http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.accessToken}"},
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<dynamic> payloadData;
      if (jsonData is List) {
        payloadData = jsonData;
      } else {
        payloadData = jsonData['payload'] as List<dynamic>;
      }
      return payloadData
          .map((item) => BookModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      throw Exception('โหลดข้อมูลไม่สำเร็จ: ${response.statusCode}');
    }
  }

  Future<void> _deleteBook(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:4000/api/books/$id'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer ${widget.accessToken}",
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบหนังสือสำเร็จ'), backgroundColor: Colors.green),
        );
        _loadBooks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบไม่สำเร็จ: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDelete(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ยืนยันการลบ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('ต้องการลบ "${book.title}" ใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteBook(book.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Widget showList() {
    return FutureBuilder(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasData) {
          List<BookModel> books = snapshot.data!;
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[300]),
                  const Text('ไม่มีข้อมูลหนังสือ', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final item = books[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBookPage(
                          accessToken: widget.accessToken,
                          bookId: item.id,
                          initialTitle: item.title,
                          initialAuthor: item.author,
                          initialYear: item.publishedYear,
                        ),
                      ),
                    );
                    if (result == true) _loadBooks();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                       Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.lightBlueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.book, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(item.author, style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                              Text(
                                'ปีที่พิมพ์: ${item.publishedYear == 0 ? '-' : item.publishedYear}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, item),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Book Library', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
            Text(widget.payload["username"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: _loadBooks, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'ROLE: ${widget.payload["role"].toString().toUpperCase()}',
                  style: const TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          Expanded(child: showList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addbookpage(accessToken: widget.accessToken),
            ),
          );
          if (result == true) _loadBooks();
        },
        label: const Text('เพิ่มหนังสือ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}