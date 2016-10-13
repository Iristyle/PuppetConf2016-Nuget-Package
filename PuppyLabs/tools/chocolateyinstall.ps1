$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName= 'PuppyLabs' # arbitrary name for the package, used in messages
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# this package accepts parameters as space separated key=value pairs (keys may not contain the = symbol)
# currently only one usable param
# INSTALLDIR=c:\path\to\folder
# NOTE: $env:chocolateyPackageParameters is not set when specifying path to .nupkg file without a source like "-s ." specified
# but the $packageParameters value is set, so work for both situations
$params = if ($env:chocolateyPackageParameters) { $env:chocolateyPackageParameters } else { $packageParameters }
$config = $params -split '\s' | % -begin { $h = @{} } -process {
    $split = $_ -split '=',2
    $h.$($split[0]) = $split[1]
  }

# default to c:\inetpub\wwwroot
if (! $h.ContainsKey('INSTALLDIR'))
{
  $defaultDir = [IO.Path]::GetPathRoot([Environment]::GetFolderPath('Windows'))
  $defaultDir = Join-Path $defaultDir "inetpub\wwwroot\$packageName"

  Write-Host "Installation directory unspecified, using $defaultDir"
  $h.INSTALLDIR = $defaultDir
}

$applicationFiles = Join-Path $toolsDir $packageName

# TODO: in the real world we'd clean up extraneous files as well
# copy and overwrite everything from application to INSTALLDIR
Copy-Item -Path $applicationFiles -Destination $h.INSTALLDIR -Recurse -Force

# $packageArgs = @{
#   packageName   = $packageName
#   unzipLocation = $toolsDir
#   softwareName  = 'PuppyLabs' #part or all of the Display Name as you see it in Programs and Features. It should be enough to be unique
# }

# Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package
# #Install-ChocolateyZipPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-zip-package
# ## If you are making your own internal packages (organizations), you can embed the installer or
# ## put on internal file share and use the following instead (you'll need to add $file to the above)
# #Install-ChocolateyInstallPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-install-package

# ## Main helper functions - these have error handling tucked into them already
# ## see https://chocolatey.org/docs/helpers-reference

# ## Unzips a file to the specified location - auto overwrites existing content
# ## - https://chocolatey.org/docs/helpers-get-chocolatey-unzip
# #Get-ChocolateyUnzip "FULL_LOCATION_TO_ZIP.zip" $toolsDir

# ##PORTABLE EXAMPLE
# #$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
# # despite the name "Install-ChocolateyZipPackage" this also works with 7z archives
# #Install-ChocolateyZipPackage $packageName $url $toolsDir $url64
# ## END PORTABLE EXAMPLE
