import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- COLLER TES INFORMATIONS SUPABASE ICI ---
  await Supabase.initialize(
    url: 'https://upabase.co', 
    anonKey: 'eiZXhwI',
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
  static const platform = MethodChannel('com.example.supabase_flutter_quickstart/device_admin');
  
  bool estBloque = false;
  String monImei = "Chargement...";
  bool adminActivated = false;
  Timer? gpsTimer;
  StreamSubscription? realtimeSubscription;

  @override
  void initState() {
    super.initState();
    initShieldCheck();
  }

  Future<void> initShieldCheck() async {
    try {
      // Récupération de l'IMEI
      final deviceInfo = DeviceInfoPlugin();
      String imei = "Non disponible";
      
      try {
        final androidInfo = await deviceInfo.androidInfo;
        imei = androidInfo.id; // ID unique Android
      } catch (e) {
        print("Erreur récupération IMEI: $e");
      }
      
      setState(() => monImei = imei);

      // Demander l'activation des droits d'administrateur
      await requestDeviceAdminActivation();

      // Surveillance en temps réel de la base
      realtimeSubscription = Supabase.instance.client
          .from('objets_voles')
          .stream(primaryKey: ['identifiant'])
          .eq('identifiant', imei)
          .listen((data) {
        if (data.isNotEmpty) {
          String statut = data[0]['statut'] ?? '';
          
          if (statut == 'recherche') {
            setState(() => estBloque = true);
            // Verrouiller l'écran
            lockDeviceScreen();
            // Démarrer le tracking GPS
            startGPSTracking(imei);
          } else {
            setState(() => estBloque = false);
            // Arrêter le tracking GPS
            stopGPSTracking();
          }
        }
      }, onError: (error) {
        print("Erreur surveillance base: $error");
      });
    } catch (e) {
      print("Erreur initShieldCheck: $e");
      setState(() => monImei = "Erreur: $e");
    }
  }

  Future<void> requestDeviceAdminActivation() async {
    try {
      final result = await platform.invokeMethod('requestDeviceAdmin');
      setState(() => adminActivated = result);
      print("Device Admin activation: $result");
    } catch (e) {
      print("Erreur activation Device Admin: $e");
    }
  }

  Future<void> lockDeviceScreen() async {
    try {
      await platform.invokeMethod('lockDevice');
      print("Écran verrouillé avec succès");
    } catch (e) {
      print("Erreur verrouillage écran: $e");
    }
  }

  void startGPSTracking(String imei) {
    // Arrêter le timer existant s'il y en a un
    stopGPSTracking();
    
    // Tracker GPS toutes les 5 minutes
    gpsTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await updateGPSLocation(imei);
    });
    
    // Mettre à jour immédiatement
    updateGPSLocation(imei);
  }

  void stopGPSTracking() {
    gpsTimer?.cancel();
    gpsTimer = null;
  }

  Future<void> updateGPSLocation(String imei) async {
    try {
      // Vérifier et demander les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Permission GPS refusée");
        return;
      }

      // Récupérer la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Mettre à jour la base de données
      await Supabase.instance.client
          .from('objets_voles')
          .update({
            'derniere_lat': position.latitude,
            'derniere_long': position.longitude,
          })
          .eq('identifiant', imei);

      print("Position GPS mise à jour: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Erreur mise à jour GPS: $e");
    }
  }

  @override
  void dispose() {
    gpsTimer?.cancel();
    realtimeSubscription?.cancel();
    super.dispose();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Système actif.\nVotre IMEI : $monImei",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              adminActivated ? "✓ Admin activé" : "⚠ Admin non activé",
              style: TextStyle(
                color: adminActivated ? Colors.green : Colors.orange,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
