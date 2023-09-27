/*
 * libusb example program to list devices on the bus
 * Copyright © 2007 Daniel Drake <dsd@gentoo.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#define PLATFORM_LINUX
#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))
#define LINUX_VERSION_CODE KERNEL_VERSION(6, 6, 0)

#include <stdio.h>

#include <libusb.h>
#include "os_dep/linux/usb_intf.c"

struct usb_interface {
	/* array of alternate settings for this interface,
	 * stored in no particular order */
	struct usb_host_interface *altsetting;

	struct usb_host_interface *cur_altsetting;	/* the currently
					 * active alternate setting */
	unsigned num_altsetting;	/* number of alternate settings */

	/* If there is an interface association descriptor then it will list
	 * the associated interfaces */
	struct usb_interface_assoc_descriptor *intf_assoc;

	int minor;			/* minor number this interface is
					 * bound to */
	enum usb_interface_condition condition;		/* state of binding */
	unsigned sysfs_files_created:1;	/* the sysfs attributes exist */
	unsigned ep_devs_created:1;	/* endpoint "devices" exist */
	unsigned unregistering:1;	/* unregistration is in progress */
	unsigned needs_remote_wakeup:1;	/* driver requires remote wakeup */
	unsigned needs_altsetting0:1;	/* switch to altsetting 0 is pending */
	unsigned needs_binding:1;	/* needs delayed unbind/rebind */
	unsigned resetting_device:1;	/* true: bandwidth alloc after reset */
	unsigned authorized:1;		/* used for interface authorization */
	enum usb_wireless_status wireless_status;
	struct work_struct wireless_status_work;

	struct device dev;		/* interface specific device info */
	struct device *usb_dev;
	struct work_struct reset_ws;	/* for resets in atomic context */
};

int main(void)
{
	int r = libusb_init(/*ctx=*/NULL);
	if (r < 0)
		return r;

	libusb_device **devs;
	ssize_t cnt = libusb_get_device_list(NULL, &devs);
	if (cnt < 0){
		libusb_exit(NULL);
		return (int) cnt;
	}

		libusb_device *dev;
	int i = 0, j = 0;
	uint8_t path[8];

	libusb_device_descriptor desc;
	while ((dev = devs[i++]) != NULL) {
		
		int r = libusb_get_device_descriptor(dev, &desc);
		if (r < 0) {
			fprintf(stderr, "failed to get device descriptor");
			return -1;
		}

//		printf("%04x:%04x \n",	desc.idVendor, desc.idProduct);

		if((desc.idVendor == 0x2604) && (desc.idProduct == 0x0012)){
			printf("FOUND");
			break;
		}
	}

	auto adapter = rtw_drv_init(struct usb_interface *pusb_intf, const struct usb_device_id *pdid)

	libusb_free_device_list(devs, 1);

	libusb_exit(NULL);
	return 0;
}