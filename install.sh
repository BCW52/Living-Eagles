#!/bin/bash
ROOT_UID=0
THEME_DIR="/usr/share/grub/themes"
FONT_DIR="/boot/grub/"
THEME_NAME=Living-Eagles
FONT_NAME="Permanent_Marker.pf2"
MAX_DELAY=20
CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # waring color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;
    *)
    echo -e "$@"
    ;;
  esac
}

prompt -s "\n\t********************************\n\t*  ${THEME_NAME} - Grub Theme  *\n\t********************************"
function has_command() {
  command -v $1 > /dev/null
}

prompt -w "\nChecking for root access...\n"
if [ "$UID" -eq "$ROOT_UID" ]; then
  prompt -i "\nChecking for the existence of themes directory...\n"
  [[ -d ${THEME_DIR}/${THEME_NAME} ]] && rm -rf ${THEME_DIR}/${THEME_NAME}
  mkdir -p "${THEME_DIR}/${THEME_NAME}"
  prompt -i "\nInstalling ${THEME_NAME} theme & ${FONT_NAME}...\n"

  cp -a ${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}
  mv ${THEME_DIR}/${THEME_NAME}/$FONT_NAME $FONT_DIR 
  prompt -i "\nSetting ${THEME_NAME} as default...\n"
  cp -an /etc/default/grub /etc/default/grub.bak
  grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
  echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
  echo -e "Updating grub config..."
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif has_command grub2-mkconfig; then
    if has_command zypper; then
      grub2-mkconfig -o /boot/grub2/grub.cfg
    elif has_command dnf; then
      grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    fi
  fi
  prompt -s "\n\t          ***************\n\t          *  All done!  *\n\t          ***************\n"

else
  prompt -e "\n [ Error! ] -> Run me as root "
  read -p "[ trusted ] specify the root password : " -t${MAX_DELAY} -s
  [[ -n "$REPLY" ]] && {
    sudo -S <<< $REPLY $0
  } || {
    prompt  "\n Operation canceled  Bye"
    exit 1
  }
fi
