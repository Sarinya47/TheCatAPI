import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ===== MODEL =====
class Animal {
  final String imageUrl;
  final String name;

  Animal({required this.imageUrl, required this.name});
}

// ===== SERVICE =====
class AnimalService {
  // fallback list สำหรับแมว
  static const List<String> fallbackCats = [
    "https://cdn2.thecatapi.com/images/1pd.jpg",
    "https://cdn2.thecatapi.com/images/24n.jpg",
    "https://cdn2.thecatapi.com/images/agm.jpg",
    "https://cdn2.thecatapi.com/images/ak0.jpg",
    "https://cdn2.thecatapi.com/images/c6r.jpg",
    "https://cdn2.thecatapi.com/images/cd1.jpg",
    "https://cdn2.thecatapi.com/images/cqm.jpg",
    "https://cdn2.thecatapi.com/images/MTg1NjkxNQ.jpg",
    "https://cdn2.thecatapi.com/images/OhTkBTPnD.jpg",
    "https://cdn2.thecatapi.com/images/1bFFj7N5c.jpg",
  ];

  // ===== FETCH CATS =====
  static Future<List<Animal>> fetchCats() async {
    final url = Uri.parse('https://api.thecatapi.com/v1/images/search?limit=10');
    try {
      final res = await http.get(url, headers: {
        'x-api-key': 'live_KevgJglE3tgGMYa3sq8ABxzW1td5h71KXKZJv9zIA9PY6RHJnOuNmx07BBNi9FAh',
      });

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        if (data.isEmpty) throw Exception("Empty data");
        return data.map((e) => Animal(imageUrl: e['url'], name: "Cat")).toList();
      } else {
        // fallback ถ้า API ใช้ไม่ได้
        return fallbackCats.map((url) => Animal(imageUrl: url, name: "Cat")).toList();
      }
    } catch (e) {
      // fallback ถ้าเกิด exception
      return fallbackCats.map((url) => Animal(imageUrl: url, name: "Cat")).toList();
    }
  }

  // ===== FETCH DOGS =====
  static Future<List<Animal>> fetchDogs() async {
    final url = Uri.parse('https://dog.ceo/api/breeds/image/random/10');
    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List images = data['message'];
        return images.map((e) => Animal(imageUrl: e, name: "Dog")).toList();
      } else {
        // fallback dog
        return [
          Animal(imageUrl: "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg", name: "Dog"),
          Animal(imageUrl: "https://images.dog.ceo/breeds/hound-basset/n02088238_1007.jpg", name: "Dog"),
          Animal(imageUrl: "https://images.dog.ceo/breeds/hound-blood/n02088466_10184.jpg", name: "Dog"),
        ];
      }
    } catch (e) {
      return [
        Animal(imageUrl: "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg", name: "Dog"),
        Animal(imageUrl: "https://images.dog.ceo/breeds/hound-basset/n02088238_1007.jpg", name: "Dog"),
        Animal(imageUrl: "https://images.dog.ceo/breeds/hound-blood/n02088466_10184.jpg", name: "Dog"),
      ];
    }
  }
}

// ===== SCREEN =====
class AnimalScreen extends StatefulWidget {
  const AnimalScreen({super.key});

  @override
  State<AnimalScreen> createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dogs & Cats"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pets), text: "Dogs"),
            Tab(icon: Icon(Icons.pets_outlined), text: "Cats"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnimalList(AnimalService.fetchDogs),
          _buildAnimalList(AnimalService.fetchCats),
        ],
      ),
    );
  }

  Widget _buildAnimalList(Future<List<Animal>> Function() fetchFunction) {
    return FutureBuilder<List<Animal>>(
      future: fetchFunction(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => AnimalCard(animal: snapshot.data![index]),
        );
      },
    );
  }
}

// ===== CARD =====
class AnimalCard extends StatelessWidget {
  final Animal animal;

  const AnimalCard({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              animal.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                height: 200,
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(animal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: AnimalScreen(), debugShowCheckedModeBanner: false));
}
