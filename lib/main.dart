import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dog {
  final String imageUrl;
  final String breedName;

  Dog({required this.imageUrl, required this.breedName});
}

class DogService {
  static const String fallbackImage =
      'https://via.placeholder.com/400x200.png?text=No+Image';

  static Future<List<Dog>> fetchDogs() async {
    final url = Uri.parse('https://dog.ceo/api/breeds/image/random/50');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List images = data['message'];

        return images.map<Dog>((imgUrl) {
          final uriParts = imgUrl.split('/');
          String breedName = 'Unknown';
          if (uriParts.length > 4) {
            breedName = uriParts[4].replaceAll('-', ' ');
            breedName = breedName[0].toUpperCase() + breedName.substring(1);
          }
          return Dog(imageUrl: imgUrl, breedName: breedName);
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

class DogScreen extends StatefulWidget {
  const DogScreen({super.key});

  @override
  State<DogScreen> createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  List<Dog> allDogs = [];
  List<Dog> filteredDogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDogs();
  }

  Future<void> loadDogs() async {
    final dogs = await DogService.fetchDogs();
    setState(() {
      allDogs = dogs;
      filteredDogs = dogs;
      isLoading = false;
    });
  }

  void filterDogs(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredDogs = allDogs.where((dog) {
        return dog.breedName.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Dog Breeds"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search breed...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: filterDogs,
                  ),
                ),
                Expanded(
                  child: filteredDogs.isEmpty
                      ? const Center(child: Text("No breeds found"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredDogs.length,
                          itemBuilder: (context, index) {
                            final dog = filteredDogs[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DogDetailScreen(dog: dog),
                                  ),
                                );
                              },
                              child: DogCard(dog: dog),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class DogCard extends StatelessWidget {
  final Dog dog;

  const DogCard({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                dog.imageUrl.isNotEmpty ? dog.imageUrl : DogService.fallbackImage,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                dog.breedName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DogDetailScreen extends StatelessWidget {
  final Dog dog;

  const DogDetailScreen({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(dog.breedName),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              dog.imageUrl.isNotEmpty ? dog.imageUrl : DogService.fallbackImage,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: DogScreen(), debugShowCheckedModeBanner: false));
}
