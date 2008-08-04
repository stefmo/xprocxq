/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package net.xproc.ant;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
 
import org.apache.tools.ant.BuildListener;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;
 
/**
 *
 * @author jimfuller
 */
public class AntTargetRunner {
 
    private static Project project;
 
    public static String executeTarget(String build, String basedir1,String target) {
        project = new Project();
        File basedir = new File(basedir1);
        project.init();
        project.addBuildListener(new org.apache.tools.ant.listener.AnsiColorLogger());
        ProjectHelper.getProjectHelper().parse(project, build);
        project.setBaseDir(basedir);
        project.executeTarget(target);
        return "success";
    }
 
}