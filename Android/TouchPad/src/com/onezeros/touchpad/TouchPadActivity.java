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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

import android.R.integer;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiManager.MulticastLock;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.util.Printer;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.ArrayAdapter;
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
	public static final int MSG_WIFI_DISCONNECT = 101;
	public static final int MSG_UPDATE_SERVERIP_COUNT = 102;
	
	final int mSocketPort = 20015;
	final int mBroadcastPort = mSocketPort +1;
	final int UPDATE_INTERVAL = 3000;
	
	Map<String,Long> mServerIpList = new HashMap<String, Long>();
	Timer mServerListTimer ;
	
	FrameLayout mProgressFrameLayout;
	RelativeLayout mTouchpadLayout;
    ImageView mMouseLeftImageView;
    ImageView mMouseRightImageView;
    ImageView mMouseMiddleImageView;
    FrameLayout mTouchpaneLayout;
    Button mServerListButton;
            
    Socket mSocket;
    PrintWriter mWriter;
    Thread mUdpThread;
    MessageHandler mMessageHandler = new MessageHandler();
    Context mContext;
    boolean mIsUDPThreadRunning = true;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        mContext = this;

        mProgressFrameLayout = (FrameLayout)findViewById(R.id.connecting_fl);
        mTouchpadLayout = (RelativeLayout)findViewById(R.id.touchpad_layout);
        mMouseLeftImageView = (ImageView)findViewById(R.id.mouse_left);
        mMouseMiddleImageView = (ImageView)findViewById(R.id.mouse_middle_btn);
        mMouseRightImageView = (ImageView)findViewById(R.id.mouse_right);
        mTouchpaneLayout = (FrameLayout)findViewById(R.id.touch_panel);
        mServerListButton = (Button)findViewById(R.id.server_list_button);
        
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

        mServerListButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
		        
		        // server ip list dialog
		        AlertDialog.Builder builderSingle = new AlertDialog.Builder(
		                TouchPadActivity.this);
		        builderSingle.setIcon(R.drawable.ic_launcher);
		        builderSingle.setTitle("Server Detected");
		        final ArrayAdapter<String> arrayAdapter = new ArrayAdapter<String>(
		                TouchPadActivity.this,
		                android.R.layout.select_dialog_singlechoice);
		        
		        for (String ipString : mServerIpList.keySet()) {
					arrayAdapter.add(ipString);
				}
		        builderSingle.setNegativeButton("cancel",
		                new DialogInterface.OnClickListener() {

		                    @Override
		                    public void onClick(DialogInterface dialog, int which) {
		                        dialog.dismiss();
		                    }
		                });

		        builderSingle.setAdapter(arrayAdapter,
		                new DialogInterface.OnClickListener() {

		                    @Override
		                    public void onClick(DialogInterface dialog, int which) {
		                        String ipstring = arrayAdapter.getItem(which);
		                        try {		                        // connect to new pc ip
			                        if (mSocket.isConnected()) {
										mSocket.close();
									}
									connect(ipstring);
								} catch (Exception e) {
									e.printStackTrace();
								}
		                    }
		                });
		        builderSingle.show();				

			}
		});
        
        // broadcast listener
        mUdpThread = new Thread(new Runnable() {
			
			@Override
			public void run() {
				// Create a socket to listen on the port.
				try {
					ConnectivityManager connManager = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
					NetworkInfo wifiInfo = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);

					if (!wifiInfo.isConnected()) {
					    mMessageHandler.sendEmptyMessage(MSG_WIFI_DISCONNECT);
					    return;
					}
					
					WifiManager wifi;
					wifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);
					MulticastLock ml = wifi.createMulticastLock("touchpad broadcast tag");
					ml.acquire();
					
					DatagramSocket dsocket = new DatagramSocket(mBroadcastPort);
					byte[] buffer = new byte[2048];
					
					// Create a packet to receive data into the buffer
					DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
					
					while (mIsUDPThreadRunning) {
						dsocket.receive(packet);
						String msg = new String(buffer, 0, packet.getLength());
						// Reset the length of the packet before reusing it.
						packet.setLength(buffer.length);
						Log.d(TAG, "server ip: "+packet.getAddress().toString());						
						Log.d(TAG, "broadcast received : "+msg);
						
						String serverIpString = packet.getAddress().toString().substring(1);
						Message message = mMessageHandler.obtainMessage(MSG_BROADCAST_RECEIVED, serverIpString);
						mMessageHandler.sendMessage(message);
					}
					
					dsocket.close();
					ml.release();
					
				} catch (SocketException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				
			}
		});
        mUdpThread.start();
        
        // update server ip list by timer
        mServerListTimer= new Timer();
        TimerTask serverListTimerTask = new TimerTask() {
			
			@Override
			public void run() {
				long timestamp = System.currentTimeMillis();
				Set<String> keysSet = mServerIpList.keySet();
				for (String key : keysSet) {
					Long timeInteger = mServerIpList.get(key);
					long interval =timestamp - timeInteger.longValue();
					if( interval >UPDATE_INTERVAL ){
						mServerIpList.remove(key);
					}
				}
				
				Message message = mMessageHandler.obtainMessage(MSG_UPDATE_SERVERIP_COUNT);
				mMessageHandler.sendMessage(message);
			}
		};
		mServerListTimer.schedule(serverListTimerTask, 0, 1000);
    }
    public void connect(String serverip) {
		try {
			
			Log.d(TAG, "stub 1 ");			
			mSocket = new Socket(serverip, mSocketPort);
			Log.d(TAG, "stub 2 ");
			mWriter = new PrintWriter(new BufferedWriter(new OutputStreamWriter(mSocket.getOutputStream())));
			Log.d(TAG, "stub 3 ");
			
			if (mSocket.isConnected()) {						
				mProgressFrameLayout.setVisibility(View.GONE);
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
    	if (mSocket == null || !mSocket.isConnected()) {
			return;
		}
		Log.d(TAG, "sending event:"+message);
    	mWriter.print(message+"\r\n");
    	mWriter.flush();
    }
	@Override
	protected void onResume() {
		super.onResume();
		
		if ( !mUdpThread.isAlive()) {
			mIsUDPThreadRunning = true;
			mUdpThread.start();	
		}
	}

	@Override
	protected void onPause() {
		super.onPause();
		mIsUDPThreadRunning = false;
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
	}
	
	private void updateServerIpCount(){
		int ipCount  = mServerIpList.size();
		mServerListButton.setText(""+ipCount);
	}
	class MessageHandler extends Handler{
		
		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case MSG_BROADCAST_RECEIVED:
				String ip = (String)msg.obj;
				if (ip.startsWith("::")) {
					break;
				}
				// if not connection, connect
				if ( mSocket == null || !mSocket.isConnected()) {
					connect(ip);	
				}
				// add this ip to ip list
				mServerIpList.put(ip, Long.valueOf( System.currentTimeMillis()));
				updateServerIpCount();
				break;
			case MSG_WIFI_DISCONNECT:
				Toast.makeText(mContext, R.string.wifi_error, Toast.LENGTH_LONG).show();
				break;
			case MSG_UPDATE_SERVERIP_COUNT:
				updateServerIpCount();
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