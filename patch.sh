#!/bin/sh

pushd /Volumes/RamDisk

# 2010 EFI levykuva käsittely
pkgutil --expand '/Volumes/Mac Pro EFI Update 2010/MacProEFIUpdate.pkg' Expanded
cp Expanded/MacProEFIUpdate.pkg/Payload Payload
tar -xf Payload
mkdir MacProEFI2010-2009
mkdir MacProEFI2009-2010
cp 'System/Library/CoreServices/Firmware Updates/MacProEFIUpdate15/EFIUpdaterApp2.efi' MacProEFI2010-2009
cp 'System/Library/CoreServices/Firmware Updates/MacProEFIUpdate15/MP51_007F_03B_LOCKED.fd' MacProEFI2009-2010/MP41_0081_07B_LOCKED.fd
rm -R Applications Expanded System Payload
hdiutil detach '/Volumes/Mac Pro EFI Update 2010/'

# 2009 EFI levykuva käsittely
pkgutil --expand '/Volumes/Mac Pro EFI Update 2009/MacProEFIUpdate.pkg' Expanded
cp Expanded/MacProEFIUpdate.pkg/Payload Payload
tar -xf Payload
cp 'Applications/Utilities/Mac Pro EFI Firmware Update.app/Contents/Resources/EfiUpdaterApp2.efi' MacProEFI2009-2010
cp 'Applications/Utilities/Mac Pro EFI Firmware Update.app/Contents/Resources/MP41_0081_07B_LOCKED.fd' MacProEFI2010-2009/MP51_007F_03B_LOCKED.fd
rm -R Applications Expanded System Payload
hdiutil detach '/Volumes/Mac Pro EFI Update 2009/'

popd

patch /Volumes/RamDisk/MacProEFI2009-2010/EfiUpdaterApp2.efi EfiUpdater2009.patch
patch /Volumes/RamDisk/MacProEFI2010-2009/EfiUpdaterApp2.efi EfiUpdater2010.patch
