@echo off
cd /d "D:\Is This Anything\TheKlif.github.io"

powershell.exe -ExecutionPolicy Bypass -File "publish.ps1" > "%~dp0publish.log" 2>&1

if %errorlevel%==0 (
    powershell -Command "$xml='<toast><visual><binding template=\"ToastGeneric\"><text>Publish complete</text></binding></visual></toast>'; $doc=New-Object Windows.Data.Xml.Dom.XmlDocument; $doc.LoadXml($xml); $toast=[Windows.UI.Notifications.ToastNotification]::new($doc); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Is This Anything').Show($toast)"
) else (
    powershell -Command "$xml='<toast><visual><binding template=\"ToastGeneric\"><text>Publish failed</text></binding></visual></toast>'; $doc=New-Object Windows.Data.Xml.Dom.XmlDocument; $doc.LoadXml($xml); $toast=[Windows.UI.Notifications.ToastNotification]::new($doc); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Is This Anything').Show($toast)"
)