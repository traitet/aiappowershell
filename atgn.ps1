# =======================================================================
#  VEWRSION#1 BY NATTAWUT
#  20/01/2022 17.43 
#  12:25 PM 27/01/2022
#  set PATH=%PATH%;C:\Program Files (x86)\Nmap\
# =======================================================================

# =======================================================================
# DECLARE VARIABLE
# =======================================================================
$atgnPath = "D:\atgn\" 
$tmpFileName = "tmp.txt"
$tempPath = $atgnPath + $tmpFileName
$file_data_input = $atgnPath + "atgninput.txt"
$file_data_output = $atgnPath = "atgnLog.txt"
$lineToken ="Bearer VLgdlXvdKhsLoHFODkPKnlUISC6X3WMUh1eqfzGEbEP"


# =======================================================================
# FUNCTION#1: GET LOG NMAP
# =======================================================================
Function getLogNmap{
    Param ($port, $IP , $desc , $findText)
    $time =Get-date -Format "dd-MM-yyyy HH:mm:ss"   
    nmap -p $port -traceroute $IP >> $tempPath
    $resultNmap = Get-Content -Path $tempPath
# =======================================================================
# FIND TEXT
# ======================================================================= 
    $resultSearch = Select-String -Path $tempPath -Pattern $findText
# =======================================================================
# IF FOUND
# ======================================================================= 
    if ($null -ne $resultSearch){
# =======================================================================
# ADD CONTENT TO FILE
# =======================================================================  
        $content= "ATGN Success : " + $time +" " + $content + $desc #+'Check ' +$type +' at ' + $plant +' Script >> nmap -p '+$port+' -traceroute '+$IP
        Add-Content -Value $content -Path $file_data_output
# =======================================================================
# IF NOT FOUND
# ======================================================================= 
    }
    else {
        $header ='================================= ERROR Result ====================================================='        
        $content= "ATGN Error : " + $time +" " + $content + $desc #+'Check ' +$type +' at ' + $plant +' Script >> nmap -p '+$port+' -traceroute '+$IP    
# =======================================================================
# ADD CONTENT TO FILE
# =======================================================================           
        Add-Content -Value "" -Path $file_data_output
        Add-Content -Value $content -Path $file_data_output
        Add-Content -Value $header -Path $file_data_output
        Add-Content -Value $resultNmap -Path $file_data_output
# =======================================================================
# CREATE EVENT LOG
# ======================================================================= 
        $errorLog = $content +"`r`n'" + $resultNmap
        eventcreate /Id 500 /D $errorLog /T ERROR /L application
# =======================================================================
# SEND LINE
# =======================================================================  
        sendLineNotify $errorLog    
    }
#$tempPath
Remove-Item $tempPath
Return $content
}


# =======================================================================
# FUNCTION#2: SEND LINE
# =======================================================================
Function sendLineNotify{
    Param( $messageSendLine)
    "Send line-----------------------------"
    $messageSendLine
    'this message for send line' + $messageSendLine
# =======================================================================
# SEND LINE
# =======================================================================   
    try{
        # curl -Uri 'https://notify-api.line.me/api/notify' -Method Post -Headers @{Authorization = $lineToken } -Body @{message = $messageSendLine}
        Invoke-WebRequest -Uri 'https://notify-api.line.me/api/notify' -Method Post -Headers @{Authorization = $lineToken } -Body @{message = $messageSendLine}
    } 
    # ====================================================================
    # SEND LINE ERROR
    # ====================================================================   
    catch   {
        $e = $_.Exception
        $msg = $e.Message
        while ($e.InnerException) {
            $e = $e.InnerException
            $msg += "`n" + $e.Message
        }
# =======================================================================
# ADD CONTENT TO FILE
# ======================================================================= 
        $header ='LINE ERROR ============================================'                
        Add-Content -Value $header -Path $file_data_output
        Add-Content -Value $msg -Path $file_data_output
    }
}


# =======================================================================
# MAIN
# ======================================================================= 

    foreach($line in Get-Content $file_data_input) {
        $CharArray = $line.Split(";")
        $ip = $CharArray[0].Split("=")[1]
        $port = $CharArray[1].Split("=")[1]
        $search = $CharArray[2].Split("=")[1]
        $desc = $CharArray[3].Split("=")[1]
# =======================================================================
# GET NMAP LOG
# =======================================================================         
        $resultLog = getLogNmap $port $ip $desc $search
        if($resultLog -like '*Success*')
        {
        }
        else{
# =======================================================================
# ADD CONTENT TO FILE
# =======================================================================     
            $end ='====================================================='
            Add-Content -Value $end -Path $file_data_output
            Add-Content -Value '' -Path $file_data_output
        }
    }
