import edu.ucsd.sccn.LSL;

// ease LSL readings
// NB: will select first playerID found if duplicates
public class ReaderLSL {
  private LSL.StreamInlet inlet;
  private float[] sample;

  // will try to find corresponding playerID within stream_type
  public ReaderLSL(String stream_type, int playerID) {
    println("Resolving LSL stream of type: " + stream_type);
    LSL.StreamInfo[] results;
    results = LSL.resolve_stream("type", stream_type);

    println("Nb streams found: " + str(results.length));


    // try to select ID
    for (int i = 0; i < results.length; i++) {
      // open an inlet
      println("Checking stream: " + str(i));
      LSL.StreamInlet inlet_probe = new LSL.StreamInlet(results[i]);
      try {
        String name = inlet_probe.info().name();
        println("Name: " + name);
        if (name.equals(stream_type + "_" + str(playerID))) {
          println("Found!");
          inlet = inlet_probe;
          break;
        }
      }
      catch(Exception e) {
        println("Error: Can't open stream!");
      }
    }

    if (inlet == null) {
      println("Error, no stream found");
    }

    return;
  }

  public double[] read() {
    return null;
  }
}

