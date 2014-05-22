
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
/*

 0 = empty
 1 = wall
 2 = seat
 3 = table
 4 = RecyclableBasket
 5 = trashbasket
 6 = food dispenser
 7 = drink dispenser
 8 = person
 9 = parking

 */
//matrice fondamentale rappresentante la scena

public class Scene {

    //numero di celle sulle x e sulle y
    int num_x, num_y;

    //largezza e altezza celle
    float c_width, c_height;
    //largezza e altezza finestra
    float w_width, w_height;

    int[][] scene;

    int perc;
    
    BufferedImage[] images;

    public Scene(int num_x, int num_y, float w_width, float w_height) {
        this.w_width = w_width;
        this.w_height = w_height;

        scene = new int[num_x][num_y];
        this.resize(num_x, num_y);
        this.initScene(scene);
        this.loadImages("img/");
    }
    
    public void loadImages(String path){
        images = new BufferedImage[9];
        try {
            images[0] = ImageIO.read(new File("wall.jpeg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            images[1] = ImageIO.read(new File("seat.jpg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            images[2] = ImageIO.read(new File("table.jpeg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            images[3] = ImageIO.read(new File("rb.jpeg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            images[4] = ImageIO.read(new File("tb.jpeg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            images[5] = ImageIO.read(new File("fd.jpeg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            images[6] = ImageIO.read(new File("dd.jpg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            images[7] = ImageIO.read(new File("persona.jpg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            images[8] = ImageIO.read(new File("parking.jpeg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }
        
    }

    public void drawScene(Graphics2D g) {

        float x0 = (w_width - c_width * num_x) / 2;
        float y0 = (w_height - c_height * num_y) / 2;
        g.setColor(Color.BLACK);

        for (int i = 0; i < scene.length; i++) {
            for (int j = 0; j < scene[i].length; j++) {
                int x = (int) (x0 + i * c_width);
                int y = (int) (y0 + j * c_height);
                //System.out.println(x + " "+ y + " "+ c_width + " "+ c_height);
                if (scene[i][j]>0) {
                    g.drawImage(images[scene[i][j]-1], x, y,(int) (c_width - 1), (int) (c_height - 1), null);
                }
                g.drawRect(x, y, (int) (c_width - 1), (int) (c_height - 1));
            }
        }
    }

    public void resize(int num_x, int num_y) {
        int[][] new_scene = new int[num_x][num_y];
        perc = 70;
        this.num_x = num_x;
        this.num_y = num_y;
        c_width = (w_width * perc / 100) / num_x;
        c_height = (w_height * perc / 100) / num_y;
        if (c_width > c_height) {
            c_width = c_height;
        } else {
            c_height = c_width;
        }

        initScene(new_scene);
        for (int i = 1; i < new_scene.length - 1; i++) {
            for (int j = 1; j < new_scene[i].length - 1; j++) {
                if (i <= scene.length - 1 && j <= scene[0].length - 1) {
                    new_scene[i][j] = scene[i][j];
                }
            }
        }
        scene = new_scene;
    }

    public void initScene(int[][] scene) {

        for (int i = 0; i < scene.length; i++) {
            for (int j = 0; j < scene[i].length; j++) {
                if (i == 0 || i == scene.length - 1 || j == 0 || j == scene[0].length - 1) {
                    scene[i][j] = 1;
                }
            }
        }
    }

    public String exportScene() {
        String s = "";
        for (int i = 0; i < scene.length; i++) {
            for (int j = 0; j < scene[i].length; j++) {
                switch (scene[i][j]) {
                    case 0:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains Empty))\n";
                        break;
                    case 1:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains Wall))\n";
                        break;
                    case 2:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains Seat))\n";
                        break;
                    case 3:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains Table))\n";
                        break;
                    case 4:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains RB))\n";
                        break;
                    case 5:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains TB))\n";
                        break;
                    case 6:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains FD))\n";
                        break;
                    case 7:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains DD))\n";
                        break;
                    case 8:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains Person))\n";
                        break;
                    case 9:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + i + ") (contains Parking))\n";
                        break;
                }

            }
        }
        return s;
    }

    void click(int x, int y, int state) {
        float x0 = (w_width - c_width * num_x) / 2;
        float y0 = (w_height - c_height * num_y) / 2;
        float cordx = x - x0;
        float cordy = y - y0;
        cordx = cordx / c_width;
        cordy = cordy / c_height;
        int i = (int) cordx;
        int j = (int) cordy;
        scene[i][j] = state;
        
    }
}
