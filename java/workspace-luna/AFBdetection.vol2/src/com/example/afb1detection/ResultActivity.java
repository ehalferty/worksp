package com.example.afb1detection;

//import java.io.File;
//import java.io.ByteArrayOutputStream;
//import java.io.FileNotFoundException;
//import java.io.FileOutputStream;
//import java.io.BufferedOutputStream;
//import java.io.IOException;
//import android.os.Parcel;
//import android.os.Parcelable;
import java.text.SimpleDateFormat;
import java.util.Date;
//import java.util.List;

import android.app.Activity;
//import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
//import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.os.Bundle;
//import android.os.Environment;
//import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.Button;
//import android.view.ViewGroup;
//import android.widget.Button;
import android.widget.TextView;
import android.widget.ImageView;
import com.example.afb1detection.History;
import com.example.afb1detection.ODRValue;


public class ResultActivity extends Activity {

     private TextView IBText;
     private TextView EquationText;
     private TextView RText;
    // private TextView concentrationText;
     
     private String[] Imean;
     private String[] Isd;
     private String[] IODR;
     private String[] IeODR;
     private String[] AFB1con;
    // private String[] concentrationText;
     private String BG;
     private String BGSTD;
     private String equation;
     private String r;
     //private String AFB1con;
    // private String AFB1constd;
     private Button backButton;
     private ImageView Resultimage;
     private Bitmap scalebitmap;
    // private Matrix matrix;
         
     @Override
     protected void onCreate(Bundle savedInstanceState) {

         super.onCreate(savedInstanceState);
         requestWindowFeature(Window.FEATURE_NO_TITLE);
         setContentView(R.layout.activity_result);
                 
         IBText = (TextView) findViewById(R.id.IBText);
         EquationText = (TextView) findViewById(R.id.EquationText);
         RText = (TextView) findViewById(R.id.RText);
        // concentrationText = (TextView) findViewById(R.id.concentrationText);

         backButton=(Button)findViewById(R.id.backButton);
         backButton.setOnClickListener(new OnClickListener() {
             public void onClick(View v) {
               Intent intent=new Intent(ResultActivity.this, CaptureActivity.class); 
               startActivity(intent); 
             }
         });
         
         Resultimage = (ImageView) findViewById(R.id.resultimage);
         mapp mp = (mapp)getApplication();
         Bitmap greyrectBitmap1 = mp.getBitmap(); 
         
         Matrix matrix = new Matrix();  
         int width =greyrectBitmap1.getWidth();  
         int height = greyrectBitmap1.getHeight();  
         matrix.postScale(0.5f, 0.5f);  
         scalebitmap=Bitmap.createBitmap(greyrectBitmap1, 0, 0, width, height, matrix, false);  
         Resultimage.setImageBitmap( scalebitmap);
       
         // calculate ODR
  	     ODRValue odrValue = new ODRValue();
  	     odrValue.calculateODR(greyrectBitmap1);
  	     Imean = odrValue.getMeanIStr();
  	     Isd = odrValue.getSDIStr();
  	     IODR = odrValue.getODRStr();
  	     IeODR = odrValue.getEODRStr();
  	     BG = odrValue.getBgStr();
  	     BGSTD = odrValue.getBgSdStr();
  	     double[] SampODR = odrValue.getsampleODR();
  	     
  	     double[] y = odrValue.getstandardODR();
  	     double[] x = {0.5,5,20,100,250};
         odrValue.LineCoefficient( x , y );
         equation = odrValue.getequation();
         r = odrValue.getR();
         
         odrValue.calculateconcentration(SampODR);
         AFB1con = odrValue.getconstr();
        // AFB1con = odrValue.getconmean();
        // AFB1constd = odrValue.getconstd();
          	
         ((TextView)findViewById(R.id.sText1)).setText(String
			    .format(" %s ¡À %s ", Imean[0], Isd[0])); 
  	     ((TextView)findViewById(R.id.sText2)).setText(String
			    .format(" %s ¡À %s ", Imean[1], Isd[1]));
	     ((TextView)findViewById(R.id.sText3)).setText(String
			    .format(" %s ¡À %s ", Imean[2], Isd[2]));
	     ((TextView)findViewById(R.id.sText4)).setText(String
			    .format(" %s ¡À %s ", Imean[3], Isd[3]));
         ((TextView)findViewById(R.id.sText5)).setText(String
			    .format(" %s ¡À %s ", Imean[4], Isd[4]));
         ((TextView)findViewById(R.id.sText6)).setText(String
			    .format(" %s ¡À %s ", Imean[5], Isd[5]));
         ((TextView)findViewById(R.id.sText7)).setText(String
			    .format(" %s ¡À %s ", Imean[6], Isd[6]));
         ((TextView)findViewById(R.id.sText8)).setText(String
			    .format(" %s ¡À %s ", Imean[7], Isd[7]));
         ((TextView)findViewById(R.id.sText9)).setText(String
			    .format(" %s ¡À %s ", Imean[8], Isd[8]));
         ((TextView)findViewById(R.id.sText10)).setText(String
			    .format(" %s ¡À %s ", Imean[9], Isd[9]));
         ((TextView)findViewById(R.id.sText11)).setText(String
			    .format(" %s ¡À %s ", Imean[10], Isd[10]));
     
         ((TextView)findViewById(R.id.sText1b)).setText(String
				.format(" %s ¡À %s ", IODR[0], IeODR[0]));
         ((TextView)findViewById(R.id.sText2b)).setText(String
				.format(" %s ¡À %s ", IODR[1], IeODR[1]));
	     ((TextView)findViewById(R.id.sText3b)).setText(String
				.format(" %s ¡À %s ", IODR[2], IeODR[2]));
	     ((TextView)findViewById(R.id.sText4b)).setText(String
				.format(" %s ¡À %s ", IODR[3], IeODR[3]));
         ((TextView)findViewById(R.id.sText5b)).setText(String
				.format(" %s ¡À %s ", IODR[4], IeODR[4]));
         ((TextView)findViewById(R.id.sText6b)).setText(String
				.format(" %s ¡À %s ", IODR[5], IeODR[5]));
         ((TextView)findViewById(R.id.sText7b)).setText(String
				.format(" %s ¡À %s ", IODR[6], IeODR[6]));
         ((TextView)findViewById(R.id.sText8b)).setText(String
				.format(" %s ¡À %s ", IODR[7], IeODR[7]));
         ((TextView)findViewById(R.id.sText9b)).setText(String
				.format(" %s ¡À %s ", IODR[8], IeODR[8]));
         ((TextView)findViewById(R.id.sText10b)).setText(String
				.format(" %s ¡À %s ", IODR[9], IeODR[9]));
         ((TextView)findViewById(R.id.sText11b)).setText(String
				.format(" %s ¡À %s ", IODR[10], IeODR[10]));
     
         IBText.setText(String.format(" %s ¡À %s ", BG, BGSTD));
         EquationText.setText(String.format(" %s ", equation));
         RText.setText(String.format(" %s ", r));
         
         ((TextView)findViewById(R.id.concentrationText1)).setText(String
 				.format(" %sug/kg ", AFB1con[0]));
         ((TextView)findViewById(R.id.concentrationText2)).setText(String
  				.format(" %sug/kg ", AFB1con[1]));
         ((TextView)findViewById(R.id.concentrationText3)).setText(String
  				.format(" %sug/kg ", AFB1con[2]));
        // concentrationText.setText(String.format(" %s ¡À %s ", AFB1con, AFB1constd));
	     
         String outputText = String.format("%s: ODR = %s ¡À %s, %s ¡À %s, %s ¡À %s, %s ¡À %s, %s ¡À %s, %s ¡À %s, %s ¡À %s, %s ¡À %s, %s ¡À %s, %s ¡À %s, %s ¡À %s, Eq: %s, R = %s, Con = %s, %s, %s",
         new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()), IODR[0], IeODR[0], IODR[1], IeODR[1], IODR[2], IeODR[2], IODR[3], IeODR[3], IODR[4], IeODR[4], IODR[5], IeODR[5], IODR[6], IeODR[6], IODR[7], IeODR[7], IODR[8], IeODR[8], IODR[9], IeODR[9], IODR[10], IeODR[10], equation, r, AFB1con[0], AFB1con[1],AFB1con[2]);
     
         // save the result in db
	     HistoryDataSource datasource = new HistoryDataSource(this);
	     datasource.open();
	     History history = datasource.createHistory(outputText);
	     datasource.close();
  	     
     }
     
}