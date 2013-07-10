// CustomSocket.cpp : 实现文件
//

#include "stdafx.h"
#include "TrackPad.h"
#include "TrackPadDlg.h"
#include "CustomSocket.h"


// CCustomSocket

CCustomSocket::CCustomSocket()
{
}

CCustomSocket::~CCustomSocket()
{
}


// CCustomSocket 成员函数
void CCustomSocket::SetParentDlg(CDialog *pDlg)
{
m_pDlg=pDlg;
}


void CCustomSocket::OnAccept(int nErrorCode) 
{ 
	if(nErrorCode==0) 
	{ 
	((CTrackPadDlg*)m_pDlg)->OnSocketAccept(this); 
	}
	CAsyncSocket::OnAccept(nErrorCode); 
} 

void CCustomSocket::OnConnect(int nErrorCode) 
{ 
	if(nErrorCode==0) 
	{ 
	((CTrackPadDlg*)m_pDlg)->OnSocketConnect(this); 
	}
	CAsyncSocket::OnConnect(nErrorCode); 
} 

void CCustomSocket::OnReceive(int nErrorCode) 
{ 
	if(nErrorCode==0) 
	{ 
	((CTrackPadDlg*)m_pDlg)->OnSocketReceive(this); 
	}
	CAsyncSocket::OnReceive(nErrorCode); 
} 

void CCustomSocket::OnClose(int nErrorCode)
{

	if(nErrorCode==0) 
	{ 
	((CTrackPadDlg*)m_pDlg)->OnSocketClose(this); 
	}
	CAsyncSocket::OnClose(nErrorCode);
}

void CCustomSocket::OnOutOfBandData(int nErrorCode)
{
	CAsyncSocket::OnOutOfBandData(nErrorCode);
}

void CCustomSocket::OnSend(int nErrorCode)
{
	CAsyncSocket::OnSend(nErrorCode);
}
