##########################################################################
# If not stated otherwise in this file or this component's Licenses.txt
# file the following copyright and licenses apply:
#
# Copyright 2019 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

#--------------------------------------------------------------------------------------------------
# Identify active bank ( either bank 0 or bank 1 ) or ( mmcblk0p2 or mmcblk0p3 )
#--------------------------------------------------------------------------------------------------

activeBank=`sed -e "s/.*root=//g" /proc/cmdline | cut -d ' ' -f1`
echo "Active bank partition is $activeBank"

bank1_partition_name=`fdisk /dev/mmcblk0 -l | grep /dev | tail -2 | cut -d' ' -f1 | head -n1`
storage_block_name=`fdisk /dev/mmcblk0 -l | grep /dev | tail -2 | cut -d' ' -f1 | tail -1`

mkdir -p /extblock
mount $storage_block_name /extblock

mkdir -p /extblock/bank0_linux

mount /dev/mmcblk0p1 /extblock/bank0_linux

if [ "$activeBank" = "$bank1_partition_name" ];
then

    passiveBank="/dev/mmcblk0p4";

    rm -rf /extblock/bank0_linux/*

    cp -R /extblock/vlinux_backup_data/* /extblock/bank0_linux/

    # change cmdline.txt for bank0 linux to partition p4 or mmcblk0p4 which has to be active bank after reboot
    sed -i -e "s|${activeBank}|${passiveBank}|g" /extblock/bank0_linux/cmdline.txt
else

    passiveBank="/dev/mmcblk0p4";

    rm -rf /extblock/bank0_linux/*

    cp -R /extblock/vlinux_backup_data/* /extblock/bank0_linux/

    # change cmdline.txt for bank0 linux to partition p4 or mmcblk0p4 which has to be active bank after reboot
    sed -i -e "s|${activeBank}|${passiveBank}|g" /extblock/bank0_linux/cmdline.txt

fi

umount /extblock/bank0_linux

rm -rf /extblock/bank0_linux


umount /extblock

echo "Rebooting with bank switch ...."

reboot -f
