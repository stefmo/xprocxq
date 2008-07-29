package net.xproc.ant;

import org.apache.tools.ant.Project; 
import org.apache.tools.ant.DemuxOutputStream; 
import org.apache.tools.ant.DefaultLogger; 
import org.apache.tools.ant.taskdefs.Echo; 
import java.io.PrintStream; 

public class testEmbedded { 

    private Project project;

    public testEmbedded() {
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

    } 

    public void run(String arg) { 
        project.fireBuildStarted();
        Echo echo=new Echo();        
        echo.setTaskName("Echo");        
        echo.setProject(project);   
        echo.init();                            
        echo.setMessage(arg);   
        echo.execute();       
        project.log("finished"); 
        project.fireBuildFinished(null);   
    } 
    
    public static void main(String args[]) { 
        testEmbedded embed=new testEmbedded();   
        try { 
            embed.run(args[0]);   
        } catch (Exception e) { 
            e.printStackTrace();   
        } 
    } 
} 

