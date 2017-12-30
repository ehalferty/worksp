package com.example.afb1detection;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.net.Uri;
import java.text.SimpleDateFormat;
import java.util.Date;
//import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
//import android.graphics.PixelFormat; 
import android.graphics.Canvas;
//import android.graphics.Color;
import android.graphics.Matrix;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.ShutterCallback;
import android.hardware.Camera.PictureCallback;
import android.hardware.Camera.PreviewCallback;
//import android.hardware.Camera.Size;
import android.util.DisplayMetrics; 
import android.os.Bundle;
//import android.os.Environment;
//import android.os.Handler;
import com.example.afb1detection.DrawImageView;
import com.example.afb1detection.R;

import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
//import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
//import android.widget.TextView;
//import android.view.SurfaceHolder;
//import android.view.SurfaceView;

public class CaptureActivity extends Activity {

	private static final String TAG = "CameraActivity";
	private Context mContext;
	private Camera mCamera;
	private CameraPreview mPreview;
	private Button backButton;
    private Button snapButton;
    private Button analyseButton;
	private DrawImageView mDrawIV;	
	private Bitmap mBitmap;
	private Bitmap greyrectBitmap;
	private boolean onPreview = true;
	
	public static Camera getCameraInstance() {
        Camera c = null;
        try {
		    c = Camera.open();
        } catch (Exception e) {
                Log.d(TAG, "Error setting camera preview: " + e.getMessage());
	    }
	    return c;
    }

	@Override
	protected void onCreate(Bundle savedInstanceState) {
	    	
	    	super.onCreate(savedInstanceState);
	    	requestWindowFeature(Window.FEATURE_NO_TITLE);
	    	setContentView(R.layout.activity_capture);
	             
	        final FrameLayout preview = (FrameLayout)findViewById(R.id.frameLayout1);	    	
	    	preview.post(new Runnable() {
				@Override
				public void run() {
					
					DisplayMetrics dm = new DisplayMetrics(); 					
			        getWindowManager().getDefaultDisplay().getMetrics(dm); 
					LayoutParams lp = preview.getLayoutParams();									
					lp.width = dm.widthPixels; 
					lp.height = (int)(dm.widthPixels * 4 / 3);
			        preview.setLayoutParams(lp);
					mPreview.startPreview();
					
				}
			});
	    	
	    	mContext=getApplicationContext(); 
	    	mDrawIV = (com.example.afb1detection.DrawImageView)findViewById(R.id.drawIV);
	        mDrawIV.draw(new Canvas());
	        
	    	backButton=(Button) findViewById(R.id.backButton);
	        backButton.setOnClickListener(new OnClickListener() {
	        	   @Override
	               public void onClick(View v) {
	                   Intent intent=new Intent(CaptureActivity.this,MainActivity.class); 
	                   startActivity(intent); 	                   
	               }
	        });
	        
	        snapButton = (Button) findViewById(R.id.captureButton);
	        snapButton.setOnClickListener(new OnClickListener() {
	        	@Override
	               public void onClick(View v) {	        		
	        		   if (onPreview) {
	        			     onPreview = false;
	        			     mCamera.takePicture(mShutterCallback, null, mPicture);
	        		   }else {
	        			     onPreview = true;
	        			     mPreview.startPreview();
						     postAutoFocus();
	        		   }	        		
	        	}
	        });
	        
	        analyseButton=(Button)findViewById(R.id.analyseButton);
	        analyseButton.setOnClickListener(new OnClickListener() {
	              public void onClick(View v) {		            	  
	           	      mapp mp= (mapp)getApplication();
                      mp.setBitmap(greyrectBitmap);              	 
	              	  Intent intent=new Intent(CaptureActivity.this,ResultActivity.class);
	              	  startActivity(intent); 	              	  
	              }
	        });
	        
	        mCamera = getCameraInstance();
	        mPreview = new CameraPreview(this, mCamera, previewCb, autoFocusCB);
	        preview.addView(mPreview);
	        ImageView rectangle = ( com.example.afb1detection.DrawImageView)findViewById(R.id.drawIV);
	      //  ImageView rectangle = (ImageView) findViewById(R.id.wgimage);
		    preview.bringChildToFront(rectangle);
	}
	
	private void postAutoFocus() {
			findViewById(R.id.frameLayout1).postDelayed(doAutoFocus,
					10000);
    }
	
	private AutoFocusCallback autoFocusCB = new AutoFocusCallback() {
		@Override
		public void onAutoFocus(boolean success, Camera camera) {			
			//Log.e(TAG,
			//		"onAutoFocus, onPreview = " + Boolean.toString(onPreview));
			postAutoFocus();
		}
	};
	
	private Runnable doAutoFocus = new Runnable() {
        public void run() {       	
             if (onPreview)
                mCamera.autoFocus(autoFocusCB);
        }
    };
    
    PreviewCallback previewCb = new PreviewCallback() {
		public void onPreviewFrame(byte[] data, Camera camera) {					
		}
	};
	
	private ShutterCallback mShutterCallback = new ShutterCallback(){
        public void onShutter() {
             Log.i(TAG, "mShutterCallback:onShutter...");
        }
    };
    
    private PictureCallback mPicture = new PictureCallback() {
    	@Override
        public void onPictureTaken(byte[] data, Camera camera) {
             Log.i(TAG, "mPicture:onPictureTaken...");
             if(null!=data){
                mBitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
               // mCamera.setPreviewCallback(null);
               // mCamera.stopPreview();
             }
             Matrix matrix = new Matrix();
             matrix.postRotate(90);
             Bitmap rotaBitmap = Bitmap.createBitmap(mBitmap, 0, 0, mBitmap.getWidth(), mBitmap.getHeight(), matrix, false);           
            
             Bitmap sizeBitmap = Bitmap.createScaledBitmap(rotaBitmap, 1080, 1440, true);
             
             Bitmap rectBitmap = Bitmap.createBitmap(sizeBitmap, 120, 338, 840, 398);
             
             greyrectBitmap = convertGreyImg(rectBitmap);
             
             if(greyrectBitmap != null){
                saveJpeg(greyrectBitmap);                
             }
             
             mCamera.startPreview();
             onPreview=true;
        }
    };
  
    public Bitmap convertGreyImg(Bitmap img){
        int width = img.getWidth();
        int height = img.getHeight();
        int []pixels = new int[width*height];
        img.getPixels(pixels,0,width,0,0,width,height);
        int alpha = 0xFF<<24;

        for(int i=0; i<height; i++){
          for(int j=0; j<width; j++){
             int grey=pixels[width*i+j];
             int red=((grey & 0x00FF0000) >>16);
             int green=((grey & 0x0000FF00) >>8);
             int blue=(grey & 0x000000FF);
             grey=(int)((float)red*0.3+(float)green*0.59+(float)blue*0.11);
             grey=alpha|(grey<<16)|(grey<<8)|grey;
             pixels[width*i+j]=grey;
           }
         }
        Bitmap result=Bitmap.createBitmap(width,height,Config.RGB_565);
        result.setPixels(pixels,0,width,0,0,width,height);
        return result;
    }
    
    public void saveJpeg(Bitmap bm){
        String savePath ="/sdcard/rectPhoto/";
        File folder = new File(savePath);
        FileOutputStream fout = null;
        if(!folder.exists()){
            folder.mkdirs();
        }
        SimpleDateFormat dateformat=new SimpleDateFormat("yyyyMMddHHmmss");
        String times=dateformat.format(new Date());
        String jpegName = savePath + times +".jpg";
        try {
             fout = new FileOutputStream(jpegName);
             bm.compress(Bitmap.CompressFormat.JPEG, 100, fout);
             //Log.i(TAG, "saveJpeg���洢��ϣ�");
        } catch(FileNotFoundException e){
        	e.printStackTrace();
        }finally{
        	try{
        		fout.flush();
        		fout.close();
        	}catch (IOException e) {        	       
             //Log.i(TAG, "saveJpeg:�洢ʧ�ܣ�");
		      e.printStackTrace();
             }
        }
        Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
        Uri uri = Uri.fromFile(folder);
        intent.setData(uri);
        mContext.sendBroadcast(intent);       
    }
    
    public void onPause() {
		super.onPause();
		releaseCamera();
    }
    
    @Override
	public void onResume() {
		super.onResume();
		if (mCamera == null){  
             mCamera = getCameraInstance();   
	         mPreview = new CameraPreview(this, mCamera, previewCb, autoFocusCB);
	         FrameLayout preview = (FrameLayout)findViewById(R.id.frameLayout1);
             preview.addView(mPreview);
             ImageView rectangle = ( com.example.afb1detection.DrawImageView)findViewById(R.id.drawIV);
		     preview.bringChildToFront(rectangle);
		     mPreview.startPreview();
		     postAutoFocus();
		}
	}
    
    private void releaseCamera() {
        if (mCamera != null) {
		         mCamera.stopPreview();
                 onPreview = false;
                 mPreview.getHolder().removeCallback(mPreview);
		         //mCamera.setPreviewCallback(null);
                 mCamera.release();
                 mCamera = null;
        }
    }   
    
}
