# PowerShell script to update AstroCalc_test1.vcxproj to include ERFA and test files

$projectFile = "E:\coding\AstroCalc\AstroCalc_test1\AstroCalc_test1.vcxproj"
$erfaSourceDir = "E:\coding\erfa\src"

# Read the project file
[xml]$proj = Get-Content $projectFile

# Add ERFASourceDir property
$userMacrosGroup = $proj.Project.PropertyGroup | Where-Object { $_.Label -eq "UserMacros" }
if ($userMacrosGroup) {
    $erfaPropertyGroup = $proj.CreateElement("PropertyGroup", $proj.Project.NamespaceURI)
    $erfaSourceDirElement = $proj.CreateElement("ERFASourceDir", $proj.Project.NamespaceURI)
    $erfaSourceDirElement.InnerText = $erfaSourceDir
    $erfaPropertyGroup.AppendChild($erfaSourceDirElement) | Out-Null
    $userMacrosGroup.ParentNode.InsertAfter($erfaPropertyGroup, $userMacrosGroup) | Out-Null
}

# Update all ItemDefinitionGroup/ClCompile sections to add AdditionalIncludeDirectories
$compileGroups = $proj.Project.ItemDefinitionGroup.ClCompile
foreach ($compileGroup in $compileGroups) {
    $includeDir = $compileGroup.AdditionalIncludeDirectories
    if ($includeDir) {
        if ($includeDir -notlike "*ERFASourceDir*") {
            $compileGroup.AdditionalIncludeDirectories = "`$(ERFASourceDir);..\AstroCalc;$($includeDir)"
        }
    } else {
        $includeDirElement = $proj.CreateElement("AdditionalIncludeDirectories", $proj.Project.NamespaceURI)
        $includeDirElement.InnerText = "`$(ERFASourceDir);..\AstroCalc;%(AdditionalIncludeDirectories)"
        $compileGroup.AppendChild($includeDirElement) | Out-Null
    }
}

# Get the ClCompile ItemGroup
$compileGroup = $proj.Project.ItemGroup | Where-Object { $_.ClCompile -ne $null } | Select-Object -First 1

# Add AstroCalcERFA.c
$erfaWrapperCompile = $proj.CreateElement("ClCompile", $proj.Project.NamespaceURI)
$erfaWrapperCompile.SetAttribute("Include", "..\AstroCalc\AstroCalcERFA.c")
$compileGroup.AppendChild($erfaWrapperCompile) | Out-Null

# Add AstroCalcERFA_Tests.c
$testCompile = $proj.CreateElement("ClCompile", $proj.Project.NamespaceURI)
$testCompile.SetAttribute("Include", "AstroCalcERFA_Tests.c")
$compileGroup.AppendChild($testCompile) | Out-Null

# Get list of all ERFA .c files (excluding test files and erfaversion.c)
$erfaFiles = Get-ChildItem "$erfaSourceDir\*.c" | Where-Object { 
    $_.Name -notmatch "^t_erfa" -and $_.Name -ne "erfaversion.c" 
}

# Add each ERFA source file
foreach ($file in $erfaFiles) {
    $erfaCompileElement = $proj.CreateElement("ClCompile", $proj.Project.NamespaceURI)
    $erfaCompileElement.SetAttribute("Include", "`$(ERFASourceDir)\$($file.Name)")
    $compileGroup.AppendChild($erfaCompileElement) | Out-Null
}

# Save the updated project file
$proj.Save($projectFile)

Write-Host "Test project file updated successfully!"
Write-Host "Added $($erfaFiles.Count) ERFA source files to the project."
Write-Host "Added AstroCalcERFA.c and AstroCalcERFA_Tests.c"
Write-Host "ERFA include directory: $erfaSourceDir"
