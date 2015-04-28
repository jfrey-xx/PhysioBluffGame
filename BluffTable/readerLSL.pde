import edu.ucsd.sccn.LSL;

// ease LSL readings
// NB: will select first playerID found if duplicates
public class ReaderLSL {
  private LSL.StreamInlet inlet;
  private double[] sample;
  private String name;

  // will try to find corresponding playerID within stream_type
  public ReaderLSL(String stream_type, int playerID) {
    name = stream_type + "_" + str(playerID);
    println("[" + name + "] Resolving LSL stream of type: " + stream_type);
    LSL.StreamInfo[] results;
    results = LSL.resolve_stream("type", stream_type);
    println("[" + name + "] Nb streams found: " + str(results.length));

    // try to select ID
    println("[" + name + "] Looking for: " + name);
    for (int i = 0; i < results.length; i++) {
      // open an inlet
      println("[" + name + "] Checking stream: " + str(i));
      LSL.StreamInlet inlet_probe = new LSL.StreamInlet(results[i]);
      try {
        String probe_name = inlet_probe.info().name();
        int channel_count = inlet_probe.info().channel_count();
        println("[" + name + "] Name: " + probe_name + ", nb channels: " + str(channel_count));
        if (name.equals(probe_name)) {
          println("[" + name + "] Found!");
          inlet = inlet_probe;
          sample = new double[channel_count];
          break;
        }
      }
      catch(Exception e) {
        println("[" + name + "] Error: Can't open stream!");
      }
    }

    if (inlet == null) {
      println("[" + name + "] Error: no stream found");
    }
    
    return;
  }

  // return null if no stream is open
  public double[] read() {
    if (inlet == null)
      return null;
    try {
      inlet.pull_sample(sample);
    }
    catch(Exception e) {
      println("[" + name + "] Error: Can't get sa sample!");
    }
    return sample;
  }
}

