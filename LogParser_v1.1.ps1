#This script parses through CHIA logs
#You will need to share out the log direction on each computer.



#Sleep timer function
function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}

#Array of Computers to test logs on
#Enter each harvester/farmer/fullnode here, DNS must be working in your environment.
$ComputerArray=@()
$ComputerArray+="Putar"
#$ComputerArray+="Farmer1"
$ComputerArray+="Harvester1"
$ComputerArray+="Harvester2"

#clear logs for fresh start

#prompts users to enter IP
write-host "press y to delete logs, any key to continue" -foregroundcolor green
$dellogs=read-host


if ($dellogs -eq "y")
	{
	foreach ($computer in $ComputerArray)
		{
		write-host "trying to delete logs from "$computer
		try {del \\$computer\log\debug.log}
		catch{$error[0].exception.message.tostring() + $error[0].invocationinfo.positionmessage}
		finally{}
		}
	}



#Sleep Duration between tests
$SleepDuration=10

Function TestLogs{
$PingTest=$null
	$PingTest=test-netconnection $Computer
	if ($PingTest.pingsucceeded -ne "TRUE")
		{
		write-host $Computer" is not responding to pings!" -backgroundcolor black -foregroundcolor red
		$msgBoxInput=[System.Windows.Forms.MessageBox]::Show('Server Disconnect','YesNoCancel')
		}
	else
		{
		$ComputerLog=get-content \\$Computer\log\debug.log | where-object {`
		($_ -like "*warning*") -or ($_ -like "*error*")`
		-and (($_ -notlike "*WARNING  Directory:*")`
		-and ($_ -notlike "*WARNING  add_spendbundle*")`
		-and ($_ -notlike "*took 1*")`
		-and ($_ -notlike "*took 2*")`
		-and ($_ -notlike "*Block validation time: 1*")`
		-and ($_ -notlike "*Block validation time: 2*")`
		-and ($_ -notlike "*Block validation time: 3*")`
		-and ($_ -notlike "*Block validation time: 4*")`
		-and ($_ -notlike "*Looking up qualities on*")`
		)}
		$LookupQualityLog=get-content \\$Computer\log\debug.log | where-object {`
		($_ -like "*Looking up qualities on*")`
		}
		if ($ComputerLog -ne $Null)
			{
			write-host "Found erors on "$Computer -backgroundcolor black -foregroundcolor red
			write-host $ComputerLog
			#$msgBoxInput=[System.Windows.Forms.MessageBox]::Show('Chia Errors Found on farmer1','YesNoCancel')
			#start notepad++ \\farmer1\log\debug.log
			}
		else
			{
			write-host "No unusual errors on "$Computer -foregroundcolor black -backgroundcolor green
			}
		if ($LookupQualityLog -ne $null)
			{
			write-host "there are "$LookupQualityLog.count" slow plot reads on "$computer -backgroundcolor black -foregroundcolor red
			}

		}
	
	start-sleep $SleepDuration
	
}


#Infinite Loop
for()
{
foreach ($computer in $ComputerArray)
	{
	TestLogs
	}
}