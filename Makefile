# Set to 'yes' to include debugging informations, e.g. DEBUG=yes make -e
DEBUG		:= no

# compiler/linker options
CC		:= gcc
CFLAGS		:= -Wall -fPIC `pkg-config --cflags libxml-2.0` \
	`pkg-config --cflags hal-storage`
LDFLAGS		:= `pkg-config --libs libxml-2.0` \
	`pkg-config --libs hal-storage`

# common source files
SRCS		:= src/conf.c \
		   src/log.c \
		   src/xpath.c \
		   src/hal.c \
		   src/pad.c \
		   src/volume.c \
		   src/local.c \
		   src/device.c
OBJS		:= $(SRCS:.c=.o)

# pam_usb
PAM_USB_SRCS	:= src/pam.c
PAM_USB_OBJS	:= $(PAM_USB_SRCS:.c=.o)
PAM_USB		:= pam_usb.so
PAM_USB_LDFLAGS	:= -shared $(LDFLAGS)
PAM_USB_DEST	:= $(DESTDIR)/lib/security

# pusb_check
PUSB_CHECK_SRCS	:= src/pusb_check.c
PUSB_CHECK_OBJS	:= $(PUSB_CHECK_SRCS:.c=.o)
PUSB_CHECK	:= pusb_check

# Tools
PUSB_ADM	:= tools/pusb_adm
PUSB_HOTPLUG	:= tools/pusb_hotplug
TOOLS_DEST	:= $(DESTDIR)/usr/bin

# Conf
CONFS		:= doc/pusb.conf-dist
CONFS_DEST	:= $(DESTDIR)/etc/pusb

# Doc
DOCS		:= doc/installation doc/configuration doc/upgrading
DOCS_DEST	:= $(DESTDIR)/usr/share/doc/pamusb

# Man
MANS		:= doc/pusb_adm.1.gz doc/pusb_hotplug.1.gz
MANS_DEST	:= $(DESTDIR)/usr/share/man/man1

# Binaries
RM		:= rm
INSTALL		:= install
MKDIR		:= mkdir

ifeq (yes, ${DEBUG})
	CFLAGS := ${CFLAGS} -ggdb
endif

all		: $(PAM_USB) $(PUSB_CHECK)

$(PAM_USB)	: $(OBJS) $(PAM_USB_OBJS)
		$(CC) -o $(PAM_USB) $(PAM_USB_LDFLAGS) $(OBJS) $(PAM_USB_OBJS)

$(PUSB_CHECK)	: $(OBJS) $(PUSB_CHECK_OBJS)
		$(CC) -o $(PUSB_CHECK) $(LDFLAGS) $(OBJS) $(PUSB_CHECK_OBJS)

%.o		: %.c
		${CC} -c ${CFLAGS} $< -o $@

clean		:
		$(RM) -f $(PAM_USB) $(PUSB_CHECK) $(OBJS) $(PUSB_CHECK_OBJS) $(PAM_USB_OBJS)

install		: all
		$(MKDIR) -p $(CONFS_DEST) $(DOCS_DEST)
		$(INSTALL) -m644 $(PAM_USB) $(PAM_USB_DEST)
		$(INSTALL) -m755 $(PUSB_CHECK) $(PUSB_ADM) $(PUSB_HOTPLUG) $(TOOLS_DEST)
		$(INSTALL) -m644 $(CONFS) $(CONFS_DEST)
		$(INSTALL) -m644 $(DOCS) $(DOCS_DEST)
		$(INSTALL) -m644 $(MANS) $(MANS_DEST)

deinstall	:
		$(RM) -f $(PAM_USB_DEST)/$(PAM_USB)
		$(RM) -f $(TOOLS_DEST)/$(PUSB_CHECK) $(TOOLS_DEST)/$(PUSB_ADM) $(TOOLS_DEST)/$(PUSB_HOTPLUG)
		$(RM) -rf $(DOCS_DEST)
		$(RM) -f $(MANS_DEST)/pusb_*
