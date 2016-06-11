#! /bin/sh

#called by /etc/profile and natmain_cgi() in cgi
#mean: before it, all modules are not load!!!
#	so, if you want to call at other place, should change this script
eval `flash get NAT_ENABLED`

if [ $NAT_ENABLED = 0 ]; then
	rmmod nf_nat_tftp
	rmmod nf_conntrack_tftp

	rmmod nf_nat_h323
	rmmod nf_conntrack_h323

	rmmod nf_nat_mms
	rmmod nf_conntrack_mms

	rmmod nf_nat_egg
	rmmod nf_conntrack_egg

	rmmod nf_nat_irc
	rmmod nf_conntrack_irc

	rmmod nf_nat_amanda
	rmmod nf_conntrack_amanda

	rmmod nf_nat_quake3
	rmmod nf_conntrack_quake3

	rmmod nf_nat_talk
	rmmod nf_conntrack_talk

	rmmod nf_nat_ipsec
	rmmod nf_conntrack_ipsec

    rmsmod nf_conntrack_l2tp

	rmmod nf_nat_sip
	rmmod nf_conntrack_sip

	#rmmod nf_nat_ftp
	#rmmod nf_conntrack_ftp
else
	eval `flash get NAT_TFTP_ENABLE`
	#eval `flash get NAT_FTP_ENABLE`
	eval `flash get NAT_H323_ENABLE`
	eval `flash get NAT_MMS_ENABLE`
	eval `flash get NAT_EGG_ENABLE`
	eval `flash get NAT_IRC_ENABLE`
	eval `flash get NAT_AMANDA_ENABLE`
	eval `flash get NAT_QUAKE3_ENABLE`
	eval `flash get NAT_TALK_ENABLE`
	eval `flash get NAT_IPSEC_ENABLE`
	eval `flash get NAT_L2TP_ENABLE`
	eval `flash get NAT_SIP_ENABLE`

	if [ $NAT_TFTP_ENABLE = 1 ]; then
		insmod nf_conntrack_tftp.ko
		insmod nf_nat_tftp.ko
	else
    	rmmod nf_nat_tftp
    	rmmod nf_conntrack_tftp	    
	fi

	#if [ $NAT_FTP_ENABLE = 1 ]; then
	#	insmod nf_conntrack_ftp.ko
	#	insmod nf_nat_ftp.ko
	#fi

	if [ $NAT_H323_ENABLE = 1 ]; then
		insmod nf_conntrack_h323.ko
		insmod nf_nat_h323.ko
	else
    	rmmod nf_nat_h323
    	rmmod nf_conntrack_h323	
	fi

	if [ $NAT_MMS_ENABLE = 1 ]; then
		insmod nf_conntrack_mms.ko
		insmod nf_nat_mms.ko
	fi

	if [ $NAT_EGG_ENABLE = 1 ]; then
		insmod nf_conntrack_egg.ko
		insmod nf_nat_egg.ko
	fi

	if [ $NAT_IRC_ENABLE = 1 ]; then
		insmod nf_conntrack_irc.ko
		insmod nf_nat_irc.ko
	fi

	if [ $NAT_AMANDA_ENABLE = 1 ]; then
		insmod nf_conntrack_amanda.ko
		insmod nf_nat_amanda.ko
	fi

	if [ $NAT_QUAKE3_ENABLE = 1 ]; then
		insmod nf_conntrack_quake3.ko
		insmod nf_nat_quake3.ko
	fi

	if [ $NAT_TALK_ENABLE = 1 ]; then
		insmod nf_conntrack_talk.ko
		insmod nf_nat_talk.ko
	fi

	if [ $NAT_IPSEC_ENABLE = 1 ]; then
		insmod nf_conntrack_ipsec.ko
		insmod nf_nat_ipsec.ko
    else
        rmmod nf_nat_ipsec
        rmmod nf_conntrack_ipsec 
	fi
	
	if [ $NAT_L2TP_ENABLE = 1 ]; then
	    insmod nf_conntrack_l2tp.ko
    else
        rmmod nf_conntrack_l2tp         
	fi

	if [ $NAT_SIP_ENABLE = 1 ]; then
		insmod nf_conntrack_sip.ko
		insmod nf_nat_sip.ko
    else
        rmmod nf_nat_sip
        rmmod nf_conntrack_sip 
	fi	
fi
