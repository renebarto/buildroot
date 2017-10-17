#!/bin/bash

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-${BOARD_NAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

for arg in "$@"
do
	case "${arg}" in
		--add-pi3-miniuart-bt-overlay)
		if ! grep -qE '^dtoverlay=pi3-miniuart-bt' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtoverlay=pi3-miniuart-bt' to config.txt (fixes ttyAMA0 serial console)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# fixes rpi3 ttyAMA0 serial console
dtoverlay=pi3-miniuart-bt
__EOF__
		fi
		;;
		--enable-audio)
		if ! grep -qE '^dtparam=audio=on' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtparam=audio=on' to config.txt (enables audio)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enables audio
dtparam=audio=on
__EOF__
		fi
		;;
		--enable-i2s)
		if ! grep -qE '^dtparam=i2s=on' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtparam=i2s=on' to config.txt (enables I2S)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enables I2S
dtparam=i2s=on
__EOF__
		fi
		;;
		--enable-i2c)
		if ! grep -qE '^dtparam=i2c=on' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtparam=i2c=on' to config.txt (enables I2C)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enables I2C
dtparam=i2c=on
__EOF__
		fi
		;;
		--enable-spi)
		if ! grep -qE '^dtparam=spi=on' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtparam=spi=on' to config.txt (enables SPI)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enables SPI
dtparam=spi=on
__EOF__
		fi
		;;
		--aarch64)
		# Run a 64bits kernel (armv8)
		sed -e '/^kernel=/s,=.*,=Image,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		if ! grep -qE '^arm_control=0x200' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable 64bits support
arm_control=0x200
__EOF__
		fi

		# Enable uart console
		if ! grep -qE '^enable_uart=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable rpi3 ttyS0 serial console
enable_uart=1
__EOF__
		fi
		;;
		--gpu_mem_256=*|--gpu_mem_512=*|--gpu_mem_1024=*)
		# Set GPU memory
		gpu_mem="${1:2}"
		sed -e "/^${gpu_mem%=*}=/s,=.*,=${gpu_mem##*=}," -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		;;
		--add-hifiberry-overlay)
		if ! grep -qE '^dtoverlay=hifiberry-dacplus' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtoverlay=hifiberry-dacplus' to config.txt (HifiBerry support)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# HifiBerry support
dtoverlay=hifiberry-dacplus
__EOF__
		fi
		;;
	esac

done

rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
