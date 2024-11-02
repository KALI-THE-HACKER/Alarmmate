import 'package:alarm/alarm.dart';
import 'package:alarmmate/main.dart';
import 'alarm_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


DateTime now = DateTime.now();
var hourNow = now.hour.toString();
var minuteNow = now.minute.toString();
String formattedHourNow = hourNow.length == 1 ? '0$hourNow' : hourNow;
String formattedMinuteNow = minuteNow.length == 1 ? '0$minuteNow' : minuteNow;
// List<String> alarms = [];

// Map<int, String> alarms= {};

// void addAlarm(int id, String alarmTime){
//   alarms[id] = alarmTime;
  
// }

class CreateAlarm extends StatefulWidget{

  @override
  _CreateAlarmState createState() => _CreateAlarmState();

}

class _CreateAlarmState extends State<CreateAlarm> {
  

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _hourController.addListener(_updateButtonState);
    _minuteController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      
      _isButtonEnabled = _hourController.text.isNotEmpty && _minuteController.text.isNotEmpty;
    });
  }

  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  void saveAlarm(BuildContext context) async {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);

    String hhtext = _hourController.text;
    String mmtext = _minuteController.text;
    var hh = int.parse(_hourController.text);
    var mm = int.parse(_minuteController.text);
    String formattedhhtext = hhtext.length == 1 ? '0$hhtext': hhtext;
    String formattedmmtext = mmtext.length == 1 ? '0$mmtext': mmtext;

    if(hh<0 || hh>24 || mm <0 || mm > 59){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid time!\nFormat must be HH:MM", style: TextStyle(color: Colors.black, fontSize: 18),),
          duration: Duration(seconds: 4),
          backgroundColor: const Color.fromARGB(233, 237, 15, 15),
        ),
        );
    }
    

    else{
      if (alarmProvider.alarms.containsValue('$formattedhhtext:$formattedmmtext')){
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Alarm for $formattedhhtext:$formattedmmtext already exists!", style: TextStyle(color: Colors.black),),
          duration: Duration(seconds: 3),
          backgroundColor: const Color.fromARGB(233, 237, 15, 15),
        ),
        );
      }
      else{
        int day;
        alarmProvider.addAlarm('$formattedhhtext:$formattedmmtext');
        var currentAlarmTime = alarmProvider.alarms.entries.toList().last.value;
        int id = alarmProvider.alarms.entries.toList().last.key;
    
        if (now.hour>hh || (now.hour==hh && now.minute>mm)){
          day = now.day+1;
        }
        else{
          day = now.day;
        }
        DateTime alarmtime = DateTime(now.year, now.month, day, hh, mm);

        await Alarm.set(
          alarmSettings:
          AlarmSettings(
            id:id, 
            dateTime: alarmtime, 
            assetAudioPath: 'assets/alarm.mp3', 
            vibrate: true,
            notificationSettings: NotificationSettings(title: 'Alarm', body: 'Your alarm is ringing,\ntap to stop!')
            ));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Alarm for $currentAlarmTime is set succesfully!", style: TextStyle(color: Colors.black),),
            duration: Duration(seconds: 3),
            backgroundColor: const Color.fromARGB(255, 0, 188, 212),
          ),
          );
        Navigator.push(context, MaterialPageRoute(builder: (context)=> MyHomePage(title: 'Alarmmate')));
      }
    }
    print(alarmProvider.alarms);
    
  }

  @override
  void dispose() {
    // Dispose the controller when no longer needed
    // _alarmSubscription.cancel();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: 
          IconThemeData(color: Colors.white),
          title: Text('Add Alarm',
          style:
            GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22, 
              fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.black,),
      body: 
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _hourController,
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
                      ],
                  maxLength: 2,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
                    hintText: 'HH',
                  ),
                  style:
                    TextStyle(
                      color: Colors.white,
                      fontSize: 30),
                  )),
            
                  Text("  :  ", style: TextStyle(color: Colors.white, fontSize: 36),),
            
                  SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _minuteController,
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      ],
                  maxLength: 2,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
                    hintText: 'MM',
                  ),
                  style:
                    TextStyle(
                      color: Colors.white,
                      fontSize: 30),
                  ))
              ],
            ),
            
            ElevatedButton(onPressed: _isButtonEnabled ? () => saveAlarm(context) : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            side: BorderSide(color: Colors.cyan, width: 0.7),
            overlayColor: Colors.white,
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
              child:
                Text('Save', style: TextStyle(color: Colors.white, fontSize: 26),
            )),
              
          ],
        )
    );
  }
}