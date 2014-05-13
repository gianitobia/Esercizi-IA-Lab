
import java.awt.Color;
import java.awt.Graphics2D;

//matrice fondamentale rappresentante la scena

public class Scene
{
  //numero di celle sulle x e sulle y
  int num_x, num_y;
  
  //largezza e altezza celle
  float c_width,c_height;
  //largezza e altezza finestra
  float w_width,w_height;
  
  int[][] scene;

  int perc;
    
  public Scene(int num_x, int num_y, float w_width, float w_height)
  {
    perc = 70;
    this.num_x = num_x;
    this.num_y = num_y;
    this.w_width = w_width;
    this.w_height = w_height;
    c_width = (w_width*perc/100)/num_x;
    c_height = (w_height*perc/100)/num_y;
    if(c_width>c_height)c_width=c_height;
    else c_height=c_width;
    System.out.println(num_x + " "+ num_y + " "+ c_width + " "+ c_height+ " "+ w_width + " "+ w_height);
    
    scene = new int[num_x][num_y];

  }
  
  public void drawScene(Graphics2D g)
  {
    g.setColor(Color.BLACK);
    float x0 = (w_width-c_width*num_x)/2;
    float y0 = (w_height-c_height*num_y)/2;
    for(int i=0;i<scene.length;i++){
      for(int j=0;j<scene[i].length;j++){
        
        int x = (int)(x0 + i * c_width);
        int y = (int)(y0 + j * c_height);
        //System.out.println(x + " "+ y + " "+ c_width + " "+ c_height);
        g.drawRect(x,y,(int)(c_width-1),(int)(c_height-1));
      }
    }
  }
}