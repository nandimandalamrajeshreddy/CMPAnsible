net accounts /MINPWLEN:14
net accounts /uniquepw:24
net accounts /MAXPWAGE:70
net accounts /MINPWAGE:1
wuauclt /detectnow /updatenow
Set-MpPreference -EnableControlledFolderAccess Enabled