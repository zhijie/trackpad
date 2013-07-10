// TrackPadDlg.h : header file
//

#pragma once

#include "customsocket.h"
#include "afxwin.h"
#include <list>
using namespace std;

#define WM_SHOWTRAYBAR WM_USER+100
#define WM_CONNECT_SERVER WM_USER+101
#define WM_DISCONNECT_SERVER WM_USER+102


// CTrackPadDlg dialog
class CTrackPadDlg : public CDialog
{
// Construction
public:
	CTrackPadDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_TRACKPAD_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg LRESULT onResponseTraybar(WPARAM wParam,LPARAM lParam);
	afx_msg LRESULT ConnectServer(WPARAM wParam,LPARAM lParam);
	afx_msg LRESULT DisconnectServer(WPARAM wParam,LPARAM lParam);
	afx_msg void OnNcPaint();
	DECLARE_MESSAGE_MAP()
public:
	void OnSocketAccept(CCustomSocket* aocket);
	void OnSocketConnect(CCustomSocket* aSocket);
	void OnSocketReceive(CCustomSocket* aSocket);
	void OnSocketClose(CCustomSocket* aSocket);

	void ClearUpConnections();
private:
	CCustomSocket m_sListener;
	list<CCustomSocket*> m_sConnected;
	CAsyncSocket m_broadcaster;
	int m_port;
	int m_broadcastPort;
	BOOL m_isServerRunning;
	NOTIFYICONDATA m_traybarData;
public:
	afx_msg void OnBnClickedButtonStartserver();
	afx_msg void OnBnClickedButtonStopServer();
//	CStatic mInfoLabel;
// 	CButton mBtnStartServer;
// 	CButton mBtnStopServer;
	void Tranlator(CString command);
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg void OnClose();
	afx_msg void OnDestroy();
	afx_msg void OnSize(UINT nType, int cx, int cy);
};
