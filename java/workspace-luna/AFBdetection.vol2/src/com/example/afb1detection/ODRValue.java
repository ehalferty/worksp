package com.example.afb1detection;

//import java.util.ArrayList;
//import java.util.List;
//import java.text.DecimalFormat;
//import java.lang.Object;
import java.lang.Math;
import com.example.afb1detection.Gongshi;
import android.graphics.Bitmap;
//import android.graphics.Bitmap.Config;
import android.graphics.Color;
//import android.graphics.Matrix;
//import android.util.Log;

public class ODRValue {
	
	 //private static final String TAG = "ODRValue";

     public static int numOfStrips = 11;
	 public static int numOfbackgrounds = 3;
     public static int numOfSamples = 3;
     public static int numOfStandard = 6;

	 private float[] meanI = new float[numOfStrips];
	 private float[] sdI = new float[numOfStrips];
	 private float[] ODR = new float[numOfStrips];
	 private float[] eODR = new float[numOfStrips]; 
     private float[] bgMeans= new float[numOfbackgrounds];
     //private float[] bgSDs = new float[numOfbackgrounds];
     private float[] sampleODR = new float[numOfSamples];
    // private float[] samplestd = new float[numOfSamples];
     private float[] standardODR = new float[numOfStandard];
     private String[] Con = new String[numOfSamples];
	 private float bg;
	 private float bgSd;
    // private float sampleODRmean;
    // private float samplestdmean;
     //private float concentrationmean;
     //private float concentrationstd;
     //private String concentrationmean1;
     //private String concentrationstd1;
     private float[] gmean = new float [3];
   //  private float[] std = new float [3];
     private String a1;
     private String b1;
     private String r1;
     private double a2;
     private double b2;
     
     public void calculateODR(Bitmap image) {
         
         //int width = image.getWidth();
	    // int height = image.getHeight();
        // double hRatio = width / 640;
	    // double vRatio = height / 480;
	     int sWidth = (int)(9);
	     int sxWidth = (int)(sWidth / 3);
	     //int sHeight = (int)(480 * vRatio);
        // int sxdHeight = (int)(160 * vRatio);
         int bgWidth = (int)(23);
	     int Height = (int)(260);
         int initYPos = 0;//(400 * vRatio);
         //int yOffset = 160;// * vRatio);

         int[] xPosbg = {(int)(98), (int)(292), (int)(488)};//背景起点位置

         int[] xPossp = {(int)(33), (int)(81), (int)(130), (int)(178), (int)(228), (int)(276), (int)(324), (int)(373), (int)(422), (int)(471), (int)(520)};//11条带起点位置

         //背景
         for (int i = 0; i < bgMeans.length; i++) {

        	  int[] pixelsBg = new int[bgWidth * Height];
              image.getPixels(pixelsBg, 0, bgWidth, xPosbg[i], initYPos, bgWidth, Height);          
              bgMeans[i] = Gongshi.getMean(getLuminosity(pixelsBg));
               
         }
         
         bg = Gongshi.getMean(bgMeans);
         bgSd = Gongshi.getSampleStdDev(bgMeans);

         //条带
         for (int i = 0; i < meanI.length; i++){
            for (int k = 0; k< 3; k++){
                int[] pixelssp = new int[sxWidth*Height];
                image.getPixels(pixelssp, 0, sxWidth, xPossp[i]+ sxWidth*k, initYPos, sxWidth, Height);                           
                gmean[k]=Gongshi.getMean(getLuminosity(pixelssp));
            }
            
            meanI[i] = Gongshi.getMean(gmean);
            sdI[i] = Gongshi.getSampleStdDev(gmean);
            ODR[i] = getODR(meanI[i], bg);
            eODR[i] = getODRError(ODR[i], meanI[i], sdI[i]);
         }
         
         //标品
         for (int i = 0; i < 5; i++){
              standardODR[i] = ODR[i+2]-ODR[0];   
         } 

         //样品
         for (int i = 0; i < 3; i++){
              sampleODR[i] = ODR[i+8]-ODR[0];
            //  samplestd[i] = eODR[i+8];
         }
     }
      	
 	 private static float[] getLuminosity(int[] pixels) {
 		 float[] sampleLuminosity = new float[pixels.length];
 		 for (int i = 0; i < pixels.length; i++) {
 			 float r = Color.red(pixels[i]);
 			 float g = Color.green(pixels[i]);
 			 float b = Color.blue(pixels[i]);
 			 sampleLuminosity[i] = (float) (0.3 * r + 0.59 * g + 0.11 * b);
 		 }
 		 return sampleLuminosity;
 	 }
     
     private static float getODR(float I, float bg) {     		
   		 if (Math.abs(bg - I) < 0.00001) {
   			 return 0.0f;
   		 }
   		 return (bg - I) / bg;
   	 }
     
     private static float getODRError(float ODR, float IS, float IError) {
        //float ans = Math.abs(ODR * IError / IS);
     	//Log.e(TAG, String.format("%f, %f, %f, %f", ODR, IS, IError, ans));
     	return Math.abs(ODR * IError / IS);
     }
     
     public String getBgStr() {
 		return Gongshi.setformat1(bg);
 	 }
 	
 	 public String getBgSdStr() {
 		return Gongshi.setformat1(bgSd);
 	 }

 	 public String[] getODRStr() {
 		//String [] ODRStr = Common.getSigFig(ODR, numOfSigFig);
 		//for (int i=0; i<ODR.length; i++) {
 		//	Log.e(TAG, String.valueOf(ODR[i]) + " " + ODRStr[i]);
 		//}
 		return Gongshi.setformat2(ODR);
 	 }
 	
 	 public String[] getEODRStr() {
 		return Gongshi.setformat2(eODR);
 	 }
 	
 	 public String[] getMeanIStr() {
 		return Gongshi.setformat1(meanI);
 	 }
 	
 	 public String[] getSDIStr() {
 		return Gongshi.setformat1(sdI);
 	 }
 	 
     public double[] getstandardODR(){
        return Gongshi.setformat3(standardODR);
     }
     
     public double[] getsampleODR(){
        return Gongshi.setformat3(sampleODR);
     }
     
     public void LineCoefficient(double[] x , double[] y ){
         
         double[] X = new double[x.length];

         for (int i = 0; i < x.length; i++){
              X[i] = (double) ((Math.log(x[i])) / (Math.log(10)));
         }
         
         double a = getXc( X , y ) ; 
         double b = getC( X , y ) ; 
         double r = getr( X , y );
         a1 = Gongshi.setformat2((float)a);
         b1 = Gongshi.setformat2((float)b);
         r1 = Gongshi.setformat2((float)r);
         a2 = Gongshi.setformat3((float)a);
         b2 = Gongshi.setformat3((float)b);
        
     }
     
     public static double getXc( double[] X , double[] y ){ 
          int n = X.length ; 
          return ( n * pSum( X , y ) - sum( X ) * sum( y ) )  / ( n * sqSum( X ) - Math.pow(sum(X), 2) ) ; 
     }
     
     public static double getC( double[] X , double[] y ){ 
          int n = X.length ; 
          double t = getXc( X , y ) ; 
          return sum( y ) / n - t * sum( X ) / n ; 
     }
     
     public static double getr( double[] X , double[] y ){
          int n = X.length ;
          return Math.abs(( n * pSum( X , y ) - sum( X ) * sum( y ) ) ) / Math.sqrt( ( n * sqSum( X ) - Math.pow(sum(X), 2) )* ( n * sqSum( y ) - Math.pow(sum(y), 2) ) );            
     }
     
     private static double sum(double[] ds) { 
          double s = 0 ; 
          for( double d : ds ) {  
               s = s + d ;
          }
          return s ;  
     }

     private static double sqSum(double[] ds) { 
          double s = 0 ; 
          for( double d : ds ) {
               s = s + Math.pow(d, 2) ; 
          }
          return s ; 
     } 

     private static double pSum( double[] X , double[] y ) { 
          double s = 0 ; 
          for( int i = 0 ; i < X.length ; i++ ) {
               s = s + X[i] * y[i] ; 
          }
          return s ; 
     } 

     public String getequation(){
          return "y="+a1+" * "+"x"+" + " +b1;
     }
     
     public String getR(){
          return r1;
     } 
     
     public void calculateconcentration(double[] sampleodr){

          float[] samplecon = new float[sampleodr.length]; 
         
          for ( int i = 0; i < sampleodr.length; i++){
               samplecon[i]  = (float) ((Math.pow(10,(( sampleodr[i] - b2 ) / a2))) * 15);         
          }
         // concentrationmean = Gongshi.getMean(sampleconcentration);
         // concentrationstd = Gongshi.getSampleStdDev(sampleconcentration);
          //concentrationmean1 = Gongshi.setformat1(concentrationmean);
          //concentrationstd1 = Gongshi.setformat1(concentrationstd);
          Con = Gongshi.setformat1(samplecon);
     }
     
     //public String getconmean(){
      //   return concentrationmean1;
     //}
     public String[] getconstr(){
    	 return Con;
     }
     //public String getconstd(){
      //   return concentrationstd1+"ng/mL";
     //}

}
