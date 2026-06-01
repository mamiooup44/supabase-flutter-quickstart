import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_information/device_information.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- COLLER TES INFORMATIONS SUPABASE ICI ---
  await Supabase.initialize(
    url: 'https://frsvuwpidxsxuczgwmfh.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZyc3Z1d3BpZHhzeHVjemd3bWZoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MzI4MzQzMCwiZXhwIjoyMDg4ODU5NDMwfQ.YAx5DQ[...]
  );
  // ---------------------------------------------
  
  runApp(const MaterialApp(home: ShieldCheckApp()));
}

class ShieldCheckApp extends StatefulWidget {
  const ShieldCheckApp({super.key});
  @override
  State<ShieldCheckApp> createState() => _ShieldCheckAppState();
}

class _ShieldCheckAppState extends State<ShieldCheckApp> {
  bool estBloque = false;
  String monImei = "Chargement...";

  @override
  void initState() {
    super.initState();
    initShieldCheck();
  }

  Future<void> initShieldCheck() async {
    // Récupération de l'IMEI - FIX: utiliser deviceIMEINumber au lieu de deviceIMEI
    String imei = await DeviceInformation.deviceIMEINumber;
    setState(() => monImei = imei);

    // Surveillance en temps réel de la base
    Supabase.instance.client
        .from('objets_voles')
        .stream(primaryKey: ['identifiant'])
        .eq('identifiant', imei)
        .listen((data) {
      if (data.isNotEmpty && data[0]['statut'] == 'recherche') {
        setState(() => estBloque = true);
      } else {
        setState(() => estBloque = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (estBloque) {
      return const Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Text(
            "SHIELD CHECK: TÉLÉPHONE DÉCLARÉ VOLÉ",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("ShieldCheck Mali")),
      body: Center(child: Text("Système actif.\nVotre IMEI : $monImei", textAlign: TextAlign.center)),
    );
  }
}
