
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.simple.*;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 *
 * @author Alex
 * Classe per il salvataggio e la lettura delle mappe in JSON
 */
public class loader {
    
    public static boolean salva_info_mappa(Scene mappa) {
        //Creo il file Json
        JSONObject info = new JSONObject();
        
        
        
        
        
        return false;
    }
    
    public static Scene read_mappa(File jsonFile) {
        Scene s = new Scene();
        try {
            JSONObject json = convertStreamToJson(new FileInputStream(jsonFile));
            int num_x = (Integer)json.get("cell_x");
            int num_y = (Integer)json.get("cell_y");
            s.setNumCelle(num_x, num_y);
            JSONArray arrayCelle=(JSONArray)json.get("celle");
            for(Object cella : arrayCelle){
                JSONObject cell = (JSONObject) cella;
                s.setCella((Integer)cell.get("x"), (Integer)cell.get("y"), (Integer)cell.get("stato"));
            }
        } catch (FileNotFoundException ex) {
            Logger.getLogger(loader.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
        return s;
    }
    
     private static JSONObject convertStreamToJson(InputStream is) {
        try {
            return (JSONObject) (new JSONParser()).parse(new BufferedReader(new InputStreamReader(is)));
        } catch (IOException | ParseException ex) {
            ex.printStackTrace();
            return null;
        }
    }
    
}
