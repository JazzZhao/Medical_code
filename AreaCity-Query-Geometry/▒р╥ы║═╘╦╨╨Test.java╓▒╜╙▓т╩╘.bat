@echo off
::��Windowsϵͳ��˫����������ļ����Զ����java�ļ����������

:Run
cls

::�޸�����ָ����Ҫʹ�õ�JDK��\��βbinĿ¼����·����������ʹ���Ѱ�װ��Ĭ��JDK
set jdkBinDir=
::set jdkBinDir=D:\xxxx\jdk-18_windows-x64_bin\jdk-18.0.2.1\bin\

if "%jdkBinDir%"=="" (
	echo ���ڶ�ȡJDK�汾������ָ��JDKΪ�ض��汾��Ŀ¼�����޸ı�bat�ļ���jdkBinDirΪJDK binĿ¼����
) else (
	echo ���ڶ�ȡJDK��%jdkBinDir%���汾��
)


%jdkBinDir%javac -version
if errorlevel 1 (
	echo ��Ҫ��װJDK���ܱ�������java�ļ�
	goto Pause
)

%jdkBinDir%javac -encoding utf-8 -cp "./*" *.java
if errorlevel 1 (
	echo java�ļ�����ʧ��
	goto Pause
)

set dir=com\github\xiangyuecn\areacity\query
if not exist %dir% (
	md %dir%
) else (
	del %dir%\*.class > nul
)
move *.class %dir% > nul

echo java -Xmx300m Test -cmd ������java�������ʹ��300M�ڴ�
%jdkBinDir%java -cp "./;./*" -Xmx300m com.github.xiangyuecn.areacity.query.Test -cmd

:Pause
pause
:End