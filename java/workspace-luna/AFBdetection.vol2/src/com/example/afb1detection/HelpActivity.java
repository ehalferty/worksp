package com.example.afb1detection;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
//import android.content.Context;

public class HelpActivity extends Activity {
	
	private Button backButton;
	public TextView helpText;
	public ImageView iconimage;
	@Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_help);

        backButton=(Button)findViewById(R.id.backButton);
        backButton.setOnClickListener(new OnClickListener() {
               public void onClick(View v) {
                    Intent intent=new Intent(HelpActivity.this,MainActivity.class);  
                    startActivity(intent); 
               }
        });
        
        iconimage = (ImageView)findViewById(R.id.iconimage);
        helpText = (TextView)findViewById(R.id.helpText);
        
    }
}
