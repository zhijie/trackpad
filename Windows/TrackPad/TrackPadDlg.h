// TrackPadDlg.h : header file
//

#pragma once

#include "customsocket.h"
#include "afxwin.h"

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
	DECLARE_MESSAGE_MAP()
public:
	void OnSocketAccept(void);
	void OnSocketConnect(void);
	void OnSocketReceive(void);

private:
	CCustomSocket m_sListener;
	CCustomSocket m_sConnected;
	CAsyncSocket m_broadcaster;
	int m_port;
	int m_broadcastPort;
public:
	afx_msg void OnBnClickedButtonStartserver();
	afx_msg void OnBnClickedButtonStopServer();
	CStatic mInfoLabel;
	CButton mBtnStartServer;
	CButton mBtnStopServer;
	void Tranlator(CString command);
	void OnSocketClose(void);
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg void OnClose();
};
