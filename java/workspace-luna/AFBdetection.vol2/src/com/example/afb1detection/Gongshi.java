package com.example.afb1detection;

//import java.text.DecimalFormat;
import java.math.BigDecimal;
//import java.math.MathContext;
//import java.math.RoundingMode;
//import android.graphics.Bitmap;
//import android.graphics.Color;
//import android.graphics.Matrix;
//import android.os.Environment;
//import android.util.Log;


public class Gongshi {
	
	 public static boolean DEBUG = false;
	
	 public static float getMean(float[] values) {
		 float sum = 0;
		 for (float value : values) {
				sum += value;
		 }
		 return sum / values.length;
	 }
	 
	 public static float getSampleVariance(float[] values){
		 float mean = getMean(values);
		 float sum = 0;
	     for (float value : values) {
	        	sum += (value - mean) * (value - mean);
	     }
	     return sum / (values.length - 1);
	 }
	 
	 public static float getSampleStdDev(float[] values){

        return (float) Math.sqrt(getSampleVariance(values));
     }
	 
	 public static String setformat1(float value){
		 BigDecimal bd = new BigDecimal(value);
		 String	 result = bd.setScale(2, BigDecimal.ROUND_HALF_UP).toString();
		 return result;
	 }
	 
	// public static String setformat1(float value){
     //   DecimalFormat df1 = new DecimalFormat("###.00");
      //  String result = df1.format(value);
      //  return result;
   // }
     public static String[] setformat1(float[] values){
         String[] result = new String[values.length];
         for (int i = 0; i < values.length; i++) {
	         result[i] = setformat1(values[i]);
	     }
	     return result;
     }
   
     public static String setformat2(float value){
    	 BigDecimal bd = new BigDecimal(value);
    	 String	result = bd.setScale(3, BigDecimal.ROUND_HALF_UP).toString();
       	 return result;
     }
     
   // public static String setformat2(float value){
   //     DecimalFormat df2 = new DecimalFormat("###.000");
   //     String result = df2.format(value);
   //     return result;
   // }
     public static String[] setformat2(float[] values){
         String[] result = new String[values.length];
         for (int i = 0; i < values.length; i++) {
	        result[i] = setformat2(values[i]);
	     }
	     return result;
     }
     
     public static double setformat3(float value){
   	     BigDecimal bd = new BigDecimal(value);
   	     double result = bd.setScale(3, BigDecimal.ROUND_HALF_UP).floatValue() ;
   	     return result;
     }
     
     public static double[] setformat3(float[] values){
   	     double[] result = new double[values.length];
   	     for (int i = 0; i < values.length; i++) {
   		    result[i] = setformat3(values[i]);
   	     }
   	     return result;
     }
   
}
