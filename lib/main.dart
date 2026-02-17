// ...existing code...
import 'dart:async'; // import for Timer and Future
import 'dart:math' as math; // import math utilities aliased as math
import 'package:flutter/material.dart'; // import Flutter material widgets
import 'package:shared_preferences/shared_preferences.dart'; // import for persistent storage
import 'package:vibration/vibration.dart'; // import vibration package

void main() => runApp(const AquanimityApp()); // app entrypoint: run the root widget

class AquanimityApp extends StatelessWidget { // root stateless widget for the app
  const AquanimityApp({super.key}); // constructor with optional key

  @override
  Widget build(BuildContext context) { // build method returns widget tree
    return MaterialApp( // Material app wrapper
      debugShowCheckedModeBanner: false, // disable debug banner
      theme: ThemeData.dark().copyWith( // use dark theme and modify
        elevatedButtonTheme: ElevatedButtonThemeData( // customize elevated button theme
          style: ElevatedButton.styleFrom( // style from factory
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // rounded corners
            elevation: 8, // button elevation
          ),
        ),
      ),
      home: const MenuScreen(), // initial screen is MenuScreen
    );
  }
}

class MenuScreen extends StatefulWidget { // main menu stateful widget
  const MenuScreen({super.key}); // constructor

  @override
  State<MenuScreen> createState() => _MenuScreenState(); // create associated state
}

class _MenuScreenState extends State<MenuScreen> { // state class for MenuScreen
  // FIXED: Changed from int to TextEditingController for custom input
  final TextEditingController _timeController = TextEditingController(text: "5"); // controller for duration input
  int totalMetersSaved = 0; // stored total meters saved
  int successfulDives = 0; // stored successful dives count
  int forfeitDives = 0; // stored forfeit dives count
  int metersLost = 0; // stored meters lost count

  @override
  void initState() { // init state lifecycle
    super.initState(); // call parent init
    _loadHistory(); // load persisted stats
  }

  Future<void> _loadHistory() async { // load saved stats asynchronously
    final prefs = await SharedPreferences.getInstance(); // get shared preferences
    setState(() { // update state with loaded values
      totalMetersSaved = prefs.getInt('total_depth') ?? 0; // read total_depth or 0
      successfulDives = prefs.getInt('successful_dives') ?? 0; // read successful_dives or 0
      forfeitDives = prefs.getInt('forfeit_dives') ?? 0; // read forfeit_dives or 0
      metersLost = prefs.getInt('meters_lost') ?? 0; // read meters_lost or 0
    });
  }

  @override
  Widget build(BuildContext context) { // build UI for menu
    return Scaffold( // scaffold provides structure
      body: Container( // container for background gradient
        decoration: const BoxDecoration( // box decoration constant
          gradient: LinearGradient( // linear gradient background
            begin: Alignment.topCenter, // gradient start
            end: Alignment.bottomCenter, // gradient end
            colors: [Color(0xFF001D3D), Colors.black], // gradient colors
          ),
        ),
        child: Center( // center content
          child: SingleChildScrollView( // prevents overflow when keyboard opens
            child: Column( // vertical layout
              mainAxisAlignment: MainAxisAlignment.center, // center children vertically
              children: [
                const Icon(Icons.waves, color: Colors.cyanAccent, size: 50), // logo icon
                const Text("AQUANIMITY", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8)), // title text
                const SizedBox(height: 40), // spacer

                // Logbook
                Container( // container for logbook total
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), // internal padding
                  decoration: BoxDecoration( // decoration for container
                    color: Colors.white.withValues(alpha: 0.05), // translucent background color
                    borderRadius: BorderRadius.circular(20), // rounded corners
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)), // cyan border
                  ),
                  child: Column( // column inside container
                    children: [
                      const Text("LOGBOOK TOTAL", style: TextStyle(color: Colors.cyanAccent, fontSize: 14)), // small label
                      Text("$totalMetersSaved m", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), // dynamic total display
                    ],
                  ),
                ),

                const SizedBox(height: 60), // spacer

                // NEW: Duration Input Field
                const Text("Enter Dive Duration (Minutes):", style: TextStyle(color: Colors.grey)), // input label
                const SizedBox(height: 10), // spacer
                SizedBox( // size constraint for input
                  width: 200, // fixed width
                  child: TextField( // text input field
                    controller: _timeController, // link controller
                    keyboardType: TextInputType.number, // numeric keyboard
                    textAlign: TextAlign.center, // center input text
                    style: const TextStyle(fontSize: 24, color: Colors.cyanAccent), // input text style
                    decoration: InputDecoration( // input decoration
                      hintText: "Enter mins", // hint text
                      helperText: "Type '0' for Endless", // helper text
                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(15)), // enabled border style
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(15)), // focused border style
                    ),
                  ),
                ),

                const SizedBox(height: 40), // spacer

                ElevatedButton( // launch sub button
                  style: ElevatedButton.styleFrom( // button style
                    backgroundColor: Colors.cyanAccent[700], // background color
                    foregroundColor: Colors.white, // text/icon color
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22) // padding
                  ),
                  onPressed: () async { // on press handler
                    int mins = int.tryParse(_timeController.text) ?? 5; // parse minutes from input or default 5
                    await Navigator.push( // navigate to DiveScreen
                      context,
                      MaterialPageRoute(builder: (context) => DiveScreen(durationMinutes: mins == 0 ? -1 : mins)), // pass -1 for endless when 0
                    );
                    _loadHistory(); // reload stats after returning
                  },
                  child: const Text("LAUNCH SUB", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // button label
                ),

                const SizedBox(height: 20), // spacer

                ElevatedButton( // stats button
                  style: ElevatedButton.styleFrom( // style for stats button
                    backgroundColor: Colors.purpleAccent[700], // background color
                    foregroundColor: Colors.white, // text color
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22) // padding
                  ),
                  onPressed: () async { // on press handler
                    await _loadHistory(); // ensure Menu has latest values before navigating
                    if (!mounted) return; // guard BuildContext after async gap
                    await Navigator.push( // navigate to StatsScreen
                      context,
                      MaterialPageRoute(builder: (context) => const StatsScreen()), // StatsScreen loads prefs itself
                    );
                    if (!mounted) return; // guard before updating state after return
                    await _loadHistory(); // reload stats on return
                  },
                  child: const Text("DEPTH STATS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // button label
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiveScreen extends StatefulWidget { // dive screen stateful widget
  final int durationMinutes; // duration in minutes, -1 means endless
  const DiveScreen({super.key, required this.durationMinutes}); // constructor with required duration

  @override
  State<DiveScreen> createState() => _DiveScreenState(); // create state
}

class _DiveScreenState extends State<DiveScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin { // state with lifecycle observer and ticker provider
  int secondsPassed = 0; // seconds passed counter used as depth
  bool isDiving = false; // whether dive is active
  Timer? timer; // periodic timer instance
  String statusMessage = "Pressure Seals: Nominal"; // status text shown to user
  late AnimationController _radarController; // animation controller for radar icon

  @override
  void initState() { // init state lifecycle
    super.initState(); // call super
    WidgetsBinding.instance.addObserver(this); // register widget lifecycle observer
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(); // start repeating radar animation
  }

  @override
  void dispose() { // dispose lifecycle
    WidgetsBinding.instance.removeObserver(this); // remove lifecycle observer
    _radarController.dispose(); // dispose animation controller
    timer?.cancel(); // cancel timer if active
    super.dispose(); // call super dispose
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { // app lifecycle change handler
    if (isDiving && state == AppLifecycleState.paused) { // if diving and app paused (backgrounded)
      _triggerTheBends(); // trigger penalty
    }
  }

  void _triggerTheBends() async { // penalty handler for backgrounding during dive
    
    if (mounted) { // only show snackbar if widget still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ VIBRATING: THE BENDS!"), duration: Duration(seconds: 2)) // show warning
      );
    }

    bool? hasVib = await Vibration.hasVibrator(); // check vibrator availability
    if (hasVib == true) { // if vibrator present
      Vibration.vibrate(pattern: [0, 500, 200, 500]); // vibrate with pattern
    }
    stopDive(wasforced: true); // stop dive and mark forced
  }

  void startDive() { // start dive routine
    setState(() { // update state
      isDiving = true; // set diving flag
      secondsPassed = 0; // reset depth counter
      statusMessage = "DESCENT INITIATED"; // update status message
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) { // start timer ticking each second
      setState(() { // update state each tick
        secondsPassed++; // increment depth/seconds
        if (widget.durationMinutes != -1 && secondsPassed >= (widget.durationMinutes * 60)) { // if duration reached (and not endless)
          stopDive(wasforced: false); // stop dive normally
        }
      });
    });
  }

  void stopDive({bool wasforced = false}) async { // stop dive, optional forced flag
    timer?.cancel(); // cancel periodic timer
    int finalDepth = secondsPassed; // record final depth

    if (!wasforced && finalDepth > 0) { // normal successful dive with depth > 0
      final prefs = await SharedPreferences.getInstance(); // get prefs
      int currentTotal = prefs.getInt('total_depth') ?? 0; // read current total
      await prefs.setInt('total_depth', currentTotal + finalDepth); // add final depth to total

      // Track successful dive
      int successfulCount = prefs.getInt('successful_dives') ?? 0; // read successful dives count
      await prefs.setInt('successful_dives', successfulCount + 1); // increment successful dives
    } else if (wasforced && finalDepth > 0) { // forced stop (forfeit) with depth > 0
      // Track forfeit dive and meters lost and apply penalty to total_depth
      final prefs = await SharedPreferences.getInstance(); // get prefs once
      int forfeitCount = prefs.getInt('forfeit_dives') ?? 0; // read forfeit count
      await prefs.setInt('forfeit_dives', forfeitCount + 1); // increment forfeit count

      int lostMeters = prefs.getInt('meters_lost') ?? 0; // read meters lost
      await prefs.setInt('meters_lost', lostMeters + finalDepth); // add lost meters

      // APPLY PURPOSE: remove lost meters from total_depth as a penalty (never negative)
      int currentTotal = prefs.getInt('total_depth') ?? 0; // read current total depth
      int newTotal = currentTotal - finalDepth; // subtract lost meters
      if (newTotal < 0) newTotal = 0; // clamp to zero
      await prefs.setInt('total_depth', newTotal); // save penalized total
    }

    setState(() { // update UI state after stopping
      isDiving = false; // clear diving flag
      statusMessage = wasforced ? "HULL BREACH: THE BENDS" : "DIVE LOGGED: $finalDepth m"; // set status message accordingly
      if (wasforced) secondsPassed = 0; // reset counter on forced stop
    });
  }

  @override
  Widget build(BuildContext context) { // build UI for dive screen
    // Target depth calculation for the display
    String targetDisplay = widget.durationMinutes == -1 ? "ENDLESS" : "${widget.durationMinutes * 60}m"; // compute display string

    return Scaffold( // scaffold for dive screen
      backgroundColor: Color.lerp(Colors.blue[900], Colors.black, (secondsPassed / 1000).clamp(0, 1)), // interpolate background color by depth
      body: Stack( // stack layout to overlay widgets
        children: [
          // NEW: Target Depth in top-left corner
          Positioned( // position target display
            top: 50, // distance from top
            left: 20, // distance from left
            child: Column( // column for label + value
              crossAxisAlignment: CrossAxisAlignment.start, // left align content
              children: [
                const Text("TARGET DEPTH", style: TextStyle(fontSize: 10, color: Colors.cyanAccent, letterSpacing: 1)), // small label
                Text(targetDisplay, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // dynamic target depth
              ],
            ),
          ),

          if (isDiving) // only show radar when diving
            Positioned( // position radar icon top-right
              top: 50, // distance from top
              right: 20, // distance from right
              child: AnimatedBuilder( // animate rotation
                animation: _radarController, // animation controller
                builder: (context, child) { // builder callback
                  return Transform.rotate( // rotate child widget
                    angle: _radarController.value * 2 * math.pi, // compute rotation angle
                    child: Icon(Icons.track_changes, color: Colors.cyanAccent.withValues(alpha: 0.5), size: 40), // radar icon
                  );
                },
              ),
            ),
            
          Center( // center main content
            child: Column( // vertical layout
              mainAxisAlignment: MainAxisAlignment.center, // center vertically
              children: [
                Text( // display current depth/seconds
                  "$secondsPassed m", // show value with unit
                  style: TextStyle( // large text style
                    fontSize: 90, // font size
                    fontWeight: FontWeight.w100, // weight
                    color: Colors.cyanAccent, // color
                    shadows: [Shadow(blurRadius: 20, color: Colors.cyanAccent.withValues(alpha: 0.5))] // glow shadow
                  )
                ),
                Text(statusMessage.toUpperCase(), style: const TextStyle(letterSpacing: 2)), // uppercase status message
                const SizedBox(height: 80), // spacer

                if (!isDiving && secondsPassed == 0) // show engage button when idle and zero
                  ElevatedButton(onPressed: startDive, child: const Text("ENGAGE ENGINES")), // start dive button
                  
                if (isDiving) // show ascend button when diving
                  OutlinedButton(onPressed: () => stopDive(), child: const Text("INITIATE ASCENT")), // stop dive button

                if (!isDiving && secondsPassed > 0) // show back button after a dive ended
                  Padding( // add top padding
                    padding: const EdgeInsets.only(top: 20.0), // only top padding
                    child: TextButton.icon( // text button with icon
                      onPressed: () => Navigator.pop(context), // pop back to menu
                      icon: const Icon(Icons.arrow_back), // back icon
                      label: const Text("BACK TO SHIP") // label
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatsScreen extends StatefulWidget { // stats screen stateful widget
  const StatsScreen({super.key}); // no longer requires injected values

  @override
  State<StatsScreen> createState() => _StatsScreenState(); // create state
}

class _StatsScreenState extends State<StatsScreen> { // state class for stats
  int successfulDives = 0; // local copy of successful dives
  int forfeitDives = 0; // local copy of forfeit dives
  int metersLost = 0; // local copy of meters lost

  @override
  void initState() {
    super.initState();
    _loadStats(); // load current stats from SharedPreferences
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      successfulDives = prefs.getInt('successful_dives') ?? 0;
      forfeitDives = prefs.getInt('forfeit_dives') ?? 0;
      metersLost = prefs.getInt('meters_lost') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) { // build UI
    return Scaffold( // scaffold wrapper
      body: Container( // container with gradient background
        decoration: const BoxDecoration( // box decoration
          gradient: LinearGradient( // linear gradient
            begin: Alignment.topCenter, // start alignment
            end: Alignment.bottomCenter, // end alignment
            colors: [Color(0xFF001D3D), Colors.black], // colors
          ),
        ),
        child: Center( // center content
          child: Column( // vertical layout
            mainAxisAlignment: MainAxisAlignment.center, // center vertically
            children: [
              const Icon(Icons.analytics, color: Colors.purpleAccent, size: 50), // analytics icon
              const Text("DEPTH STATISTICS", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8)), // title
              const SizedBox(height: 60), // spacer

              // Successful Dives
              Container( // container for successful dives
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), // padding
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // margin
                decoration: BoxDecoration( // decoration
                  color: Colors.green.withValues(alpha: 0.1), // green tinted background
                  borderRadius: BorderRadius.circular(20), // rounded corners
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)), // border color
                ),
                child: Column( // inner column
                  children: [
                    const Text("SUCCESSFUL DEPTH", style: TextStyle(color: Colors.greenAccent, fontSize: 14)), // label
                    Text("$successfulDives", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), // value display
                  ],
                ),
              ),

              // Forfeit Dives
              Container( // container for forfeit dives
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), // padding
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // margin
                decoration: BoxDecoration( // decoration
                  color: Colors.orange.withValues(alpha: 0.1), // orange background tint
                  borderRadius: BorderRadius.circular(20), // rounded corners
                  border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)), // border color
                ),
                child: Column( // inner column
                  children: [
                    const Text("DEPTH FORFEIT", style: TextStyle(color: Colors.orangeAccent, fontSize: 14)), // label
                    Text("$forfeitDives", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), // value display
                  ],
                ),
              ),

              // Meters Lost
              Container( // container for meters lost
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), // padding
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // margin
                decoration: BoxDecoration( // decoration
                  color: Colors.red.withValues(alpha: 0.1), // red tint background
                  borderRadius: BorderRadius.circular(20), // rounded corners
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)), // border
                ),
                child: Column( // inner column
                  children: [
                    const Text("METERS LOST", style: TextStyle(color: Colors.redAccent, fontSize: 14)), // label
                    Text("$metersLost m", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), // value display with unit
                  ],
                ),
              ),

              const SizedBox(height: 60), // spacer

              TextButton.icon( // back button with icon
                onPressed: () => Navigator.pop(context), // pop back to menu
                icon: const Icon(Icons.arrow_back), // icon
                label: const Text("BACK TO SHIP"), // label
              ),
            ],
          ),
        ),
      ),
    );
  }
}