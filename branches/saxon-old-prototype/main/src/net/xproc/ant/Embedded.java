// this is just a test bed for the time being

package net.xproc.ant;

import java.io.IOException;
import java.io.*;

import net.xproc.util.StringStream;
        
import org.apache.tools.ant.Project; 
import org.apache.tools.ant.BuildException; 
import org.apache.tools.ant.DemuxOutputStream; 
import org.apache.tools.ant.DefaultLogger; 
import org.apache.tools.ant.taskdefs.Echo; 
import org.apache.tools.ant.taskdefs.Execute; 
import org.apache.tools.ant.Task;

import java.io.PrintStream; 

public class Embedded { 
    
    private static Project project;
    private static PrintStream backupSystemOut = System.out;
    private static ByteArrayOutputStream out = new ByteArrayOutputStream();
    private static PrintStream stringStream = new StringStream(out);             
      
    public Embedded() { 
        project = new Project();   
        project.init(); 
        DefaultLogger logger = new DefaultLogger();       
        project.addBuildListener(logger);                 
        logger.setOutputPrintStream(System.out);          
        logger.setErrorPrintStream(System.err);           
        logger.setMessageOutputLevel(Project.MSG_INFO);   
        System.setOut(                                 
          new PrintStream(                             
            new DemuxOutputStream(project, false)));   
        System.setErr(                                 
          new PrintStream(                             
            new DemuxOutputStream(project, true)));    
        project.fireBuildStarted(); 
    } 


    public void destroy() {
        System.setOut(backupSystemOut);
    }


    public static String execute(String[] command){
        System.setOut(stringStream);
        out.reset();

        Execute execute = new Execute();
        execute.setCommandline(command);
        try { 

            execute.execute();
        } catch (java.io.IOException e) { 
            e.printStackTrace();   
        }
        return out.toString();
    }


    public static String echo(String message) { 
        System.out.println("running"); 
        Echo echo=new Echo();        
        echo.setTaskName("Echo");        
        echo.setProject(project);   
        echo.init();                            
        echo.setMessage(message);   
        echo.execute();       
        project.log("finished"); 
        project.fireBuildFinished(null);   
        return "success";
    } 

        
    public static String doTask(String arg) { 
        Embedded embed=new Embedded();   
        String test = null;
        try { 
            test = embed.echo(arg);  
        } catch (BuildException e) { 
            e.printStackTrace();   
        } 
            return test;

    } 
    
    public static void main(String args[]) { 
        Embedded embed=new Embedded();   
        try { 
            String test = embed.echo(args[0]);   
        } catch (BuildException e) { 
            e.printStackTrace();   
        } 
    } 
} 
