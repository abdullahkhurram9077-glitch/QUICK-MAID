$Port = 3000

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:3000/')
$listener.Prefixes.Add('http://127.0.0.1:3000/')
try {
    $listener.Prefixes.Add('http://192.168.8.30:3000/')
} catch {}

$listener.Start()
Write-Host '==================================================' -ForegroundColor Green
Write-Host ' QuickMaid Server Running at http://localhost:3000/' -ForegroundColor Cyan
Write-Host ' Local Wi-Fi Access at http://192.168.8.30:3000/' -ForegroundColor Cyan
Write-Host ' Listening for SMS Dispatch Alerts to +265887081958' -ForegroundColor Yellow
Write-Host '==================================================' -ForegroundColor Green

$rootDir = Get-Location

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    $path = $request.Url.AbsolutePath

    if ($request.HttpMethod -eq 'POST' -and $path -eq '/api/dispatch') {
        $reader = New-Object System.IO.StreamReader($request.InputStream, $request.ContentEncoding)
        $jsonBody = $reader.ReadToEnd()
        $reader.Close()

        Write-Host ''
        Write-Host '==================================================' -ForegroundColor Yellow
        Write-Host ' 📲 [AUTOMATIC SMS DISPATCH ALERT TRIGGERED]' -ForegroundColor Green
        Write-Host ' Target Phone : +265887081958' -ForegroundColor Cyan
        Write-Host " Dispatch Payload: $jsonBody" -ForegroundColor White
        Write-Host ' Timestamp   : ' (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -ForegroundColor Gray
        Write-Host '==================================================' -ForegroundColor Yellow
        Write-Host ''

        $logPath = Join-Path $rootDir 'sms_dispatches.log'
        $logText = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Target: +265887081958 | Payload: $jsonBody`r`n"
        Add-Content -Path $logPath -Value $logText

        $resJson = '{"success":true,"message":"SMS alert dispatched to +265887081958"}'
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($resJson)
        $response.ContentType = 'application/json; charset=utf-8'
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    }
    else {
        $filePath = Join-Path $rootDir 'code.html'

        if (Test-Path $filePath) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentType = 'text/html; charset=utf-8'
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $notFound = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found')
            $response.OutputStream.Write($notFound, 0, $notFound.Length)
        }
        $response.Close()
    }
}
