import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

void main() => runApp(const EnviroAcousticApp());

Map<String, String> registeredUser = {};

class EnviroAcousticApp extends StatelessWidget {
  const EnviroAcousticApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const SignUpPage(),
    );
  }
}

// --- SHARED UI COMPONENT: HEALTH BACKGROUND ---
class HealthBackground extends StatelessWidget {
  final Widget child;
  const HealthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0FDFA), Colors.white],
            ),
          ),
        ),
        // Abstract Medical Pulse Design
        Positioned(
          top: -50, right: -50,
          child: Icon(Icons.favorite_rounded, size: 300, color: Colors.teal.withOpacity(0.03)),
        ),
        Positioned(
          bottom: -20, left: -20,
          child: Icon(Icons.air, size: 200, color: Colors.blue.withOpacity(0.03)),
        ),
        child,
      ],
    );
  }
}

// --- 1. CREATIVE SIGN UP PAGE ---
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HealthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.health_and_safety_outlined, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text("Join EnviroAcoustic", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const Text("Your journey to better lung health starts here", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              _buildInput(nameController, "Full Name", Icons.person_outline),
              const SizedBox(height: 15),
              _buildInput(emailController, "Email", Icons.email_outlined),
              const SizedBox(height: 15),
              _buildInput(passController, "Password", Icons.lock_outline, obscure: true),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: () {
                  registeredUser = {'name': nameController.text, 'email': emailController.text, 'pass': passController.text};
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginPage()));
                },
                child: const Text("Create Patient Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}

// --- 2. LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HealthBackground(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 40),
              TextField(controller: emailController, decoration: InputDecoration(hintText: "Email", prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
              const SizedBox(height: 15),
              TextField(controller: passController, obscureText: true, decoration: InputDecoration(hintText: "Password", prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60), backgroundColor: Colors.teal),
                onPressed: () {
                  if (emailController.text == registeredUser['email']) {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const GPSRequestPage()));
                  }
                },
                child: const Text("Sign In", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. DYNAMIC DASHBOARD (BACKGROUND CHANGES WITH AQI) ---
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int aqi = 0;
  String status = "Syncing Air Data...";
  List<Color> bgGradient = [Colors.teal.shade50, Colors.white];
  Color accentColor = Colors.teal;

  Future<void> fetchAQI() async {
    final response = await http.get(Uri.parse("https://api.waqi.info/feed/here/?token=demo"));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      int val = data['data']['aqi'];
      setState(() {
        aqi = val;
        if (aqi <= 50) {
          bgGradient = [const Color(0xFFE8F5E9), Colors.white]; // Green tint
          accentColor = Colors.green.shade700;
          status = "Pure Air Detected";
        } else if (aqi <= 100) {
          bgGradient = [const Color(0xFFFFF3E0), Colors.white]; // Orange tint
          accentColor = Colors.orange.shade800;
          status = "Moderate Pollution";
        } else {
          bgGradient = [const Color(0xFFFFEBEE), Colors.white]; // Red tint
          accentColor = Colors.red.shade800;
          status = "Hazardous Condition";
        }
      });
    }
  }

  @override
  void initState() { super.initState(); fetchAQI(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: bgGradient)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("Health Hub", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: PopupMenuButton(
                icon: CircleAvatar(backgroundColor: accentColor, child: const Icon(Icons.person, color: Colors.white)),
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text("Signed in as: ${registeredUser['name']}")),
                  PopupMenuItem(child: const Text("Logout", style: TextStyle(color: Colors.red)), onTap: () => Navigator.of(context).popUntil((route) => route.isFirst)),
                ],
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              // AQI SECTION
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 30)],
                ),
                child: Column(
                  children: [
                    Text("ENVIRONMENTAL STATUS", style: TextStyle(letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold, color: accentColor)),
                    const SizedBox(height: 20),
                    Text("$aqi", style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: accentColor)),
                    Text(status, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    const Text("Based on your current GPS location", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildModernTile("Acoustic Monitoring", Icons.graphic_eq, "Coming Soon"),
              const SizedBox(height: 15),
              _buildModernTile("Medical History", Icons.receipt_long, "View Records"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTile(String title, IconData icon, String sub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 12))])
        ],
      ),
    );
  }
}

// GPS Page omitted for brevity, logic remains same as previous step.
class GPSRequestPage extends StatelessWidget {
  const GPSRequestPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 80, color: Colors.teal),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Dashboard())),
              child: const Text("Authorize GPS for AQI Monitoring"),
            ),
          ],
        ),
      ),
    );
  }
}