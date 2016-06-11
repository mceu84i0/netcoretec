#!/bin/sh
ifconfig wlan0  hw ether 001122334455
iwpriv wlan0 set_mib led_type=0
iwpriv wlan0 set_mib opmode=16
iwpriv wlan0 set_mib RFChipID=10
iwpriv wlan0 set_mib MIMO_TR_mode=4  #1T1R
#iwpriv wlan0 set_mib MIMO_TR_mode=3 #2T2R
#iwpriv wlan0 set_mib MIMO_TR_mode=1 #1T2R


eval `flash get HW_TX_POWER_CCK`
eval `flash get HW_WLAN0_TX_POWER_OFDM_2S`
iwpriv wlan0 set_mib TxPowerCCK=$HW_TX_POWER_CCK
iwpriv wlan0 set_mib TxPowerOFDM_1SS=$HW_WLAN0_TX_POWER_OFDM_1S
iwpriv wlan0 set_mib TxPowerOFDM_2SS=$HW_WLAN0_TX_POWER_OFDM_2S

eval `flash get HW_WLAN0_11N_LOFDMPWDA`
eval `flash get HW_WLAN0_11N_LOFDMPWDB`
iwpriv wlan0 set_mib LOFDM_pwd_A=$HW_WLAN0_11N_LOFDMPWDA
iwpriv wlan0 set_mib LOFDM_pwd_B=$HW_WLAN0_11N_LOFDMPWDB

eval `flash get HW_WLAN0_11N_TSSI1`
eval `flash get HW_WLAN0_11N_TSSI2`
iwpriv wlan0 set_mib tssi1=$HW_WLAN0_11N_TSSI1
iwpriv wlan0 set_mib tssi2=$HW_WLAN0_11N_TSSI2

eval `flash get HW_WLAN0_11N_THER`
iwpriv wlan0 set_mib ther=$HW_WLAN0_11N_THER

iwpriv wlan0 set_mib bcnint=100

iwpriv wlan0 set_mib channel=6
iwpriv wlan0 set_mib ssid="MPROM"
iwpriv wlan0 set_mib basicrates=0
iwpriv wlan0 set_mib oprates=0
iwpriv wlan0 set_mib autorate=1
iwpriv wlan0 set_mib rtsthres=2347
iwpriv wlan0 set_mib fragthres=2346
iwpriv wlan0 set_mib expired_time=30000
iwpriv wlan0 set_mib preamble=0
iwpriv wlan0 set_mib hiddenAP=0
iwpriv wlan0 set_mib dtimperiod=3
iwpriv wlan0 set_mib aclnum=0
iwpriv wlan0 set_mib authtype=0
iwpriv wlan0 set_mib encmode=0
iwpriv wlan0 set_mib 802_1x=0
iwpriv wlan0 set_mib wds_num=0
iwpriv wlan0 set_mib wds_enable=0
iwpriv wlan0 set_mib iapp_enable=0
iwpriv wlan0 set_mib band=11

iwpriv wlan0 set_mib use40M=1
iwpriv wlan0 set_mib 2ndchoffset=2
iwpriv wlan0 set_mib shortGI20M=1
iwpriv wlan0 set_mib shortGI40M=1
iwpriv wlan0 set_mib ampdu=1
iwpriv wlan0 set_mib amsdu=1
iwpriv wlan0 set_mib nat25_disable=0
iwpriv wlan0 set_mib macclone_enable=0
iwpriv wlan0 set_mib disable_protection=0
iwpriv wlan0 set_mib block_relay=0
iwpriv wlan0 set_mib wifi_specific=2
iwpriv wlan0 set_mib qos_enable=1
iwpriv wlan0 set_mib guest_access=0
iwpriv wlan0 set_mib psk_enable=0 
