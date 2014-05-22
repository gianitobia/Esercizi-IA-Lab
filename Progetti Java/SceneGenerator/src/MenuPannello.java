
import javax.swing.JPanel;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author toby
 */
public class MenuPannello extends JPanel{
    private javax.swing.JButton drinkButton;
    private javax.swing.JButton emptyButton;
    private javax.swing.JButton exportButton;
    private javax.swing.JButton foodButton;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JTextField nomeFileField;
    private javax.swing.JTextField num_col_field;
    private javax.swing.JTextField num_row_field;
    private javax.swing.JButton parkingButton;
    private javax.swing.JButton personButton;
    private javax.swing.JButton recyclableButton;
    private javax.swing.JButton seatButton;
    private javax.swing.JButton tableButton;
    private javax.swing.JButton trashButton;
    private javax.swing.JButton updateButton;
    private javax.swing.JButton wallButton;
    private ScenePanel scenePanel;
    private int state;

    public MenuPannello(){
        initComponents();
    }

    private void initComponents() {
        
        jLabel1 = new javax.swing.JLabel();
        num_row_field = new javax.swing.JTextField();
        jLabel2 = new javax.swing.JLabel();
        num_col_field = new javax.swing.JTextField();
        updateButton = new javax.swing.JButton();
        jLabel3 = new javax.swing.JLabel();
        emptyButton = new javax.swing.JButton();
        wallButton = new javax.swing.JButton();
        seatButton = new javax.swing.JButton();
        tableButton = new javax.swing.JButton();
        recyclableButton = new javax.swing.JButton();
        trashButton = new javax.swing.JButton();
        foodButton = new javax.swing.JButton();
        drinkButton = new javax.swing.JButton();
        personButton = new javax.swing.JButton();
        parkingButton = new javax.swing.JButton();
        nomeFileField = new javax.swing.JTextField();
        exportButton = new javax.swing.JButton();

        setPreferredSize(new java.awt.Dimension(280, 720));
        setSize(new java.awt.Dimension(280, 720));

        jLabel1.setText("Dimensioni griglia");

        num_row_field.setText("5");
        num_row_field.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                num_row_fieldActionPerformed(evt);
            }
        });

        jLabel2.setText("x");

        num_col_field.setText("5");
        num_col_field.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                num_col_fieldActionPerformed(evt);
            }
        });

        updateButton.setText("Aggiorna");
        updateButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                updateButtonActionPerformed(evt);
            }
        });

        jLabel3.setText("Inserisci");

        emptyButton.setText("Vuoto");
        emptyButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                emptyButtonActionPerformed(evt);
            }
        });

        wallButton.setText("Muro");
        wallButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                wallButtonActionPerformed(evt);
            }
        });

        seatButton.setText("Sedia");
        seatButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                seatButtonActionPerformed(evt);
            }
        });

        tableButton.setText("Tavolo");
        tableButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                tableButtonActionPerformed(evt);
            }
        });

        recyclableButton.setText("Riciclabile");
        recyclableButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                recyclableButtonActionPerformed(evt);
            }
        });

        trashButton.setText("Cestino");
        trashButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                trashButtonActionPerformed(evt);
            }
        });

        foodButton.setText("Dispenser cibo");
        foodButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                foodButtonActionPerformed(evt);
            }
        });

        drinkButton.setText("Dispenser drink");
        drinkButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                drinkButtonActionPerformed(evt);
            }
        });

        personButton.setText("Persona");
        personButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                personButtonActionPerformed(evt);
            }
        });

        parkingButton.setText("Parcheggio");
        parkingButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                parkingButtonActionPerformed(evt);
            }
        });

        nomeFileField.setText("initMap");
        nomeFileField.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                nomeFileFieldActionPerformed(evt);
            }
        });

        exportButton.setText("Export");
        exportButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                exportButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                        .addComponent(jLabel1)
                        .addGroup(layout.createSequentialGroup()
                            .addComponent(num_row_field, javax.swing.GroupLayout.PREFERRED_SIZE, 30, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                            .addComponent(jLabel2)
                            .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                            .addComponent(num_col_field, javax.swing.GroupLayout.PREFERRED_SIZE, 30, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addComponent(updateButton)
                        .addComponent(jLabel3)
                        .addGroup(layout.createSequentialGroup()
                            .addComponent(emptyButton)
                            .addGap(10, 10, 10)
                            .addComponent(wallButton))
                        .addGroup(layout.createSequentialGroup()
                            .addComponent(seatButton)
                            .addGap(10, 10, 10)
                            .addComponent(tableButton))
                        .addGroup(layout.createSequentialGroup()
                            .addComponent(recyclableButton)
                            .addGap(10, 10, 10)
                            .addComponent(trashButton))
                        .addGroup(layout.createSequentialGroup()
                            .addComponent(foodButton)
                            .addGap(10, 10, 10)
                            .addComponent(drinkButton))
                        .addGroup(layout.createSequentialGroup()
                            .addComponent(personButton)
                            .addGap(10, 10, 10)
                            .addComponent(parkingButton)))
                    .addGroup(layout.createSequentialGroup()
                        .addGap(102, 102, 102)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(exportButton)
                            .addGroup(layout.createSequentialGroup()
                                .addGap(9, 9, 9)
                                .addComponent(nomeFileField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(21, 21, 21)
                .addComponent(jLabel1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel2)
                    .addComponent(num_col_field, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(num_row_field, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addComponent(updateButton)
                .addGap(40, 40, 40)
                .addComponent(jLabel3)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(emptyButton)
                    .addComponent(wallButton))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(seatButton)
                    .addComponent(tableButton))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(recyclableButton)
                    .addComponent(trashButton))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(foodButton)
                    .addComponent(drinkButton))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(personButton)
                    .addComponent(parkingButton))
                .addGap(40, 40, 40)
                .addComponent(nomeFileField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(exportButton)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
    }
    
    private void num_row_fieldActionPerformed(java.awt.event.ActionEvent evt) {                                              

    }                                             

    private void num_col_fieldActionPerformed(java.awt.event.ActionEvent evt) {                                              
    }                                             

    private void updateButtonActionPerformed(java.awt.event.ActionEvent evt) {                                             
        int num_row = Integer.parseInt(num_row_field.getText());
        int num_col = Integer.parseInt(num_col_field.getText());
        if (num_row > 0 && num_col > 0) {
            scenePanel.resizeScene(num_row, num_col);
        }
    }                                            

    private void emptyButtonActionPerformed(java.awt.event.ActionEvent evt) {                                            
        setState(0);
    }                                           

    private void wallButtonActionPerformed(java.awt.event.ActionEvent evt) {                                           
        setState(1);
    }                                          

    private void seatButtonActionPerformed(java.awt.event.ActionEvent evt) {                                           
        setState(2);
    }                                          

    private void tableButtonActionPerformed(java.awt.event.ActionEvent evt) {                                            
        setState(3);
    }                                           

    private void recyclableButtonActionPerformed(java.awt.event.ActionEvent evt) {                                                 
        setState(4);
    }                                                

    private void trashButtonActionPerformed(java.awt.event.ActionEvent evt) {                                            
        setState(5);
    }                                           

    private void foodButtonActionPerformed(java.awt.event.ActionEvent evt) {                                           
        setState(6);
    }                                          

    private void drinkButtonActionPerformed(java.awt.event.ActionEvent evt) {                                            
        setState(7);
    }                                           

    private void personButtonActionPerformed(java.awt.event.ActionEvent evt) {                                             
        setState(8);
    }                                            

    private void parkingButtonActionPerformed(java.awt.event.ActionEvent evt) {                                              
        setState(9);
    }                                             

    private void nomeFileFieldActionPerformed(java.awt.event.ActionEvent evt) {                                              
        // TODO add your handling code here:
    }                                             

    private void exportButtonActionPerformed(java.awt.event.ActionEvent evt) {                                             
        scenePanel.exportScene(nomeFileField.getText());
    }   
    void init(ScenePanel scenePanel) {
        this.scenePanel = scenePanel;
    }

    int getState() {
        return state;
    }

    void setState(int i) {
        state = i;
    }
}
