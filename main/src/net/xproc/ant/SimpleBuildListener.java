/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package net.xproc.ant;

import java.io.File;
 
import org.apache.tools.ant.BuildEvent;
import org.apache.tools.ant.BuildListener;
 
public class SimpleBuildListener implements BuildListener {
 
    public void buildFinished(BuildEvent buildEvent) {
    }
 
    public void buildStarted(BuildEvent buildEvent) {
    }
 
    public void messageLogged(BuildEvent buildEvent) {
        System.out.println(" ["+buildEvent.getTask().getTaskName()+"] "+buildEvent.getMessage());
    }
 
    public void targetFinished(BuildEvent buildEvent) {
        System.out.println("target finished");
    }
 
    public void targetStarted(BuildEvent buildEvent) {
        System.out.println(buildEvent.getTarget().getName()+":");
    }
 
    public void taskFinished(BuildEvent buildEvent) {
    }
 
    public void taskStarted(BuildEvent buildEvent) {
    }
 
}
