/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package net.xproc.ant;

/**
 *
 * @author jimfuller
 */
public class NewClass {
    // /*  */ //
 public static void main( String[] args )
    {
     
     int a = 1;
     int x = 5;
     int y =5;
      switch (a){      
        case 1:
           System.out.println("Enter the number one=" + (x+y));
           break;
        case 2:
          System.out.println("Enter the number two=" + (x-y));
          break;
        case 3:
          System.out.println("Enetr the number three="+ (x*y));
          break;
        case 4:
          System.out.println("Enter the number four="+ (x/y));
          break;
        default:
          System.out.println("Invalid Entry!");
          break;
      }
   } 
}
