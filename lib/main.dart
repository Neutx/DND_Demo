import 'package:flutter/material.dart';
import 'package:flutter_dnd/flutter_dnd.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DndExampleScreen(),
    );
  }
}

class DndExampleScreen extends StatefulWidget {
  @override
  _DndExampleScreenState createState() => _DndExampleScreenState();
}

class _DndExampleScreenState extends State<DndExampleScreen>
    with WidgetsBindingObserver {
  String _filterName = '';
  bool? _isNotificationPolicyAccessGranted = false;
  bool _showDialog = false; // Flag to control dialog visibility

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    updateUI();

    // Show the dialog after a delay
    Future.delayed(Duration(seconds: 1), () {
      showDNDPermissionDialog();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      updateUI();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateUI();
  }

  void updateUI() async {
    int? filter = await FlutterDnd.getCurrentInterruptionFilter();
    if (filter != null) {
      String filterName = FlutterDnd.getFilterName(filter);
      bool? isNotificationPolicyAccessGranted =
      await FlutterDnd.isNotificationPolicyAccessGranted;

      setState(() {
        _isNotificationPolicyAccessGranted = isNotificationPolicyAccessGranted;
        _filterName = filterName;
      });

      if (_isNotificationPolicyAccessGranted == false) {
        _showDialog = true;
      }
    }
  }

  void setInterruptionFilter(int filter, String snackBarMessage) async {
    final bool? isNotificationPolicyAccessGranted =
    await FlutterDnd.isNotificationPolicyAccessGranted;
    if (isNotificationPolicyAccessGranted != null &&
        isNotificationPolicyAccessGranted) {
      await FlutterDnd.setInterruptionFilter(filter);
      updateUI();
      showSnackBar(snackBarMessage);
    } else {
      setState(() {
        _showDialog = true;
      });
    }
  }

  void showDNDPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'DND Permission Required',
            style: TextStyle(color: Colors.black87),
          ),
          content: Text(
            'Please grant DND permission to the app to enable the DND functionality.',
            style: TextStyle(color: Colors.black87),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog manually
                _redirectToPolicySettings(); // Redirect to DND settings
              },
              style: TextButton.styleFrom(
                primary: Colors.black,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without redirection
                setState(() {
                  _showDialog = false; // Set the flag to false on Not Now
                });
              },
              style: TextButton.styleFrom(
                primary: Colors.black87,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Text('Not Now'),
            ),
          ],
        );
      },
    );
  }

  void _redirectToPolicySettings() async {
    await Future.delayed(Duration(milliseconds: 100)); // Add a small delay
    FlutterDnd.gotoPolicySettings();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GSoC Project Idea - It\'s Urgent',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              FlutterDnd.gotoPolicySettings();
            },
          ),
        ],
      ),
      body: Container(
        padding:
        EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setInterruptionFilter(
                          FlutterDnd.INTERRUPTION_FILTER_NONE,
                          'Do Not Disturb turned ON',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                        side: BorderSide(width: 3, color: Colors.black),
                        padding: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Turn On DND',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setInterruptionFilter(
                          FlutterDnd.INTERRUPTION_FILTER_ALL,
                          'Do Not Disturb turned OFF',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                        side: BorderSide(width: 3, color: Colors.black),
                        padding: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Turn Off DND',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setInterruptionFilter(
                    FlutterDnd.INTERRUPTION_FILTER_ALARMS,
                    'Do Not Disturb turned ON - Allowing Alarms',
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  side: BorderSide(width: 3, color: Colors.black),
                  padding: EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Turn On DND - Allow Alarm',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setInterruptionFilter(
                    FlutterDnd.INTERRUPTION_FILTER_PRIORITY,
                    'Do Not Disturb turned ON - Allowing Priority',
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  side: BorderSide(width: 3, color: Colors.black),
                  padding: EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Turn On DND - Allow Priority',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 2,
                color: Colors.black,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ), // Bold horizontal line after buttons
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Filter:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    '$_filterName',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Bold horizontal line after Current Filter line
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DND Accessibility:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    '${_isNotificationPolicyAccessGranted! ? 'Granted' : 'Not Granted'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isNotificationPolicyAccessGranted!
                          ? Colors.green // Color for granted
                          : Colors.red, // Color for not granted
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 2,
                color: Colors.black,
                margin: EdgeInsets.symmetric(horizontal: 16),
              ),
              Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Note: Please give DND permission to the app to handle DND by tapping the settings icon on top left.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
