// dll.cpp : ���� DLL Ӧ�ó���ĵ���������
//

#include "stdafx.h"
#include "dll.h"


// ���ǵ���������һ��ʾ��
DLL_API int ndll=0;

// ���ǵ���������һ��ʾ����
DLL_API int fndll(void)
{
	return 42;
}

// �����ѵ�����Ĺ��캯����
// �й��ඨ�����Ϣ������� dll.h
Cdll::Cdll()
{
	return;
}
