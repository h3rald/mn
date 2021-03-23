import 
  mnpkg/meta

# Package

version       = pkgVersion
author        = pkgAuthor
description   = pkgDescription
license       = "MIT"
bin           = @[pkgName]
installFiles  = @["mn.yml", "mn.nim"]
installDirs   = @["mnpkg"]

# Dependencies

requires "nim >= 1.4.4"
