import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutoSmsApp());
}

class AutoSmsApp extends StatelessWidget {
  const AutoSmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Missed Call Auto SMS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('missed_call_sms/channel');

  bool _hasPermissions = false;
  bool _isServiceRunning = false;
  bool _isLoading = false;
  String _smsMessage = "Sorry I missed your call. I'll get back to you soon!";

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);
    await _loadSavedMessage();
    await _checkServiceStatus();
    await _requestPermissions();
    setState(() => _isLoading = false);
  }

  Future<void> _loadSavedMessage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _smsMessage = prefs.getString('smsMessage') ??
          "Sorry I missed your call. I'll get back to you soon!";
    });
  }

  Future<void> _saveMessage(String message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('smsMessage', message);
    setState(() => _smsMessage = message);

    // Update message on Android side
    try {
      await platform.invokeMethod('setSmsMessage', message);
    } catch (e) {
      print("Failed to update message on service: $e");
    }
  }

  Future<void> _checkServiceStatus() async {
    try {
      final bool isRunning = await platform.invokeMethod('isServiceRunning');
      setState(() => _isServiceRunning = isRunning);
    } catch (e) {
      print("Failed to check service status: $e");
      setState(() => _isServiceRunning = false);
    }
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.phone,
      Permission.sms,
      Permission.notification,
      Permission.ignoreBatteryOptimizations
    ].request();

    final hasPhoneSmsPermissions =
        statuses[Permission.phone]?.isGranted == true &&
            statuses[Permission.sms]?.isGranted == true;

    setState(() => _hasPermissions = hasPhoneSmsPermissions);

    if (!hasPhoneSmsPermissions) {
      Fluttertoast.showToast(
        msg: "Please grant phone and SMS permissions",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> _startService() async {
    if (!_hasPermissions) {
      Fluttertoast.showToast(msg: "Please grant permissions first");
      await _requestPermissions();
      if (!_hasPermissions) return;
    }

    setState(() => _isLoading = true);

    try {
      await platform.invokeMethod('startService');
      setState(() => _isServiceRunning = true);
      Fluttertoast.showToast(msg: "Auto-SMS service started");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to start service: $e");
      setState(() => _isServiceRunning = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _stopService() async {
    setState(() => _isLoading = true);

    try {
      await platform.invokeMethod('stopService');
      setState(() => _isServiceRunning = false);
      Fluttertoast.showToast(msg: "Auto-SMS service stopped");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to stop service: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestBatteryOptimization() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 23) {
        // Request ignore battery optimization permission
        final status = await Permission.ignoreBatteryOptimizations.request();

        if (status.isGranted) {
          Fluttertoast.showToast(msg: "Battery optimization disabled");
        } else {
          // Open battery optimization settings
          const intent = AndroidIntent(
            action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
          );
          await intent.launch();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error opening battery settings");
      print('Error opening battery settings: $e');
    }
  }

  void _editSmsMessage() {
    final TextEditingController controller =
        TextEditingController(text: _smsMessage);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Auto-Reply Message'),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your auto-reply message for missed calls...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newMessage = controller.text.trim();
                if (newMessage.isNotEmpty) {
                  _saveMessage(newMessage);
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: "Message saved successfully");
                } else {
                  Fluttertoast.showToast(msg: "Message cannot be empty");
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missed Call Auto SMS'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: openAppSettings,
            tooltip: 'App Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Control Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Auto-SMS Service',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: _isServiceRunning,
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                          if (value) {
                                            _startService();
                                          } else {
                                            _stopService();
                                          }
                                        },
                                  activeColor: Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isServiceRunning
                                  ? "✅ Service is running - monitoring for missed calls"
                                  : "❌ Service is stopped",
                              style: TextStyle(
                                color: _isServiceRunning
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!_isServiceRunning) const SizedBox(height: 8),
                            if (!_isServiceRunning)
                              ElevatedButton(
                                onPressed: _startService,
                                child: const Text('Start Service'),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Message Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Auto-Reply Message:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _smsMessage,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _editSmsMessage,
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Message'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Permissions Card
                    Card(
                      elevation: 4,
                      color: _hasPermissions
                          ? Colors.green[50]
                          : Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _hasPermissions
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: _hasPermissions
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _hasPermissions
                                      ? 'All permissions granted'
                                      : 'Permissions required',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _hasPermissions
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _hasPermissions
                                  ? 'Your app has all necessary permissions to work properly.'
                                  : 'Phone and SMS permissions are needed for call detection and auto-reply.',
                              style: TextStyle(
                                color: _hasPermissions
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (!_hasPermissions)
                              ElevatedButton(
                                onPressed: _requestPermissions,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('Grant Permissions'),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Battery Optimization Card
                    Card(
                      elevation: 4,
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.battery_charging_full,
                                    color: Colors.blue),
                                SizedBox(width: 10),
                                Text(
                                  'Battery Optimization',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'For reliable background operation, please disable battery optimization for this app.',
                              style: TextStyle(color: Colors.blue),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _requestBatteryOptimization,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Disable Battery Optimization'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Instructions Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'How to Use:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('1. Grant all required permissions'),
                                Text('2. Disable battery optimization'),
                                Text('3. Turn on the service'),
                                Text('4. Edit your auto-reply message'),
                                Text(
                                    '5.  When you miss a call, SMS will be sent automatically, and you can send WhatsApp via notification button'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Note: Keep this app in the background for continuous operation.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Support Text
                    Center(
                      child: Text(
                        'Make sure to keep the app running in background\nfor continuous missed call detection',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
