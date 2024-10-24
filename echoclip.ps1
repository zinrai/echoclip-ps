param(
    [Parameter(Mandatory=$false)]
    [int]$Port = 12345,

    [Parameter(Mandatory=$false)]
    [string]$ListenAddress = "127.0.0.1",

    # Timeout in seconds (default: 5 seconds)
    [Parameter(Mandatory=$false)]
    [int]$Timeout = 5
)

$ErrorActionPreference = "Stop"

try {
    Write-Host "echoclip listening at ${ListenAddress}:${Port} (${Timeout}s timeout)"

    $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Parse($ListenAddress), $Port)
    $listener.Start()

    while ($true) {
        Write-Host "Ready"

        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)

        Write-Host "Connected"

        $data = ""
        # Convert timeout from seconds to milliseconds
        $stream.ReadTimeout = $Timeout * 1000

        try {
            while ($true) {
                $line = $reader.ReadLine()
                if ($line -eq $null) { break }
                $data += "$line`n"
            }
        }
        catch [System.IO.IOException] {
            # Silent catch for normal connection closure
        }
        finally {
            $reader.Close()
            $stream.Close()
            $client.Close()
        }

        if ($data.Length -gt 0) {
            $data | Set-Clipboard
            Write-Host "Disconnected"
        }
    }
}
catch {
    Write-Host "Error: $_"
}
finally {
    if ($listener) {
        $listener.Stop()
    }
}
