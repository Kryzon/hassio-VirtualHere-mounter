#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: USBIP Mounter
# Configures USBIP devices
# ==============================================================================

# Configure mount script for all usbip devices
declare server_address
declare bus_id
declare script_directory
declare mount_script
declare vhclient

vhclient="/usr/sbin/vhclientx86_64"
script_directory="/usr/local/bin"
mount_script="/usr/local/bin/mount_devices"

if ! bashio::fs.file_exists "${vhclient}"; then
  wget https://www.virtualhere.com/sites/default/files/usbclient/vhclientx86_64 -P /usr/sbin
  chmod +x /usr/sbin/vhclientx86_64
fi

if ! bashio::fs.directory_exists "${script_directory}"; then
  bashio::log.info  "Creating script directory"
  mkdir -p "${script_directory}" || bashio::exit.nok "Could not create bin folder"
fi

if bashio::fs.file_exists "${mount_script}"; then
  rm "${mount_script}"
fi

if ! bashio::fs.file_exists "${mount_script}"; then
  touch ${mount_script}
  chmod +x ${mount_script}
  echo '#!/command/with-contenv bashio' > "${mount_script}"
  echo 'set -x' >> "${mount_script}"
  echo 'mount -o remount -t sysfs sysfs /sys' >> "${mount_script}"
  echo '/usr/sbin/vhclientx86_64 --log=/var/log/usbip.log -n' >> "${mount_script}"
  for device in $(bashio::config 'devices|keys'); do
    server_address=$(bashio::config "devices[${device}].server_address")
    bus_id=$(bashio::config "devices[${device}].bus_id")
    bashio::log.info "Adding device from server ${server_address} on bus ${bus_id}"
    echo "/usr/sbin/vhclientx86_64 -t "${server_address}.${bus_id}" >> "${mount_script}"
  done
fi
