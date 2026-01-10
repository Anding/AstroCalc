# PowerShell script to update AstroCalc.vcxproj to reference ERFA files from their repository

$projectFile = "E:\coding\AstroCalc\AstroCalc\AstroCalc.vcxproj"
$erfaSourceDir = "E:\coding\erfa\src"

# Read the project file
[xml]$proj = Get-Content $projectFile

# Find the PropertyGroup after UserMacros
$userMacrosGroup = $proj.Project.PropertyGroup | Where-Object { $_.Label -eq "UserMacros" }
if ($userMacrosGroup) {
    # Create a new PropertyGroup after UserMacros to define ERFASourceDir
    $erfaPropertyGroup = $proj.CreateElement("PropertyGroup", $proj.Project.NamespaceURI)
    $erfaSourceDirElement = $proj.CreateElement("ERFASourceDir", $proj.Project.NamespaceURI)
    $erfaSourceDirElement.InnerText = $erfaSourceDir
    $erfaPropertyGroup.AppendChild($erfaSourceDirElement) | Out-Null
    $userMacrosGroup.ParentNode.InsertAfter($erfaPropertyGroup, $userMacrosGroup) | Out-Null
}

# Update all ItemDefinitionGroup/ClCompile sections to add AdditionalIncludeDirectories
$compileGroups = $proj.Project.ItemDefinitionGroup.ClCompile
foreach ($compileGroup in $compileGroups) {
    # Check if AdditionalIncludeDirectories already exists
    $includeDir = $compileGroup.AdditionalIncludeDirectories
    if ($includeDir) {
        # Append to existing
        if ($includeDir -notlike "*ERFASourceDir*") {
            $compileGroup.AdditionalIncludeDirectories = "`$(ERFASourceDir);$($includeDir)"
        }
    } else {
        # Create new
        $includeDirElement = $proj.CreateElement("AdditionalIncludeDirectories", $proj.Project.NamespaceURI)
        $includeDirElement.InnerText = "`$(ERFASourceDir);%(AdditionalIncludeDirectories)"
        $compileGroup.AppendChild($includeDirElement) | Out-Null
    }
}

# Add ERFA header files to ClInclude group
$includeGroup = $proj.Project.ItemGroup | Where-Object { $_.ClInclude -ne $null } | Select-Object -First 1
if ($includeGroup) {
    # Add erfa.h
    $erfaHeader = $proj.CreateElement("ClInclude", $proj.Project.NamespaceURI)
    $erfaHeader.SetAttribute("Include", "`$(ERFASourceDir)\erfa.h")
    $includeGroup.AppendChild($erfaHeader) | Out-Null
    
    # Add erfam.h
    $erfamHeader = $proj.CreateElement("ClInclude", $proj.Project.NamespaceURI)
    $erfamHeader.SetAttribute("Include", "`$(ERFASourceDir)\erfam.h")
    $includeGroup.AppendChild($erfamHeader) | Out-Null
}

# Add AstroCalcERFA.c to compile group with precompiled header turned off
$compileGroup = $proj.Project.ItemGroup | Where-Object { $_.ClCompile -ne $null } | Select-Object -First 1
if ($compileGroup) {
    # Check if AstroCalcERFA.c already exists
    $erfaCompile = $compileGroup.ClCompile | Where-Object { $_.Include -eq "AstroCalcERFA.c" }
    if (-not $erfaCompile) {
        $erfaCompileElement = $proj.CreateElement("ClCompile", $proj.Project.NamespaceURI)
        $erfaCompileElement.SetAttribute("Include", "AstroCalcERFA.c")
        
        # Add PrecompiledHeader elements for all configurations
        $configs = @("Debug|Win32", "Release|Win32", "Debug|x64", "Release|x64")
        foreach ($config in $configs) {
            $pch = $proj.CreateElement("PrecompiledHeader", $proj.Project.NamespaceURI)
            $pch.SetAttribute("Condition", "'`$(Configuration)|`$(Platform)'=='$config'")
            $pch.InnerText = "NotUsing"
            $erfaCompileElement.AppendChild($pch) | Out-Null
        }
        
        $compileGroup.AppendChild($erfaCompileElement) | Out-Null
    }
}

# Get list of all ERFA .c files (excluding test files)
$erfaFiles = Get-ChildItem "$erfaSourceDir\*.c" | Where-Object { $_.Name -notmatch "^t_erfa" }

# Add each ERFA source file
foreach ($file in $erfaFiles) {
    $erfaCompileElement = $proj.CreateElement("ClCompile", $proj.Project.NamespaceURI)
    $erfaCompileElement.SetAttribute("Include", "`$(ERFASourceDir)\$($file.Name)")
    
    # Add PrecompiledHeader element (applies to all configurations)
    $pch = $proj.CreateElement("PrecompiledHeader", $proj.Project.NamespaceURI)
    $pch.InnerText = "NotUsing"
    $erfaCompileElement.AppendChild($pch) | Out-Null
    
    $compileGroup.AppendChild($erfaCompileElement) | Out-Null
}

# Save the updated project file
$proj.Save($projectFile)

Write-Host "Project file updated successfully!"
Write-Host "Added $($erfaFiles.Count) ERFA source files to the project."
Write-Host "ERFA include directory: $erfaSourceDir"
