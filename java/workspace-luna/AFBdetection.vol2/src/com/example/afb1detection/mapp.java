package com.example.afb1detection;

import  android.app.Application;
import  android.graphics.Bitmap;

public class mapp extends  Application{
	
	 private  Bitmap mBitmap;
	 
	 public  Bitmap getBitmap()
	    {
	         return  mBitmap;
	    }

	 public  void  setBitmap(Bitmap bitmap)
	    {
	         this .mBitmap  =  bitmap;
	    }

}
