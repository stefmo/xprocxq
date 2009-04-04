/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package net.xproc.util;

import java.io.*;
 
public class StringStream extends PrintStream {
 
    ByteArrayOutputStream out;
 
    public StringStream(ByteArrayOutputStream out) {
        super(System.out);
        this.out = out;
    }
 
    public void write(byte buf[], int off, int len) {
        out.write(buf, off, len);
    }
 
    public void flush() {
       super.flush();
    }
} 
