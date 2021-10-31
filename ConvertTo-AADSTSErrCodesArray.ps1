Function ConvertTo-AADSTSErrCodesArray {
<#
.SYNOPSIS
    Convert AADSTS error codes to ArrayList in Powershell. 
.DESCRIPTION
    Convert a flat file of AADSTS error codes to ArrayList in Powershell that may be further
    transformed into JSON.
.PARAMETER URI
    The web resource that contains the list of AADSTS error codes in a flat file.
 
.EXAMPLE
    ConvertTo-AADSTSErrCodesArray
.EXAMPLE
     ConvertTo-AADSTSErrCodesArray -URI 'https://www.server.com/file.txt'
.EXAMPLE
     ConvertTo-AADSTSErrCodesArray | ConvertTo-Json
.OUTPUTS
    [System.Collections.ArrayList]
.NOTES
    Author:  Carnegie Johnson
    Website: http://www.IAYFconsulting.com
    Twitter: @CarnegieJ

    Flat file pattern: nnnnn|||<description>

    Copyright (c) IAYF Consulting, LLC
    MIT License
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
#>

    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param (
        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$URI = 'https://github.com/IAYFC/azure-signinlog-results/raw/main/resulttypes.txt'
    )

  Begin {
    $ct = 'text/plain'
    $option = [System.StringSplitOptions]::RemoveEmptyEntries
    $ropts = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    $rx = '^([0-9]+)([|][|][|])(.*)'
    $lines = [System.Collections.ArrayList]::new()
    Try {
      $request = Invoke-WebRequest -Uri $URI -ContentType $ct -UseBasicParsing
      $lines = [System.Collections.ArrayList]::new($request.Content.Split([Environment]::NewLine, $option))
    }
    Catch {
      throw $_.Exception
    }
  }

  Process {
    $out = [System.Collections.ArrayList]::new()
    foreach ($ec in $lines) {
      $mtchs = [Regex]::Matches($ec, $rx, $ropts)
      if ($mtchs.Success -eq $true) {
        $eCode = $mtchs.Groups[1].Value
        $eDesc = $mtchs.Groups[3].Value
        $eURI = "https://login.microsoftonline.com/error?code={0}" -f $eCode
        $itm = $out.Add(
          [pscustomobject]@{
            'error_code' = $eCode
            'error_desc' = $eDesc
            'error_uri' = $eURI
          }
        )
      }
    }
    $out
  }
}

# ConvertTo-AADSTSErrCodesArray | ConvertTo-Json
