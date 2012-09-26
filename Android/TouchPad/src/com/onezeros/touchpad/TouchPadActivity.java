package com.onezeros.touchpad;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.Socket;
import java.net.SocketException;
import java.net.UnknownHostException;

import android.R.integer;
import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.util.Printer;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;

public class TouchPadActivity extends Activity {
	private static final String TAG = "lzhj"; 

	public static final int MSG_BROADCAST_RECEIVED = 100;
	final int mSocketPort = 20000;
	final int mBroadcastPort = mSocketPort +1;
	
	RelativeLayout mTouchpadLayout;
    ImageView mMouseLeftImageView;
    ImageView mMouseRightImageView;
    ImageView mMouseMiddleImageView;
    FrameLayout mTouchpaneLayout;
    
    
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
        
        mTouchpadLayout = (RelativeLayout)findViewById(R.id.touchpad_layout);
        mMouseLeftImageView = (ImageView)findViewById(R.id.mouse_left);
        mMouseMiddleImageView = (ImageView)findViewById(R.id.mouse_middle_btn);
        mMouseRightImageView = (ImageView)findViewById(R.id.mouse_right);
        mTouchpaneLayout = (FrameLayout)findViewById(R.id.touch_panel);
        
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
        
        mMouseLeftImageView.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				String action = null ;
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
					action = "MOUSEEVENTF_LEFTDOWN";
					break;
				case MotionEvent.ACTION_UP:
					action = "MOUSEEVENTF_LEFTUP";
					break;
				default:
					break;
				}
				if (action != null) {
					sendSocketMessage(action);
				}
				return true;
			}
		});
        mMouseRightImageView.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				String action = null ;
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
					action = "MOUSEEVENTF_RIGHTDOWN";
					break;
				case MotionEvent.ACTION_UP:
					action = "MOUSEEVENTF_RIGHTUP";
					break;
				default:
					break;
				}
				if (action != null) {
					sendSocketMessage(action);
				}
				return true;
			}
		});
        mMouseMiddleImageView.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				String action = null ;
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
					action = "MOUSEEVENTF_MIDDLEDOWN";
					break;
				case MotionEvent.ACTION_MOVE:
					break;
				case MotionEvent.ACTION_UP:
					action = "MOUSEEVENTF_MIDDLEUP";
					break;
				default:
					break;
				}
				if (action != null) {
					sendSocketMessage(action);
				}
				return true;
			}
		});
        
        mTouchpaneLayout.setOnTouchListener(new OnTouchListener() {
			float lastX;
			float lastY;
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				String actionString = null;
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
					//actionString = String.format("DOWN:(%f,%f)", event.getX(),event.getY());
					lastX = event.getX();
					lastY = event.getY();
					break;
				case MotionEvent.ACTION_MOVE:
					actionString = String.format("MOUSEEVENTF_MOVE %f %f", event.getX() - lastX,event.getY() - lastY);
					lastX = event.getX();
					lastY = event.getY();
							
					break;
				case MotionEvent.ACTION_UP:
					//actionString = String.format("UP:(%f,%f)", event.getX(),event.getY());
					break;

				default:
					break;
				}
				if (actionString!= null) {
					sendSocketMessage(actionString);
				}
				return true;
			}
		});
        
        // broadcast listener
        new Thread(new Runnable() {
			
			@Override
			public void run() {
				// Create a socket to listen on the port.
				try {
					DatagramSocket dsocket;
					dsocket = new DatagramSocket(mBroadcastPort);
					dsocket.setBroadcast(true);
					// Create a buffer to read datagrams into. If a
					// packet is larger than this buffer, the
					// excess will simply be discarded!
					byte[] buffer = new byte[2048];
					
					// Create a packet to receive data into the buffer
					DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
					
					// Now loop forever, waiting to receive packets and printing them.
					while (true) {
						Log.d(TAG, "ready to receive broadcast...");
						// Wait to receive a datagram
						dsocket.receive(packet);
						// Convert the contents to a string, and display them
						String msg = new String(buffer, 0, packet.getLength());
						// Reset the length of the packet before reusing it.
						packet.setLength(buffer.length);
						
						Log.d(TAG, "broadcast received : "+msg);
					}
				} catch (SocketException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				
			}
		}).start();
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
    
    public void sendSocketMessage(String message) {
    	if (!mSocket.isConnected()) {
			Toast.makeText(this, "connetion lost",Toast.LENGTH_SHORT).show();
			mTouchpadLayout.setVisibility(View.GONE);
			
			mWriter.close();
			try {
				mSocket.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
			return;
		}
    	mWriter.println(message);
    	mWriter.flush();
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
			return;
		}
		super.onBackPressed();
	}
	
	class MessageHandler extends Handler{
		
		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case MSG_BROADCAST_RECEIVED:
				
				break;
				
			default:
				break;
			}
		}
		
	}
}
/*
Command :
MOUSEEVENTF_MOVE x y
MOUSEEVENTF_LEFTDOWN
MOUSEEVENTF_LEFTUP
MOUSEEVENTF_RIGHTDOWN
MOUSEEVENTF_RIGHTUP
MOUSEEVENTF_MIDDLEDOWN
MOUSEEVENTF_MIDDLEUP
MOUSEEVENTF_WHEEL WHEEL_DELTA

reference :
http://msdn.microsoft.com/en-us/library/windows/desktop/ms646273(v=vs.85).aspx
*/