/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package net.xproc.ant;

import java.io.File;
 
import org.apache.tools.ant.DefaultLogger;
import org.apache.tools.ant.BuildEvent;
import org.apache.tools.ant.BuildListener;
 
public class SimpleBuildListener extends DefaultLogger  {
 
    public void buildFinished(BuildEvent buildEvent) {
    }
 
    public void buildStarted(BuildEvent buildEvent) {
    }
 
    public void messageLogged(BuildEvent buildEvent) {
        System.out.println(" ");
    }
 
    public void targetFinished(BuildEvent buildEvent) {
        System.out.println(" ");
    }
 
    public void targetStarted(BuildEvent buildEvent) {
        System.out.println(" ");
    }
 
    public void taskFinished(BuildEvent buildEvent) {
    }
 
    public void taskStarted(BuildEvent buildEvent) {
    }
 
}
