$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName= 'PuppyLabs' # arbitrary name for the package, used in messages
$softwareName = 'PuppyLabs*' #part or all of the Display Name as you see it in Programs and Features. It should be enough to be unique
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

# TODO: in the real world, we'd be smarter about what was removed so not data was destroyed
Write-Host "Removing all files under $($h.INSTALLDIR)"
if (Test-Path $h.INSTALLDIR) { Remove-Item $h.INSTALLDIR -Recurse -Force }


# ## OTHER HELPERS
# ## https://chocolatey.org/docs/helpers-reference
# #Uninstall-ChocolateyZipPackage $packageName # Only necessary if you did not unpack to package directory - see https://chocolatey.org/docs/helpers-uninstall-chocolatey-zip-package
# #Uninstall-ChocolateyEnvironmentVariable # 0.9.10+ - https://chocolatey.org/docs/helpers-uninstall-chocolatey-environment-variable
# #Uninstall-BinFile # Only needed if you used Install-BinFile - see https://chocolatey.org/docs/helpers-uninstall-bin-file
# ## Remove any shortcuts you added
