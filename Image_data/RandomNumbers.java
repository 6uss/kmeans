/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import java.util.Random;

/**
 *
 * @author vh133
 */
import java.io.PrintWriter;
import java.io.File;
import java.io.FileNotFoundException;
public class RandomNumbers {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try{
            
        
        double temp =0;
        File file = new File("test10Million.txt");
        PrintWriter writeTo = new PrintWriter(file);
        for(int i=0; i<10000000; i++)
        {
            writeTo.write(i + " ");
            for(int j = 0; j < 9; j++)
            {
                Random gen= new Random();
                temp = gen.nextDouble()+gen.nextInt(10);
                String tempString = "";
                tempString += temp;
                tempString = String.format("%1.8s", tempString);
                tempString += " ";
                writeTo.write(tempString);
                
            }
            writeTo.write("\n");
        }
        writeTo.close();
        }
        catch(FileNotFoundException ex)
        {
            System.out.println("Ya dungoofed");
        }
        
    }
    
}
