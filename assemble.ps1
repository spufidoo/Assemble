Import-Module './helper-functions' 
Write-Host "Avengers Assemble!"

# Loading params from json file
$params = Get-Content '.\params.json' | ConvertFrom-JSON

$remoteFilePath = Get-Remote_FilePath -localFilePath $args[0]
$member = [io.path]::GetFileNameWithoutExtension($remoteFilePath).ToUpper()
Write-Host "Member $($member)"

# This JCL can be parametrized more, if needed
$JCL="//$($params.assemble.jobCard.jobname)   JOB $($params.assemble.jobCard.account),$($params.assemble.jobCard.username),
//    NOTIFY=$($params.assemble.jobCard.notify),
//    MSGLEVEL=$($params.assemble.jobCard.msglevel),
//    CLASS=$($params.assemble.jobCard.class),
//    MSGCLASS=$($params.assemble.jobCard.msgclass),
//    REGION=$($params.assemble.jobCard.region),
//    USER=$($params.assemble.jobCard.username)
//    SET MEMBER=$($member)
//ASM     EXEC PGM=ASMA90,PARM='OBJECT,NODECK'          
//SYSIN    DD  DISP=SHR,DSN=$($params.assemble.inputPDS)(&MEMBER)  
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR                 
//         DD  DSN=CSGI.DB2V12M.DSNMACS,DISP=SHR    
//SYSLIN   DD  DSN=&&LOADSET,DISP=(MOD,PASS),UNIT=SYSDA,
//             SPACE=(TRK,(15,15)),DCB=(BLKSIZE=800)    
//SYSPRINT DD  SYSOUT=*                                 
//SYSUDUMP DD  SYSOUT=*                                 
//SYSUT1   DD  SPACE=(TRK,(45,15),,,ROUND),UNIT=SYSDA   
//*                                                     
//LKED    EXEC PGM=IEWL,COND=(4,LT,ASM),                
//         PARM='LET,MAP,SIZE=(996K,96K),LIST,XREF'     
//SYSLIB   DD  DUMMY                                    
//SYSLIN   DD  DSN=&&LOADSET,DISP=(OLD,DELETE)          
//SYSLMOD  DD  DSN=$($params.assemble.loadPDS)(&MEMBER),DISP=SHR 
//SYSPRINT DD  SYSOUT=*                                 
//SYSUDUMP DD  SYSOUT=*                                 
//SYSUT1   DD  SPACE=(1024,(50,50)),UNIT=SYSDA          
"
# Write the temp JCL file
Set-Content -Path $params.assemble.outputJcl -Value $JCL

# check if profile is passed from task, if not, take it from params
if  ($args[1]) {
    $profile = $args[1]
} else {
    $profile = $params.assemble.defaultProfile
}

# Zowe CLI command to FTP the local file to the mainframe
$ftpout = zowe zos-files upload file-to-data-set $remoteFilePath "mvsmjd.marcus.asm($($member))"
Write-Host $ftpout

# Zowe CLI command to submit a local file and get back the spool files
$output = zowe jobs submit local-file $params.assemble.outputJcl --directory . --rfj --zosmf-p $profile | ConvertFrom-JSON

$jobid = $output.data.jobid
Write-Host "Submitted $($jobid)"
$keepSpool = [System.Convert]::ToBoolean($params.assemble.keepSpool)

# Basic error handling
if ($output.data.retcode -eq "CC 0000") {
    Write-Host "JOB $($output.data.jobid) COMPLETED SUCCESSFULLY." 
    Write-Host "OUTPUT: $jobid$($params.assemble.defaultStdout)"
    #Get-Content -Path ".\$jobid$($params.assemble.defaultStdout)"
    Remove-Files -jobid $jobid -keepSpool $keepSpool -outputJcl $params.assemble.outputJcl
} else {
    Write-Host "JOB $($output.data.jobid) finished in error." 
    Write-Host "Return Code: $($output.data.retcode)"
    Remove-Files -jobid $jobid -keepSpool $keepSpool -outputJcl $params.assemble.outputJcl
}
