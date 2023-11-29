.EXAMPLE
        Get updates histry list for sets of remote computers.
         
        PS C:\> "G1","G2" | Get-WUHistory
		
		 .EXAMPLE
        Get information about specific installed updates.
     
        PS C:\> $WUHistory = Get-WUHistory
        PS C:\> $WUHistory | Where-Object {$_.Title -match "KB2607047"} | Select-Object *