import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarmmate/create_alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'alarm_manager.dart';
// import 'notification_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('AlarmBox');
  await Alarm.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarmmate',
      home: const MyHomePage(title: 'Alarmmate'),
      debugShowCheckedModeBanner: false,
    );
  }
  
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _handColor = Colors.cyan;

  // Map<int, String> alarms= {};

  void addAlarm(int id, String alarmTime){
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    (alarmProvider.alarms[id] = alarmTime);
  }

  void delIndex(int index){
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    int idToDel = alarmProvider.alarms.keys.elementAt(index);
    alarmProvider.deleteAlarm(idToDel);
  }
   
  // late StreamSubscription _alarmSubscription;

  static
  StreamSubscription<AlarmSettings>? _alarmSubscription;
  @override 
  void initState() {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    super.initState();
    if (alarmProvider.alarms.isEmpty){
      Alarm.stopAll();
    }
    _alarmSubscription ??= Alarm.ringStream.stream.listen((_) {
      _onAlarmRinging();
    });
  }

  void _onAlarmRinging(){

    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);

    int id=1;
    DateTime now = DateTime.now();
    var hourNow = now.hour.toString();
    var minuteNow = now.minute.toString();
    String formattedHourNow = hourNow.length == 1 ? '0$hourNow' : hourNow;
    String formattedMinuteNow = minuteNow.length == 1 ? '0$minuteNow' : minuteNow;
    String formattedTime = '$formattedHourNow:$formattedMinuteNow';

    for(var entry in alarmProvider.alarms.entries){
      if (entry.value == formattedTime){
        id = entry.key;
        break;
      }
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Alarm ringing'),
        content: Text('Your alarm for $formattedTime is ringing!', style: TextStyle(color: Colors.cyan, 
        fontSize: 20),),
        actions: [
          TextButton(
            onPressed: () async {
              if (id==1){
                Alarm.stopAll();
              }
              await Alarm.stop(id);
              alarmProvider.deleteAlarm(id);
              Navigator.of(context).pop();
            },
            child: Text('Stop', style: TextStyle(fontSize: 24, color: Colors.cyan),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.karla(
            fontSize: 38,
            color: Colors.cyan
          ),),
          toolbarHeight: 60,
          backgroundColor: Colors.black,
          actions: [IconButton(
            onPressed:(){ Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAlarm()));},
            icon: Icon(Icons.add, color: Colors.white,size: 35,),),],
      ),
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, child){
          return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              margin: EdgeInsets.only(left:71, top: 20),
              decoration: BoxDecoration(
              // color: Colors.white,
              border: Border.all(color:Colors.white, width: 3),
              borderRadius: BorderRadius.circular(9999)
                //image: DecorationImage(image: AssetImage('assets/clock.jpg')),
              ),
              child: AnalogClock(
                dialColor: null,
                markingColor: null,
                hourNumberColor: Color.fromRGBO(255, 255, 255, 1),
                hourHandColor: _handColor,
                minuteHandColor: _handColor,
                secondHandColor: _handColor,
              ),
            ),
            
            Padding(
              padding: EdgeInsets.only(top: 30, left: 20),
              child: Text("Active Alarms",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
              ),
              ),),

              // SizedBox(height: 10,),
              
              SizedBox(
                height: 300,
                child: alarmProvider.alarms.isEmpty
                  ? Center(
                      child: Text(
                        "No active alarms\n\nTap '+' in topright corner to add one",
                        style: GoogleFonts.roboto(
                          color: const Color.fromARGB(86, 255, 255, 255),
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )

                  : ListView.builder(itemCount: alarmProvider.alarms.length,
                      itemBuilder: (context, index){
                      String alarmText = alarmProvider.alarms.values.elementAt(index);
                      return Container(
                        margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                        padding: EdgeInsets.only(top: 8, left: 30),
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan, width: 1.5),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Row(
                          children: [
                            Text(alarmText,
                              style: GoogleFonts.poppins(
                                color: Colors.cyan,
                                fontSize: 32),),
                              
                            Spacer(),
                            IconButton(onPressed: () => {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Deleting alarm for $alarmText!", style: TextStyle(color: Colors.black),),
                                  duration: Duration(seconds: 3),
                                  backgroundColor: const Color.fromARGB(255, 0, 188, 212),
                                ),
                                ),
                              delIndex(index)},
                            icon: Icon(Icons.delete), color: Color.fromARGB(255, 0, 188, 212),)
                          ],
                        )
                      );
                    })
              )
          ],
        );
    })
    );
  }
}
