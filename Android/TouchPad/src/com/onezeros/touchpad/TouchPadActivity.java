package com.onezeros.touchpad;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.util.Printer;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

public class TouchPadActivity extends Activity {
	private static final String TAG = "lzhj"; 
    FrameLayout mTouchpadLayout;
    
    LinearLayout mSetupLayout;
    EditText mServerIPEditText;
    EditText mServerPortText;
    Button mConnectButton;
    
    Socket mSocket;
    PrintWriter mWriter;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        mTouchpadLayout = (FrameLayout)findViewById(R.id.touchpad_layout);
        mSetupLayout = (LinearLayout)findViewById(R.id.setup_ll);
        mServerIPEditText = (EditText)findViewById(R.id.serverip_et);
        mServerPortText = (EditText)findViewById(R.id.port_et);
        mConnectButton = (Button)findViewById(R.id.connect_bt);
        
        mConnectButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				try {
					Log.d(TAG, "stub 1 ");
					mSocket = new Socket(mServerIPEditText.getText().toString(), Integer.parseInt(mServerPortText.getText().toString()));
					Log.d(TAG, "stub 2 ");
					mWriter = new PrintWriter(new BufferedWriter(new OutputStreamWriter(mSocket.getOutputStream())));
					Log.d(TAG, "stub 3 ");
					
					if (mSocket.isConnected()) {						
						mTouchpadLayout.setVisibility(View.VISIBLE);
					}
					Log.d(TAG,"mSocket.isConnected() = "+mSocket.isConnected());
					
				} catch (NumberFormatException e) {
					e.printStackTrace();
				} catch (UnknownHostException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}
				
				
			}
		});
        
        mTouchpadLayout.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				String actionString = null;
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
					actionString = String.format("DOWN:(%f,%f)", event.getX(),event.getY());
					break;
				case MotionEvent.ACTION_MOVE:
					actionString = String.format("MOVE:(%f,%f)", event.getX(),event.getY());
					break;
				case MotionEvent.ACTION_UP:
					actionString = String.format("UP:(%f,%f)", event.getX(),event.getY());
					break;

				default:
					break;
				}
				if (actionString!= null) {
					mWriter.println(actionString);
					mWriter.flush();
				}
				return false;
			}
		});
    }
    
    public void stopConnection() {
    	if(mSocket.isConnected()){
    		try {
    			mWriter.close();
				mSocket.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
    		
    	}
    }

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
	}

	@Override
	public void onBackPressed() {
		if (mTouchpadLayout.getVisibility() == View.VISIBLE) {
			stopConnection();
			mTouchpadLayout.setVisibility(View.GONE);
		}
		super.onBackPressed();
	}
}