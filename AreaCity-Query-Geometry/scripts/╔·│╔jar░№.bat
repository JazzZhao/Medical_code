@echo off
::��Windowsϵͳ��˫����������ļ����Զ����java�ļ�����ʹ����jar

for %%i in (%cd%) do set dir=%%~ni
if not "%dir%"=="scripts" (
	echo �뵽scriptsĿ¼�����б��ű���
	goto Pause
)

:Run
cls
cd ../
setlocal enabledelayedexpansion

::�޸�����ָ����Ҫʹ�õ�JDK��\��βbinĿ¼����·����������ʹ���Ѱ�װ��Ĭ��JDK
set jdkBinDir=
::set jdkBinDir="C:\Program Files\Java\jdk-1.8\bin\"

if "%jdkBinDir%"=="" (
	echo ���ڶ�ȡJDK�汾������ָ��JDKΪ�ض��汾��Ŀ¼�����޸ı�bat�ļ���jdkBinDirΪJDK binĿ¼����
) else (
	echo ���ڶ�ȡJDK��%jdkBinDir%���汾��
)


%jdkBinDir%javac -version
if errorlevel 1 (
	echo ��Ҫ��װJDK���ܱ���java�ļ�
	goto Pause
)

:JarN
	echo.
	echo ��ѡ����Ҫ�����ɲ�����
	echo   1. ����������jar�ļ����ŵ�������Ŀ��Java������ã�����Test.java��
	echo   2. ���ɿ�����jar�ļ�������Test.java����̨����
	echo   3. �˳�
	set step=
	set /p step=���������:
	echo.
	if "%step%"=="1" goto Jar1
	if "%step%"=="2" goto Jar2
	if "%step%"=="3" goto Pause
	echo �����Ч������������
	goto JarN

:Clazz
	echo ������...
	%jdkBinDir%javac -encoding utf-8 -cp "./*" %Clazz_Files%
	if errorlevel 1 (
		echo java�ļ�����ʧ��
		goto JarN
	)

	set dir=target\classes\com\github\xiangyuecn\areacity\query
	if exist target\classes rd /S /Q target\classes > nul
	md %dir%
	move *.class %dir% > nul

	echo ������ɣ���������jar...
	goto %Clazz_End%

:Jar1
	set Clazz_Files=AreaCityQuery.java
	set Clazz_End=Jar1_1
	goto Clazz
	:Jar1_1
	
	set dir=target\jarLib\
	if not exist %dir% md %dir%
	set jarPath=%dir%areacity-query-geometry.lib.jar
	
	%jdkBinDir%jar cf %jarPath% -C target/classes/ com
	if errorlevel 1 (
		echo ����jarʧ��
	) else (
		copy jts-core-*.jar %dir% > nul
		echo ������jar���ļ���Դ���Ŀ¼��%jarPath%����copy���jar + jts-core-xxx.jar �������Ŀ��ʹ�á�
	)
	echo.
	pause
	goto JarN

:Jar2
	set Clazz_Files=*.java
	set Clazz_End=Jar2_1
	goto Clazz
	:Jar2_1
	
	set dir=target\jarConsole\
	set dir_libs=%dir%libs\
	if not exist %dir% md %dir%
	if not exist %dir_libs% md %dir_libs%
	set jarPath=%dir%areacity-query-geometry.console.jar
	
	copy *.jar %dir_libs% > nul
	set jarArr=
	for /f %%a in ('dir /b "%dir_libs%"') do (set jarArr=!jarArr! libs/%%a)
	echo Class-Path:%jarArr%
	
	set MANIFEST=target\classes\MANIFEST.MF
	echo Manifest-Version: 1.0>%MANIFEST%
	echo Class-Path:%jarArr%>>%MANIFEST%
	echo Main-Class: com.github.xiangyuecn.areacity.query.Test>>%MANIFEST%
	
	%jdkBinDir%jar cfm %jarPath% target/classes/MANIFEST.MF -C target/classes/ com
	if errorlevel 1 (
		echo ������jarʧ��
	) else (
		echo ������jar���ļ���Դ���Ŀ¼��%jarPath%��libs���Ѱ�������������jar�ļ���ʹ��ʱ��ȫ�����ơ�
		echo �뵽����ļ��������ִ�������������jar��
		echo       java -jar areacity-query-geometry.console.jar
	)
	echo.
	pause
	goto JarN

:Pause
pause
:End