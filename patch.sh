#!/bin/bash

# EFI Firmware Patch Script for Mac Pro 4.1 to 5.1
# IMPORTANT: Suorita ensin Recovery mode -> Terminal: csrutil disable

# Vaihe 1: Varmista levykuvat ovat ladattuna ja samassa hakemistossa
EFI2009="EFI2009.dmg"
EFI2010="EFI2010.dmg"

if [[ ! -f "$EFI2009" || ! -f "$EFI2010" ]]; then
  echo "Puuttuvat levykuvat EFI2009.dmg tai EFI2010.dmg!"
  exit 1
fi

# 2. Muunna levykuvat luku/kirjoitus -muotoon
echo "Muunnetaan levykuvat luku/kirjoitus-muotoon..."
hdiutil convert "$EFI2009" -format UDRW -o EFI2009_RW.dmg
hdiutil convert "$EFI2010" -format UDRW -o EFI2010_RW.dmg

# 3. Mounttaa ja nimeä levykuvat
echo "Mountataan levykuvat..."
hdiutil attach EFI2009_RW.dmg
hdiutil attach EFI2010_RW.dmg

diskutil rename "$(hdiutil info | grep '/Volumes/Mac Pro EFI Firmware Update' | awk '{print $1}')" "Mac Pro EFI Update 2009"
diskutil rename "Mac Pro EFI Update" "Mac Pro EFI Update 2010"

# 4. Luo RamDisk, jos ei ole vielä olemassa
if [[ ! -d "/Volumes/RamDisk" ]]; then
  echo "Luodaan RamDisk..."
  diskutil erasevolume HFS+ "RamDisk" $(hdiutil attach -nomount ram://262144)
fi

# 5. Kopioi ja patchaa EFI-tiedostot
pushd /Volumes/RamDisk

echo "Puretaan ja valmistellaan 2010 EFI-tiedostot..."
pkgutil --expand '/Volumes/Mac Pro EFI Update 2010/MacProEFIUpdate.pkg' Expanded2010
cp Expanded2010/MacProEFIUpdate.pkg/Payload ./Payload2010
tar -xf Payload2010
mkdir -p MacProEFI2010-2009 MacProEFI2009-2010
cp 'System/Library/CoreServices/Firmware Updates/MacProEFIUpdate15/EFIUpdaterApp2.efi' MacProEFI2010-2009
cp 'System/Library/CoreServices/Firmware Updates/MacProEFIUpdate15/MP51_007F_03B_LOCKED.fd' MacProEFI2009-2010/MP41_0081_07B_LOCKED.fd
rm -rf Applications Expanded2010 System Payload2010

echo "Puretaan ja valmistellaan 2009 EFI-tiedostot..."
pkgutil --expand '/Volumes/Mac Pro EFI Update 2009/MacProEFIUpdate.pkg' Expanded2009
cp Expanded2009/MacProEFIUpdate.pkg/Payload ./Payload2009
tar -xf Payload2009
cp 'Applications/Utilities/Mac Pro EFI Firmware Update.app/Contents/Resources/EfiUpdaterApp2.efi' MacProEFI2009-2010
cp 'Applications/Utilities/Mac Pro EFI Firmware Update.app/Contents/Resources/MP41_0081_07B_LOCKED.fd' MacProEFI2010-2009/MP51_007F_03B_LOCKED.fd
rm -rf Applications Expanded2009 System Payload2009

popd

# 6. Patchaa EFI-tiedostot (oletetaan että patch-tiedostot ovat saatavilla skriptin kanssa samassa kansiossa)
echo "Patchataan EFI-tiedostot..."
patch /Volumes/RamDisk/MacProEFI2009-2010/EfiUpdaterApp2.efi EfiUpdater2009.patch
patch /Volumes/RamDisk/MacProEFI2010-2009/EfiUpdaterApp2.efi EfiUpdater2010.patch

# 7. Suorita päivitys (varmistetaan että tämä on oikea polku)
echo "Suoritetaan EFI-päivitys..."
sudo /bin/bash ~/Downloads/Mac\ Pro\ 2009-2010\ Firmware\ Tool.app/Contents/Resources/UpgradeEFI2009-2010.sh

echo "Valmis! Sammuta tietokone, käynnistä virtapainike pohjassa ja odota EFI-päivitystä."

# Muista ottaa SIP takaisin käyttöön päivityksen jälkeen (Recovery mode -> Terminal: csrutil enable)
