package com.example.afb1detection;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.Button;
//import android.widget.TextView;
//import android.content.Context;

public class MainActivity extends Activity {
	
	private Button takepictureButton;
    private Button historyButton;
    private Button helpButton;
    private Button quitButton;
    
    @Override
	protected void onCreate(Bundle savedInstanceState) {
			
	      super.onCreate(savedInstanceState);
          requestWindowFeature(Window.FEATURE_NO_TITLE);
	      setContentView(R.layout.activity_main);	      

          takepictureButton=(Button)findViewById(R.id.Btntakepicture);
          takepictureButton.setOnClickListener(new OnClickListener() {
                public void onClick(View v) {
                   Intent intent=new Intent(MainActivity.this,CaptureActivity.class);  
                   startActivity(intent); 
                }
          });

          historyButton=(Button)findViewById(R.id.Btnhistory);
          historyButton.setOnClickListener(new OnClickListener() {
                public void onClick(View v) {
                   Intent intent=new Intent(MainActivity.this,HistoryActivity.class);  
                   startActivity(intent); 
                }
          });
            
          helpButton=(Button)findViewById(R.id.Btnhelp);
          helpButton.setOnClickListener(new OnClickListener() {
                public void onClick(View v) {
                   Intent intent=new Intent(MainActivity.this,HelpActivity.class);  
                   startActivity(intent); 
                }
          });
          
          quitButton=(Button)findViewById(R.id.Btnquit);
          quitButton.setOnClickListener(new OnClickListener() {     	  
        	    public void onClick(View v) {        	    	
        	    	finish();
        	    }
          });

    }

}
