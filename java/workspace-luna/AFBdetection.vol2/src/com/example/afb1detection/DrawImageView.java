package com.example.afb1detection;

import android.content.Context;  
import android.graphics.Canvas;  
import android.graphics.Color;  
import android.graphics.Paint;  
import android.graphics.Paint.Style;  
import android.graphics.Rect;  
import android.util.AttributeSet;  
import android.widget.ImageView; 

public class DrawImageView extends ImageView {
	
	public DrawImageView(Context context, AttributeSet attrs) {  
        super(context, attrs);          
    }
	
    Paint paint1 = new Paint();  
    {  
        paint1.setAntiAlias(true);  
        paint1.setColor(Color.RED);  
        paint1.setStyle(Style.STROKE);  
        paint1.setStrokeWidth(1.5f);
        paint1.setAlpha(100);  
    };
    Paint paint2 = new Paint();  
    {  
        paint2.setAntiAlias(true);  
        paint2.setColor(Color.BLUE);  
        paint2.setStyle(Style.STROKE);  
        paint2.setStrokeWidth(1.5f);
        paint2.setAlpha(100);  
    };
    @Override
    protected void onDraw(Canvas canvas) {  
     
        super.onDraw(canvas);  
        canvas.drawRect(new Rect(120, 338, 960, 728), paint1);
        canvas.drawLine(170,338,170,728,paint1);
        canvas.drawLine(182,338,182,728,paint1);
        canvas.drawLine(241,338,241,728,paint1);
        canvas.drawLine(253,338,253,728,paint1);

        canvas.drawLine(270,338,270,728,paint2);//����
        canvas.drawLine(285,338,285,728,paint2);

        canvas.drawLine(307,338,307,728,paint1);
        canvas.drawLine(319,338,319,728,paint1);
        canvas.drawLine(371,338,371,728,paint1);
        canvas.drawLine(383,338,383,728,paint1);
        canvas.drawLine(438,338,438,728,paint1);
        canvas.drawLine(450,338,450,728,paint1);
        canvas.drawLine(498,338,498,728,paint1);
        canvas.drawLine(510,338,510,728,paint1);

        canvas.drawLine(525,338,525,728,paint2);//����
        canvas.drawLine(550,338,550,728,paint2);

        canvas.drawLine(566,338,566,728,paint1);
        canvas.drawLine(578,338,578,728,paint1);
        canvas.drawLine(632,338,632,728,paint1);
        canvas.drawLine(644,338,644,728,paint1);
        canvas.drawLine(697,338,697,728,paint1);
        canvas.drawLine(709,338,709,728,paint1);
        canvas.drawLine(763,338,763,728,paint1);
        canvas.drawLine(775,338,775,728,paint1);

        canvas.drawLine(790,338,790,728,paint2);//����
        canvas.drawLine(805,338,805,728,paint2);

        canvas.drawLine(828,338,828,728,paint1);
        canvas.drawLine(840,338,840,728,paint1);
          
    }  

}
