// Misc stuff, mainly enum

import processing.core.*;
import processing.data.Table;
import processing.data.TableRow;
import java.util.Random; 


// wrapper for several enum linked to BodyPart or HR type

public class Body {

  // body part type
  public enum Type {
    HEAD, EYES, MOUTH, HEART
  };

  // body part genre
  public enum Genre {
    FEMALE, MALE, BOTH
  };

  // HR type
  // Give three information: BPM, variability and stimulation code
  public enum HR {
    LOW(20, 2, "OVTK_GDF_Stage_1"), 
    MEDIUM(70, 4, "OVTK_GDF_Stage_2"), 
    HIGH(120, 8, "OVTK_GDF_Stage_3"), 
    // default BPM value as medium but should read input from physio
    HUMAN(70, 4, "OVTK_GDF_Stage_4");

    // BPM for body part
    public final int BPM;
    // variability (but you've guessed that already)
    public final int variability;
    // stimulation code for openvibe
    public final String code;

    HR(int BPM, int variability, String code) {
      this.BPM = BPM;
      this.variability = variability;
      this.code = code;
    }
  };

  // return the corresponding id for that name
  // TODO: useless, enum to string is done by java...
  static public String getTypeName(Type type) {
    String typeName = "";
    switch(type) {
    case HEAD:
      typeName+="head";
      break;
    case EYES:
      typeName+="eyes";
      break;
    case MOUTH:
      typeName+="mouth";
      break;
    case HEART:
      typeName+="heart";
      break;
    default:
      //println("Error, no name set for this body type: " + type);
      break;
    }
    return typeName;
  }

  // return the corresponding id for that genre
  // TODO: useless, enum to string is done by java...
  static public String getGenreName(Genre genre) {
    String genreName = "";
    switch(genre) {
    case FEMALE:
      genreName+="F";
      break;
    case MALE:
      genreName+="M";
      break;
    case BOTH:
      genreName+="B";
      break;

    default:
      //println("Error, no name set for this body genre: " + genre);
      break;
    }
    return genreName;
  }

  // Holds how may parts are available for eatch. genre/type combination
  private static Table parts = null;

  // to be called before body parts are created to make some randomness happen
  static public void setTableParts(Table parts) {
    Body.parts = parts;
  }

  // return a random number part for ths type/genre
  // "1" every time if no table loaded, 0 if doesn't find anyting
  public static int getRandomPart(Type type, Genre genre) {
    int part_number = 0;
    int nb_parts = 0;
    String type_name = getTypeName(type);
    String genre_name = getGenreName(genre);
    // if possible, tries to randomize part 
    if (parts != null) {
      // select correct type
      PApplet.println("Looking for " + type_name + " parts");
      int[] genre_rows = parts.findRowIndices(type_name, "type");
      PApplet.println("Found " + genre_rows.length + " rows");
      // then loop to match on first good genre
      // TODO: a select more in BDD style..
      PApplet.println("Looking for " + genre_name + " genre");
      for (int i = 0; i < genre_rows.length; i++) {
        TableRow row = parts.getRow(genre_rows[i]);
        if (row.getString("genre").equals(genre_name)) {
          nb_parts = row.getInt("nb_parts");
          PApplet.println("Found: " + nb_parts + " parts");
        }
      }
      // if found something, randomly choose among part
      if (nb_parts > 0) {
        Random rand = new Random();
        part_number = rand.nextInt(nb_parts) + 1;
        PApplet.println("Randomly selected: " + part_number);
      }
      // really not a good time to be here
      // TODO: will probably crash after that when will try to load an invalid file
      else {
        PApplet.println("Number of parts not found, or lesser than 1");
      }
    } else {
      part_number = 1;
      PApplet.println("No randomness.");
    }
    return part_number;
  }
}

