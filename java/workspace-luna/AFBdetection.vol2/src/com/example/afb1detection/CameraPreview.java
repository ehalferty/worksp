package com.example.afb1detection;

import java.util.List;
import android.content.Context;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.PreviewCallback;
import android.util.Log;
import android.view.SurfaceView;
import android.view.SurfaceHolder;
//import android.graphics.PixelFormat;

public class CameraPreview extends SurfaceView implements
    SurfaceHolder.Callback {

	private static final String TAG = "CameraPreview"; 
    private Context mContext;
    private List<Camera.Size> mSizes;//支持的尺寸列表
    public Camera.Size mPreviewSize;//实际预览尺寸
    private SurfaceHolder mHolder;//监听
    private Camera mCamera;
    private PreviewCallback previewCallback;
    private AutoFocusCallback autoFocusCallback;
    private boolean onPreview = true;
    public CameraPreview(Context context, Camera camera,PreviewCallback previewCb, AutoFocusCallback autoFocusCb) 
    {
         super(context);
         mContext = context;
         previewCallback = previewCb;
 		 autoFocusCallback = autoFocusCb;
		 mCamera = camera;
         mHolder = getHolder();
         //mHolder.setFormat(PixelFormat.TRANSPARENT);
         mHolder.addCallback(this);
         mHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
    }   
    public void startPreview() {
		if (!onPreview && (mCamera != null)) {
			// set preview size and make any resize, rotate or
			// reformatting changes here

			// start preview with new settings
			try {
				// set preview size				 				 				
				// Set Camera parameters
				Camera.Parameters params = mCamera.getParameters();

				// supported preview sizes
				mSizes = mCamera.getParameters()
						.getSupportedPreviewSizes();
				
				 try  
			        {  
			          if(mSizes!=null)  
			          {  
			            for(int i=0;i<mSizes.size();i++)  
			            {  
			              Log.i(TAG,""+(((Camera.Size)mSizes.get(i)).height)+"/"+(((Camera.Size)mSizes.get(i)).width));  
			            }  
			          }  

				params.setPreviewSize(640, 480);
				
				mSizes = params.getSupportedPictureSizes(); 
				try  
		          {  
		            if(mSizes!=null)  
		            {  
		              for(int i=0;i<mSizes.size();i++)  
		              {  
		                Log.i(TAG,""+(((Camera.Size)mSizes.get(i)).height)+"/"+(((Camera.Size)mSizes.get(i)).width));  
		              }  
		            }  
				
				params.setPictureSize(640, 480);
				
				params.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);
				mCamera.setParameters(params);
		        
				// Hard code camera surface rotation 90 degs to match Activity view in portrait
				mCamera.setDisplayOrientation(90);

				mCamera.setPreviewDisplay(mHolder);
				mCamera.startPreview();
				onPreview = true;
			    }catch (Exception e)  
			          {  
			            Log.i(TAG, e.toString());  
			            e.printStackTrace();  
			          }  
			    }catch (Exception e)  
		        {    
			          e.printStackTrace();  
			        } 
			} catch (Exception e) {
				Log.d(TAG, "Error starting camera preview: " + e.getMessage());
			}
		}
	}

	public void stopPreview() {
		try {
			if (onPreview && (mCamera != null)) {
				mCamera.setPreviewCallback(null);
				mCamera.stopPreview();
				onPreview = false;
			}
		} catch (Exception e) {
			Log.d(TAG, "Error stopping camera preview: " + e.getMessage());
		}
	}
    public void surfaceCreated(SurfaceHolder holder) {
    	startPreview();
    }
    public void surfaceDestroyed(SurfaceHolder holder) {

	}
    public void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
        if (mHolder.getSurface() == null) {
                 return;
        }
        try {
	       stopPreview();
        } catch (Exception e) {
          }
        try {
             mCamera.setDisplayOrientation(90);
             mCamera.setPreviewDisplay(mHolder);
             mCamera.setPreviewCallback(previewCallback);
             startPreview();
             mCamera.autoFocus(autoFocusCallback);
         } catch (Exception e) {
	            Log.d(TAG, "Error starting camera preview: " + e.getMessage());
          }
    } 
}
