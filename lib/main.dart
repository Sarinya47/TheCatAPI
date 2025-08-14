import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dog {
  final String breedName;
  final String temperament;
  final List<String> images;

  Dog({
    required this.breedName,
    required this.temperament,
    required this.images,
  });
}

class DogService {
  static const String fallbackImage =
      'https://via.placeholder.com/400x200.png?text=No+Image';

  // ลักษณะนิสัยสายพันธุ์เป็นภาษาไทย
  static const Map<String, String> breedTemperament = {
    'Hound': 'ขี้เล่น ฉลาด กระตือรือร้น เหมาะกับการวิ่งและกิจกรรมกลางแจ้ง',
    'Bulldog': 'ขี้เล่น สุภาพ อดทน รักครอบครัว ขี้เกียจเล็กน้อย',
    'Retriever': 'ฉลาด รักสังคม ซื่อสัตย์ อดทน เหมาะกับครอบครัวและเด็ก',
    'Poodle': 'ฉลาด กระตือรือร้น ขี้เล่น รักความสะอาด ชอบเรียนรู้สิ่งใหม่',
    'Terrier': 'ขี้เล่น กล้าหาญ กระตือรือร้น ชอบล่าสัตว์ มีพลังเยอะ',
    'Sheepdog': 'ซื่อสัตย์ อดทน ใจดี รักครอบครัว ชอบช่วยงาน',
    'Spaniel': 'ขี้เล่น รักสังคม อ่อนโยน ชอบอยู่กับคนและสัตว์ตัวอื่น',
    'Boxer': 'ขี้เล่น พลังเยอะ ซื่อสัตย์ อดทน รักครอบครัว',
    'Chihuahua': 'ฉลาด ขี้เล่น รักเจ้าของ ตัวเล็กแต่มีพลังและกล้าหาญ',
    'Dachshund': 'ฉลาด ร่าเริง อยากรู้อยากเห็น กล้าหาญ',
  };

  static String getTemperament(String breedName) {
    final mainBreed = breedName.split(' ').first;
    return breedTemperament[mainBreed] ?? 'ขี้เล่น ซื่อสัตย์ กระตือรือร้น';
  }

  // ดึงรูปสุนัขหลายรูป
  static Future<List<Dog>> fetchDogs() async {
    final url = Uri.parse('https://dog.ceo/api/breeds/image/random/50');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List images = data['message'];

        // รวมรูปตามสายพันธุ์
        Map<String, List<String>> breedImages = {};
        for (var imgUrl in images) {
          final uriParts = imgUrl.split('/');
          String breedName = 'Unknown';
          if (uriParts.length > 4) {
            breedName = uriParts[4].replaceAll('-', ' ');
            breedName = breedName[0].toUpperCase() + breedName.substring(1);
          }
          if (!breedImages.containsKey(breedName)) {
            breedImages[breedName] = [];
          }
          breedImages[breedName]!.add(imgUrl);
        }

        // สร้าง List<Dog>
        return breedImages.entries.map((e) {
          return Dog(
            breedName: e.key,
            temperament: getTemperament(e.key),
            images: e.value,
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

// กำหนดสีตามลักษณะนิสัย
Color temperamentColor(String temperament) {
  if (temperament.contains('ขี้เล่น')) return Colors.yellow.shade100;
  if (temperament.contains('ซื่อสัตย์')) return Colors.blue.shade100;
  if (temperament.contains('ฉลาด')) return Colors.green.shade100;
  return Colors.grey.shade100;
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
        title: const Text("สายพันธุ์สุนัข"),
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
                      hintText: 'ค้นหาสายพันธุ์...',
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
                      ? const Center(child: Text("ไม่พบสายพันธุ์"))
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
        color: temperamentColor(dog.temperament),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
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
                dog.images.first,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[300], child: const Icon(Icons.error, color: Colors.red)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dog.breedName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dog.temperament,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
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
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: dog.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  dog.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[300], child: const Icon(Icons.error, color: Colors.red)),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            dog.breedName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              dog.temperament,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: DogScreen(), debugShowCheckedModeBanner: false));
}
