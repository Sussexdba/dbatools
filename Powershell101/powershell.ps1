<#	
	Environment

	Windows Environment
	--------------------------------------
	v2 - Windows 2008/R2 - Windows 7
	v3 - Windows 2012 - Windows 8
	v4 - Windows 2012R2 - Windows 8.1
	v5.1 Windows 2016 - Windows 10

	You should work to get to v5.1 or at least v4
	You will miss out on SqlServer module if you are not on 5.1

	Enable-PSRemoting

	Set-ExecutionPolicy RemoteSigned -Force

	Optional
	--------------------------------------
	v6.x Installable and is installable on Linux

	# Downloadable from Search WINRM Version Download

	Where does everything live?
	Personal Modules # $Home\Documents\WindowsPowerShell\Modules
	Global Modules for PowerShell # $PSHome\Modules
	Global Modules for User/Machine # C:\Program Files\WindowsPowerShell\Modules

	Modules versions will be put in another folder so that you have all the
	versions available.

#>

$PSVersionTable

$Host

<#
	PowerShell Basics

	Intrinsic Variables (Think @@SERVERNAME, etc)
	-----------------------------------------------
	$Profile

	$PSHome

	$Home

	$ErrorActionPreference
		SilentlyContinue
		Stop

	Drives and Environment
	----------------------------------
	$env:PsModulePath

	Env: (drive)

	Variable: (drive)

	# Now let's take a look at profile
	$profile
	c:\Users\ben\Documents\WindowsPowerShell does not exist in the beginning 
	You can create this by using
	md (split-path $profile)
	notepad $profile

	# Switch to profile file

	# Last important thing in this presentation of Basics
	The principal of First In Wins exists in PowerShell
	$var1 = 1 (becomes an Int32)
	$var2 = "string" (becomes a string)
	$var1 = "string" (becomes a string overwrites the Int32)

	$var1 + $var2 

#>
$Profile

$PSHome

$Home

$ErrorActionPreference


$env:PsModulePath

dir Env:

dir Variable:

dir Alias:

dir Function:


$var1 = 1 #(becomes an Int32)
$var2 = "string" #(becomes a string)
$var1 = 'string' #(becomes a string overwrites the Int32)

$var1 = 1
$var2 = "string" #(becomes a string)
$var3 = "2"

$var1 + $var2 #what does this become?
$var2 + $var1 #what does this become?
$var1 + $var3
$var3 + $var1

# Got the hang of this?


<# 
	Syntax
	----------------------------------------------
	SQL : DECLARE @BestId int
	PS  : $BestId = 1

	SQL : exec sp_whoisactive @filter='demodb', @filter_type='database'
	PS  : Invoke-DbaWhoIsactive -filter 'demodb' -filter_type 'database'

	SQL : IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'bob')
			BEGIN
				-- do something
				SELECT 1
			END
		  ELSE IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'bill')
			BEGIN
				SELECT 2
			END
		  ELSE
			BEGIN
				SELECT 3
			END

	PS  : if(Test-Path c:\SQLDATA\files\test.mdf) 
		  {
				# do something
				"1"
		  }
		  elseif(Test-Path c:\SQLDATA\files\new.mdf) 
		  {
				"2"
		  }
		  else 
		  {
				"3"
		  }

	Just remember that { } are the way to represent code blocks.

	# After version 3 Help is not downloaded on install
	# You must update help yourself.
	Get-Help -ShowWindow
			Full
			Detailed
			Examples

	Get-Help about_Comparison_Operators
	
	Save-Help -DestinationPath c:\temp\help

	Update-Help -SourcePath c:\temp\help

	Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=14.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
	
	New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "localhost"
	

#>
Get-Help about_Comparison_Operators -ShowWindow

Get-Service MSSQL* 


<#
	Arrays

#>
$ary = @()
$ary = @('1', '2', '3')
$ary = "1", "2", "3"

$ary2 = [System.Collections.ArrayList]@()
$ary2 = New-Object -TypeName System.Collections.ArrayList

# Slower
Measure-Command -Expression { 1 .. 10000 | ForEach-Object { $ary += $_ } }

# Super Fast
Measure-Command -Expression { 1 .. 10000 | ForEach-Object { $null = $ary2.Add($_) } }


####################################################
# 1 .. X iteration
# I want to do something X number of times.
####################################################
<#
	1..5 produces an array of 1 - 5 one at a time
	Can be used with Foreach()
	Increments by 1 so you can start at any number
	Can be done in reverse order
	5..1 and it will produce 5,4,3,2,1

	Useful and kind of like GO 5 except that it does not always have to go in reverse, and you can use the number in PowerShell

	1..5 | Foreach { $_ }
#>
1 .. 10

1 .. 10 | foreach { $_ }

1 .. 10 | foreach { $_ += $_; $_ }

####################################################
# Splatting (what is this?)
####################################################
<#
	Splatting is all about a Variable satisfying Parameters
	Variables look like this $obj

	Splatting uses @obj 

	Basically a Hash Table with multiple Keys/Values passed into a function/cmdlet

	Rules: You can splat with a variable that has as many or fewer parameter satisfying keys/values.
#>
function get-mytestfunction
{
	param (
		$FirstName,
		$LastName,
		$FavoritePet
	)
	
	Write-Host "$FirstName $LastName $FavoritePet"
	
}
$splat = @{
	FirstName = "Ben"
	LastName  = "Miller"
	
}
$splat2 = @{
	FavoritePet = "Lily"
}

get-mytestfunction @splat

get-mytestfunction @splat @splat2

get-mytestfunction @splat -FavoritePet "Lily"


# Comparisons
"BEN" -eq "ben"
"BEN" -cne "ben"
"BEN" -ceq "ben"
"BEN" -ceq "BEN"


<#
	Modules
	---------------------------------------
	Install-Module dbatools
	Install-Module sqlserver

	Update-Module dbatools

#>


<#
	Let's do some things
#>

Import-Module dbatools

## Get connected to an instance
$server = Connect-DbaInstance -SqlInstance localhost -ClientName "Bob O'bob"

# Show me the databases
$server.Databases

# Find a if a database exists
$nametofind = "demodb"

$server.Databases.Name -contains $nametofind

Get-DbaBackupHistory -SqlInstance localhost -Database demodb

Get-DbaAgentJobHistory -SqlInstance localhost -Job "Waitfor Job" 



<#
	SMO - Shared Management Objects

	These are produced and managed by Microsoft

	Included in both SqlServer and dbatools modules
#>
$smo = "Microsoft.SqlServer.Management.Smo"
$server = New-Object -TypeName "$smo.Server" -Args "localhost"

# By default the StatementTimeout = 600 or 10 minutes
$server.ConnectionContext.StatementTimeout = 0
$server.ConnectionContext.Connect()

$databaseName = "DROPME"
$database = $server.Databases["master"]
$database = $server.Databases[$databaseName]
$database.PageVerify

# Tip, properties are in memory until you Alter() (meaning please send me to SQL)
$database.PageVerify = "CHECKSUM"
$database.Alter()

# Or you can just drop it
$database.Drop()

# Oops there are connections to the database
$server.KillAllProcesses($databaseName)
$database.Drop()

Remove-DbaDatabase -SqlInstance localhost -Database DROPME

