Invoke-Command -ComputerName 'REMOTECOMPUTER' -ScriptBlock { quser }

Invoke-Command -ComputerName 'REMOTECOMPUTER' -ScriptBlock { logoff 2 }


#one liner to log off all sessions:
invoke-command -computername cedc-nc2413-d1 -scriptblock {quser | Select-Object -Skip 1 | ForEach-Object {$id = ($_ -split ' +')[-6];logoff $id}}