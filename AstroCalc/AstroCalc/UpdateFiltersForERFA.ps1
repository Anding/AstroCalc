# PowerShell script to update AstroCalc.vcxproj.filters to organize ERFA files

$filtersFile = "E:\coding\AstroCalc\AstroCalc\AstroCalc.vcxproj.filters"
$erfaSourceDir = "E:\coding\erfa\src"

# Read the filters file
[xml]$filters = Get-Content $filtersFile

# Create ERFA filter if it doesn't exist
$filterGroup = $filters.Project.ItemGroup | Where-Object { $_.Filter -ne $null } | Select-Object -First 1
$erfaFilter = $filterGroup.Filter | Where-Object { $_.Include -eq "ERFA" }

if (-not $erfaFilter) {
    $erfaFilterElement = $filters.CreateElement("Filter", $filters.Project.NamespaceURI)
    $erfaFilterElement.SetAttribute("Include", "ERFA")
    
    $uniqueId = $filters.CreateElement("UniqueIdentifier", $filters.Project.NamespaceURI)
    $uniqueId.InnerText = "{" + [guid]::NewGuid().ToString().ToUpper() + "}"
    $erfaFilterElement.AppendChild($uniqueId) | Out-Null
    
    $filterGroup.AppendChild($erfaFilterElement) | Out-Null
}

# Add ERFA header files to the ClInclude group with ERFA filter
$includeGroup = $filters.Project.ItemGroup | Where-Object { $_.ClInclude -ne $null } | Select-Object -First 1

# Add erfa.h
$erfaHeaderFilter = $filters.CreateElement("ClInclude", $filters.Project.NamespaceURI)
$erfaHeaderFilter.SetAttribute("Include", "`$(ERFASourceDir)\erfa.h")
$filterElement = $filters.CreateElement("Filter", $filters.Project.NamespaceURI)
$filterElement.InnerText = "ERFA"
$erfaHeaderFilter.AppendChild($filterElement) | Out-Null
$includeGroup.AppendChild($erfaHeaderFilter) | Out-Null

# Add erfam.h
$erfamHeaderFilter = $filters.CreateElement("ClInclude", $filters.Project.NamespaceURI)
$erfamHeaderFilter.SetAttribute("Include", "`$(ERFASourceDir)\erfam.h")
$filterElement2 = $filters.CreateElement("Filter", $filters.Project.NamespaceURI)
$filterElement2.InnerText = "ERFA"
$erfamHeaderFilter.AppendChild($filterElement2) | Out-Null
$includeGroup.AppendChild($erfamHeaderFilter) | Out-Null

# Add AstroCalcERFA.c to Source Files filter
$compileGroup = $filters.Project.ItemGroup | Where-Object { $_.ClCompile -ne $null } | Select-Object -First 1

$erfaWrapperFilter = $filters.CreateElement("ClCompile", $filters.Project.NamespaceURI)
$erfaWrapperFilter.SetAttribute("Include", "AstroCalcERFA.c")
$filterElement3 = $filters.CreateElement("Filter", $filters.Project.NamespaceURI)
$filterElement3.InnerText = "Source Files"
$erfaWrapperFilter.AppendChild($filterElement3) | Out-Null
$compileGroup.AppendChild($erfaWrapperFilter) | Out-Null

# Get list of all ERFA .c files (excluding test files)
$erfaFiles = Get-ChildItem "$erfaSourceDir\*.c" | Where-Object { $_.Name -notmatch "^t_erfa" }

# Add each ERFA source file to ERFA filter
foreach ($file in $erfaFiles) {
    $erfaCompileFilter = $filters.CreateElement("ClCompile", $filters.Project.NamespaceURI)
    $erfaCompileFilter.SetAttribute("Include", "`$(ERFASourceDir)\$($file.Name)")
    
    $filterElement4 = $filters.CreateElement("Filter", $filters.Project.NamespaceURI)
    $filterElement4.InnerText = "ERFA"
    $erfaCompileFilter.AppendChild($filterElement4) | Out-Null
    
    $compileGroup.AppendChild($erfaCompileFilter) | Out-Null
}

# Save the updated filters file
$filters.Save($filtersFile)

Write-Host "Filters file updated successfully!"
Write-Host "Added $($erfaFiles.Count) ERFA source files to the ERFA filter."
Write-Host "All ERFA files will now appear under the 'ERFA' folder in Solution Explorer."
