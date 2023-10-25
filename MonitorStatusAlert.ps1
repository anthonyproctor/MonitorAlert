function Get-IdleTime {
    [CmdletBinding()]
    param ()

    $wts = Get-WmiObject Win32_Session
    $idleTime = 0

    foreach ($session in $wts) {
        if ($session.SessionState -eq 0) {
            $userSession = New-Object PSObject -Property @{
                SessionId = $session.SessionId
                UserName = $session.UserName
            }
            $idleTime += ($userSession | Select-Object -Property SessionId, UserName)
        }
    }

    return $idleTime
}

# Function to check if the monitor is off
function IsMonitorOff {
    # Get the idle time in seconds
    $idleTime = (Get-IdleTime)

    # Define the threshold (in seconds) for considering the monitor off
    $monitorOffThreshold = 60  # Adjust this value as needed

    # Check if the idle time exceeds the threshold
    if ($idleTime -ge $monitorOffThreshold) {
        return $true
    } else {
        return $false
    }
}

# Define your email settings
$smtpServer = "smtp-relay.gmail.com"
$smtpPort = 587
$smtpUsername = ""
$smtpPassword = ""
$senderEmail = ""
$recipientEmail = ""
$subject = "Monitor Status Alert"

# Log file path
$logFilePath = "C:\Users\EngrainAdmin\Documents\MonitorStatusLog.txt"

# Check if the monitor is off
if (IsMonitorOff) {
    $logMessage = "$(Get-Date) - Monitor is off. Sending email alert..."
    Add-Content -Path $logFilePath -Value $logMessage
    
    Write-Host $logMessage
    
    # Email body
    $emailBody = "Monitor is off. Please check the connection."
    
    # Send an email alert
    Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -From $senderEmail -To $recipientEmail -Subject $subject -Body $emailBody -Credential (New-Object PSCredential $smtpUsername, (ConvertTo-SecureString $smtpPassword -AsPlainText -Force))
} else {
    $logMessage = "$(Get-Date) - Monitor is on."
    Add-Content -Path $logFilePath -Value $logMessage
    
    Write-Host $logMessage
    # You can add actions for when the monitor is on if needed.
}
