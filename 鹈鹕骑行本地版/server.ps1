param(
    [int]$Port = 0,
    [switch]$NoBrowser
)

$ErrorActionPreference = 'Stop'
$siteDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$siteFile = Join-Path $siteDir 'index.html'
if (-not (Test-Path -LiteralPath $siteFile -PathType Leaf)) {
    Write-Error 'index.html is missing from the launcher folder.'
    exit 1
}

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
try {
    $listener.Start()
    $actualPort = ([System.Net.IPEndPoint]$listener.LocalEndpoint).Port
    $url = "http://127.0.0.1:$actualPort/"
    Write-Host "Pelican Bike is running at $url"
    Write-Host 'Keep this window open while using the page. Close it to stop the local site.'
    if (-not $NoBrowser) {
        try { Start-Process $url } catch { Write-Host "Open this address manually: $url" }
    }

    while ($true) {
        $client = $listener.AcceptTcpClient()
        try {
            $stream = $client.GetStream()
            $stream.ReadTimeout = 5000
            $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
            $request = $reader.ReadLine()
            if (-not $request) { continue }
            do { $header = $reader.ReadLine() } while ($null -ne $header -and $header.Length -gt 0)

            $parts = $request.Split(' ')
            $method = $parts[0]
            $route = if ($parts.Count -gt 1) { $parts[1].Split('?')[0] } else { '' }
            if (($method -eq 'GET' -or $method -eq 'HEAD') -and ($route -eq '/' -or $route -eq '/index.html')) {
                $status = '200 OK'
                $body = [System.IO.File]::ReadAllBytes($siteFile)
                $contentType = 'text/html; charset=utf-8'
            } else {
                $status = '404 Not Found'
                $body = [System.Text.Encoding]::UTF8.GetBytes('Not Found')
                $contentType = 'text/plain; charset=utf-8'
            }
            $response = "HTTP/1.1 $status`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nCache-Control: no-store`r`nX-Content-Type-Options: nosniff`r`nConnection: close`r`n`r`n"
            $responseBytes = [System.Text.Encoding]::ASCII.GetBytes($response)
            $stream.Write($responseBytes, 0, $responseBytes.Length)
            if ($method -ne 'HEAD') { $stream.Write($body, 0, $body.Length) }
            $stream.Flush()
        } catch {
            Write-Host "Request error: $($_.Exception.Message)"
        } finally {
            $client.Dispose()
        }
    }
} finally {
    $listener.Stop()
}
