package com.example.afb1detection;

import java.util.List;
import com.example.afb1detection.R;
import android.content.Intent;
import android.os.Bundle;
import android.app.Activity;
import android.view.View;
import android.view.Window;
//import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
//import android.widget.TextView;
//import com.example.afb1detection.HistoryDataSource;

public class HistoryActivity extends Activity {
	
	private static HistoryDataSource datasource;
	public static ArrayAdapter<History> adapter;
	private Button clearHistoryButton;
	private Button backButton;
	@Override
	protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_history);

        clearHistoryButton = (Button)findViewById(R.id.clearHistoryButton);
        clearHistoryButton.setOnClickListener(new OnClickListener() {
	        public void onClick(View v) {
	         // datasource = new HistoryDataSource();
		      datasource.open();
		      datasource.clearHistory();
		      datasource.close();
		      updateAdapter();
	        }
        });

        backButton=(Button)findViewById(R.id.backButton);
        backButton.setOnClickListener(new OnClickListener() {
                 public void onClick(View v) {
                   Intent intent=new Intent(HistoryActivity.this, MainActivity.class); 
                   startActivity(intent); 
                 }
        });

        ListView listView = (ListView)findViewById(R.id.listView1);

        datasource = new HistoryDataSource(this);
        datasource.open();

        List<History> values = datasource.getAllComments();
        datasource.close();

        adapter = new ArrayAdapter<History>(this, R.layout.list_item1, values);
        listView.setAdapter(adapter);
        
    }
	
	public static void updateAdapter() {
		datasource.open();
		List<History> values = datasource.getAllComments();
		datasource.close();
		adapter.clear();
		if (values != null) {
			for (History history : values) {
				adapter.add(history);
			}
		}
		adapter.notifyDataSetChanged();
	}

}
