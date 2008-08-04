package net.xproc.ant;

import org.apache.tools.ant.Project; 
import org.apache.tools.ant.BuildException; 
import org.apache.tools.ant.DemuxOutputStream; 
import org.apache.tools.ant.DefaultLogger; 
import org.apache.tools.ant.taskdefs.Echo; 
import java.io.PrintStream; 

public class Embedded { 
    private static Project project; 
    public Embedded() { 
        project = new Project();   
        project.init(); 
        DefaultLogger logger = new net.xproc.ant.SimpleBuildListener();       
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
