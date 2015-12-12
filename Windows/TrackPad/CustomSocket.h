#pragma once

#include "stdafx.h"

// CCustomSocket

class CCustomSocket : public CAsyncSocket
{
public:
	CCustomSocket();
	virtual ~CCustomSocket();

// Overrides 
public: 
void SetParentDlg(CDialog *pDlg);// ClassWizard generated virtual function overrides 
//{{AFX_VIRTUAL(MyEchoSocket) 
public: 
virtual void OnAccept(int nErrorCode);
virtual void OnClose(int nErrorCode);
virtual void OnConnect(int nErrorCode);
virtual void OnOutOfBandData(int nErrorCode);
virtual void OnReceive(int nErrorCode); 
virtual void OnSend(int nErrorCode); 
//}}AFX_VIRTUAL // Generated message map functions 
//{{AFX_MSG(MyEchoSocket) 
// NOTE - the ClassWizard will add and remove member functions here. //}}AFX_MSG 

protected: 
private:
CDialog * m_pDlg; 
};


