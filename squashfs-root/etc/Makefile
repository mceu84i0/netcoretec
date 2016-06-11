
all:
	@echo "binary program, given by realtek!"
	@echo "we do nothing for it!!!"

#dst=$(CURDIR)/host.conf passwd protocols services nsswitch.conf inetd.conf hosts group
dst=host.conf passwd protocols services nsswitch.conf inetd.conf hosts group profile

romfs:
	[ -e $(ROMPATH)/etc ] || mkdir -p $(ROMPATH)/etc
	cp -fr $(dst) -t $(ROMPATH)/etc
	[ -e $(ROMPATH)/etc/ppp ] || ln -s /var/ppp $(ROMPATH)/etc/ppp 
	cp -fr $(CURDIR)/ppp/true -t $(ROMPATH)/etc/ppp
	#[ -e $(ROMPATH)/etc/ppp ] || mkdir -p $(ROMPATH)/etc/ppp
