 #!/bin/bash

#root_pass="12345678"     #   Пароль для Рута
#teacher_pass="12345"     #   Пароль для Учителя
#student_pass="123"       #   Пароль для Ученика

#autologin="student"       #   Пользователь для автовхода

use_gui=true

script_dir=$(dirname "$0")  #   Папка скрипта

if [ ! $(whoami) == 'root' ]; then
    if [ "$use_gui" = true ]; then
        kdialog --error "Данный скрипт должен быть запущен от root"
    else
        echo -e "\e[31mДанный скрипт должен быть запущен от root\e[0m"
    fi
    exit 1
fi

options=("Обновить систему"
        "Переименовать компьютер (требуется перезагрузка)"
        "Создать пользователей по умолчанию"
        "Пересоздать учетную запись Ученика"
        "Заблокировать Рабочий стол Ученика"
        "Разблокировать Рабочий стол Ученика"
        "Установить автологин"
        "Установить открытый ssh ключ для root"
        "Установить и настроить Veyon"
        "Убрать меню GRUB"
        "Убрать 30-секундное ожидание у учетной записи Ученика"
        "Chrome по умолчанию у Ученика"
        "Удалить учетку User"
        "Переустановить KDE Plasma"
        "Включить WoL"
        "Включить авторизацию через mos.ru"
        "Отключить авторизацию через mos.ru"
        "Включить гостевой вход"
        "Отключить гостевой вход"
        "Перезагрузить"
)

#   список для GUI
options_list=()
for i in "${!options[@]}"; do
    index=$((i + 1))
    options_list+=(${index} "${options[$i]}" off )
done

#   Обновление
function function_update () {
    if [ "$use_gui" = true ]; then
        dbusRef=`kdialog --title="Обновление" --progressbar "Идет обновление" 4`
        qdbus $dbusRef showCancelButton false
        qdbus $dbusRef setLabelText "Обновление списка"
        qdbus $dbusRef Set "" value 1
    fi
    dnf --refresh -y update
    if [ "$use_gui" = true ]; then
        qdbus $dbusRef setLabelText "Обновление пакетов"
        qdbus $dbusRef Set "" value 2
    fi
    dnf --refresh -y upgrade
    if [ "$use_gui" = true ]; then
        qdbus $dbusRef setLabelText "Обновление модулей ядра"
        qdbus $dbusRef Set "" value 3
    fi
#    update-kernel -f
#    if [ "$use_gui" = true ]; then
#        qdbus $dbusRef setLabelText "Очистка"
#        qdbus $dbusRef Set "" value 4
#    fi

    dnf clean all

    if [ "$use_gui" = true ]; then
        qdbus $dbusRef setLabelText "Завершено"
        dbus $dbusRef Set "" value 4
        sleep 1
        qdbus $dbusRef close
    fi
}

#     Переименовать компьютер
function function_rename () {
    myhostname=$(hostname)
    oldhostname=$myhostname

    if [ "$use_gui" = true ]; then
        myhostname=$(kdialog --title="Переименование компьютера" --inputbox "Введите имя компьютера" $myhostname)
    else
        read -p "Введите имя компьютера (текущее: ${myhostname}): " myhostname
    fi

    if [[ -n $myhostname ]] && [[ $myhostname != $oldhostname ]]; then
        pkexec bash -c 'rm -f /etc/machine-id && rm -f /var/lib/dbus/machine-id && dbus-uuidgen --ensure && systemd-machine-id-setup && rm -f /etc/uds-system-agent/registration && hostnamectl hostname '$myhostname''
        echo -e "Новое имя компьютера: \e[92m${myhostname}\e[0m"
        reboot
    else
            echo -e "\e[92mИмя компьютера не изменено. Продолжаем...\e[0m"
    fi
}

#     Создать пользователей по умолчанию
function function_default_users () {
    #   Установка пароля учетки root
    if [ -z ${root_pass+x} ]; then
        if [ "$use_gui" = true ]; then
            password=$(kdialog --password "Введите пароль для root: " --title "Установка пароля для root")
        else
            read -p "Введите пароль для root: " password
        fi
    else
        password=$root_pass
    fi
    if [[ ! "$password" = "" ]]; then
        echo -e "Меняю пароль для \e[92mroot\e[0m"
        chpasswd <<< "root:${password}"
    else
        echo -e "\e[31mПароль root не изменен\e[0m"
    fi

#   Создание учетки учителя
    if [ -z ${teacher_pass+x} ]; then
        if [ "$use_gui" = true ]; then
            password=$(kdialog --password "Введите пароль для Учителя: " --title "Установка пароля для Учителя")
        else
            read -p "Введите пароль для Учителя: " password
        fi
    else
        password=$teacher_pass
    fi
    if ! id teacher &> /dev/null ; then
        if [[ ! "$password" = "" ]]; then
            echo -e "\e[92mСоздаю\e[0m пользователя \e[35mteacher\e[0m и устанавливаю пароль"
            useradd teacher -G wheel -c "Учитель"
            chpasswd <<< "teacher:${password}"
        else
            echo -e "\e[31mПароль Учителя не изменен\e[0m"
        fi
    else
        if [[ ! "$password" = "" ]]; then
            echo -e "Пользователь \e[35mteacher\e[0m \e[92mсуществует\e[0m. Меняю пароль..."
            chpasswd <<< "teacher:${password}"
        else
            echo -e "\e[31mПароль Учителя не изменен\e[0m"
        fi
    fi

#   Создание учетки ученика
    if [ -z ${student_pass+x} ]; then
        if [ "$use_gui" = true ]; then
            password=$(kdialog --password "Введите пароль для Ученика: " --title "Установка пароля для ученика")
        else
            read -p "Введите пароль для Ученика: " password
        fi
    else
        password=$student_pass
    fi
    if ! id student &> /dev/null ; then
        if [[ ! "$password" = "" ]]; then
            echo -e "\e[92mСоздаю\e[0m пользователя \e[35mstudent\e[0m и устанавливаю пароль"
            useradd student -c "Ученик"
            chpasswd <<< "student:${password}"
        else
            echo -e "\e[31mПароль Ученика не изменен\e[0m"
        fi
    else

        if [[ ! "$password" = "" ]]; then
            echo -e "Пользователь \e[35mstudent\e[0m \e[92mсуществует\e[0m. Меняю пароль..."
            chpasswd <<< "student:${password}"
        else
            echo -e "\e[31mПароль Ученика не изменен\e[0m"
        fi
    fi

    mkdir -p '/home/student/Рабочий стол/Сдать работы'
    chown student:student '/home/student/Рабочий стол/Сдать работы'
    chmod 750 '/home/student/Рабочий стол/Сдать работы'
}

#     Блокировка рабочего стола ученика
function function_block_desktop () {
    echo -e "\e[92mБлокирую настройки рабочего стола учетной записи student\e[0m"
    if [ -f /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc ]; then
        chown root:student /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
        chmod 640 /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
        chattr +i /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
    else
        echo -e "\e[31mОтсутствует файл plasma-org.kde.plasma.desktop-appletsrc. Создаю пустой\e[0m"
        touch /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
        chown root:student /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
        chmod 640 /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
        chattr +i /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
    fi
    if [ -f /home/student/.config/systemsettingsrc ]; then
        chown root:student /home/student/.config/systemsettingsrc
        chmod 640 /home/student/.config/systemsettingsrc
        chattr +i /home/student/.config/systemsettingsrc
    else
        echo -e "\e[31mОтсутствует файл systemsettingsrc\e[0m"
    fi
    if [ -f /home/student/.config/kcmfonts ]; then
        sed -i -r "s/^(forceFontDPI=).*/\10/" /home/student/.config/kcmfonts
        chown root:student /home/student/.config/kcmfonts
        chmod 640 /home/student/.config/kcmfonts
        chattr +i /home/student/.config/kcmfonts
    else
        echo -e "\e[31mОтсутствует файл kcmfonts\e[0m"
        echo "[General]" > /home/student/.config/kcmfonts
        echo "forceFontDPI=0" >> /home/student/.config/kcmfonts
        chown root:student /home/student/.config/kcmfonts
        chmod 640 /home/student/.config/kcmfonts
        chattr +i /home/student/.config/kcmfonts
    fi
    if [ -f /home/student/.config/kdeglobals ]; then
        chown root:student /home/student/.config/kdeglobals
        chmod 640 /home/student/.config/kdeglobals
        chattr +i /home/student/.config/kdeglobals
    else
        echo -e "\e[31mОтсутствует файл kdeglobals\e[0m"
        touch  /home/student/.config/kdeglobals
        chown root:student /home/student/.config/kdeglobals
        chmod 640 /home/student/.config/kdeglobals
        chattr +i /home/student/.config/kdeglobals
    fi
    if [ -f /home/student/default.png ]; then
        chown root:student /home/student/default.png
        chmod 640 /home/student/default.png
        chattr +i /home/student/default.png
    fi

    if [ -d /home/student/Рабочий\ стол ]; then
        chown root:student '/home/student/Рабочий стол'
        chmod 750 '/home/student/Рабочий стол'
        chattr +i '/home/student/Рабочий стол'
    fi
}

#     Разлокировка рабочего стола ученика
function function_unblock_desktop () {
    echo -e "\e[92mРазблокирую настройки рабочего стола учетной записи student\e[0m"
    if [ -f /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc ]; then
        chattr -i /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
        chown student:student /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
        chmod 660 /home/student/.config/plasma-org.kde.plasma.desktop-appletsrc
    else
        echo -e "\e[31mОтсутствует файл plasma-org.kde.plasma.desktop-appletsrc\e[0m"
    fi
    if [ -f /home/student/.config/systemsettingsrc ]; then
        chattr -i /home/student/.config/systemsettingsrc
        chown student:student /home/student/.config/systemsettingsrc
        chmod 660 /home/student/.config/systemsettingsrc
    else
        echo -e "\e[31mОтсутствует файл systemsettingsrc\e[0m"
    fi
    if [ -f /home/student/.config/kcmfonts ]; then
        chattr -i /home/student/.config/kcmfonts
        sed -i -r "s/^(forceFontDPI=).*/\10/" /home/student/.config/kcmfonts
        chown student:student /home/student/.config/kcmfonts
        chmod 660 /home/student/.config/kcmfonts
    else
        echo -e "\e[31mОтсутствует файл kcmfonts\e[0m"
    fi
    if [ -f /home/student/.config/kdeglobals ]; then
        chattr -i /home/student/.config/kdeglobals
        chown student:student /home/student/.config/kdeglobals
        chmod 660 /home/student/.config/kdeglobals
    else
        echo -e "\e[31mОтсутствует файл kdeglobals\e[0m"
    fi
    if [ -f /home/student/default.png ]; then
        chattr -i /home/student/default.png
        chown student:student /home/student/default.png
        chmod 660 /home/student/default.png
    fi

    if [ -d /home/student/Рабочий\ стол ]; then
        chattr -i '/home/student/Рабочий стол'
        chown student:student '/home/student/Рабочий стол'
        chmod 770 '/home/student/Рабочий стол'
    fi
}

#     Пересоздание Ученика
function function_recreate_student () {
    function_unblock_desktop
    userdel -rf student
    rm -rf /home/student
    echo -e "\e[92mСоздаю\e[0m пользователя \e[35mstudent\e[0m и устанавливаю пароль"
    if [ -z ${student_pass+x} ]; then
        if [ "$use_gui" = true ]; then
            password=$(kdialog --password "Введите пароль для Ученика: " --title "Установка пароля для ученика")
        else
            read -p "Введите пароль для Ученика: " password
        fi
    else
        password=$student_pass
    fi
    if [[ ! "$password" = "" ]]; then
        useradd student -c "Ученик"
        chpasswd <<< "student:${password}"
    else
        echo -e "\e[31mПароль Ученика не изменен\e[0m"
    fi

    mkdir -p '/home/student/Рабочий стол/Сдать работы'
    chown student:student '/home/student/Рабочий стол/Сдать работы'
    chmod 750 '/home/student/Рабочий стол/Сдать работы'
}

#   Автологин
function function_autologin () {
    #   Если был автологин на User, меняем на student
    if [ -z ${autologin+x} ]; then
        if [ "$use_gui" = true ]; then
            username=$(kdialog --inputbox "Введите имя учетной записи для автовхода: " --title "Настройка автовхода")
        else
            read -p "Введите имя учетной записи для автовхода: " username
        fi
    else
        username=$autologin
    fi
#    if id student &> /dev/null ; then
        echo -e "\e[92mМеняю автологин на ${username}\e[0m"
        sed -i -r 's/^([Ss]ession=).*/\1plasma/' /etc/sddm.conf.d/kde_settings.conf
        sed -i -r "s/^([Uu]ser=).*/\1${username}/" /etc/sddm.conf.d/kde_settings.conf
#    fi
}

#     Открытый ключ для рута
function function_ssh_root () {
    #   Настройка ssh для Рута
    if [ -f "${script_dir}/id_rsa.pub" ] ; then
        echo -e "\e[92mНайден ключ ssh \e[35m${script_dir}/id_rsa.pub\e[0m"
        mkdir -p '/root/.ssh'
        cp -fv "${script_dir}/id_rsa.pub" '/root/.ssh/'
        chmod 440 '/root/.ssh/id_rsa.pub'
        cat '/root/.ssh/id_rsa.pub' > '/root/.ssh/authorized_keys' && chmod -v 600 '/root/.ssh/authorized_keys'
    else
        if [ "$use_gui" = true ]; then
            kdialog --error "Отсутствует ключ id_rsa.pub"
        else
            echo -e "\e[31mОтсутствует ключ id_rsa.pub\e[0m"
        fi
    fi
}

#     Установка и настройка Veyon
function function_veyon_setup () {
    echo -e '\e[92mУстановка Veyon\e[0m'
    dnf install -y veyon-core
#     veyon-cli service start
#     if [ "$(systemctl is-active veyon.service)" == "active" ]; then
        veyon_key_name=$(find "${script_dir}" -type f -name "*_public_key.pem" -exec basename \{} _public_key.pem \;)

        veyon-cli config set Authentication/Method 1
        veyon-cli config set Service/HideTrayIcon true

        if [ -f "${script_dir}/${veyon_key_name}_public_key.pem" ]; then
            echo -e "\e[92mНайден ключ для Veyon \e[35m${script_dir}/${veyon_key_name}_public_key.pem\e[0m"

            echo -e '\e[92mИмпорт ключей\e[0m'
            if [ -f "/etc/veyon/keys/public/${veyon_key_name}/key" ]; then
                echo -e "\e[92mКлюч \e[35m${veyon_key_name}/public \e[92mуже установлен. \e[31mУдаляю\e[0m"
                rm -rfv "/etc/veyon/keys/public/${veyon_key_name}/key"
            fi
            veyon-cli authkeys import "${veyon_key_name}/public" "${script_dir}/${veyon_key_name}_public_key.pem"
            echo -e '\e[92mУстановка группы доступа\e[0m'
            veyon-cli authkeys setaccessgroup "${veyon_key_name}/public" "wheel"
            echo -e '\e[92mПерезапуск сервиса\e[0m'
            veyon-cli service restart
        else
            if [ "$use_gui" = true ]; then
                kdialog --error "Открытый ключ для Veyon отсутствует"
            else
                echo -e "\e[31mОткрытый ключ для Veyon отсутствует\e[0m"
            fi
        fi

#     else
#         echo -e '\e[31mVeyon не запущен\e[0m'
#     fi
}

#   Настройка GRUB
function function_grub () {
    echo -e "\e[92mМеняю настройки GRUB\e[0m"
    sed -i -r 's/.*GRUB_TIMEOUT=.*/GRUB_TIMEOUT="0"/i' /etc/default/grub
    sed -i -r 's/.*GRUB_HIDDEN_TIMEOUT=.*/GRUB_HIDDEN_TIMEOUT=$GRUB_TIMEOUT/i' /etc/default/grub
    sed -i -r 's/.*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER="true"/i' /etc/default/grub
#     grub-mkconfig -o /boot/grub/grub.cfg
    update-grub2
}

#   Удаление ненужной учетки пользователя
function function_delete_user () {
    if id user &> /dev/null ; then
        echo -e "\e[92mУдаляю пользователя\e[0m \e[97mUser\e[0m"
        userdel -rf user
    fi
}

#   Установка Chrome браузером по умолчанию
function function_default_chrome () {
    if [ ! -f /home/student/.config/mimeapps.list ]; then
        echo -e "\e[92mУстанавливаю Chrome браузером по умолчанию\e[0m"
        echo '[Default Applications]' > /home/student/.config/mimeapps.list
        echo 'x-scheme-handler/http=chromium.desktop;' >> /home/student/.config/mimeapps.list
        echo 'x-scheme-handler/https=chromium.desktop;'  >> /home/student/.config/mimeapps.list
        chown student:student /home/student/.config/mimeapps.list
    else
        sed -i -r 's/(http=|https=).*/\1chromium.desktop;/' /home/student/.config/mimeapps.list
    fi
}

#   Отключение 30-секундного ожидания
function function_instant_logout () {
    if [ -f /home/student/.config/ksmserverrc ] ; then
        rm -rfv /home/student/.config/ksmserverrc
    fi
    echo '[General]' > /home/student/.config/ksmserverrc
    echo 'confirmLogout=false' >> /home/student/.config/ksmserverrc
    chown -v student:student /home/student/.config/ksmserverrc
}

function function_reinstall_plasma () {
#     dnf reinstall kde5-mini kde5-small gtk-theme-breeze-education sddm-theme-breeze kde5-display-manager-5-sddm plasma5-sddm-kcm sddm plasma5-khotkeys
     dnf reinstall -y task-plasma5
#	echo Временно отключено
}

function function_enable_wol() {
    echo 'Cкрипт включает Wake-on-LAN для всех интерфейсов, имя которых начинается с en'

    main() {
        echo 'ACTION=="add", SUBSYSTEM=="net", NAME=="en*", RUN+="/usr/sbin/ethtool -s $name wol g"' > /etc/udev/rules.d/81-wol.rules &&
        for i in /sys/class/net/en*; do
            ethtool -s ${i##*/} wol g
        done
    }

    main &&
    echo 'Готово.'
}

function function_enable_mos() {
    dnf in -y mos-auth-core mos-auth-folders
    mos-auth-config enable
    echo -e "\e[92mВход через mos.ru \e[35mвключен\e[0m"
}

function function_disable_mos() {
    mos-auth-config disable
    dnf remove -y mos-auth-core mos-auth-folders
    echo -e "\e[92mВход через mos.ru \e[35mотключен\e[0m"
    sed -i -r "s/^([Cc]urrent=).*/\1breeze/" /etc/sddm.conf.d/kde_settings.conf
}

function function_enable_mos_guest(){
    echo -e "\e[92mВключаю гостевой вход через mos-auth\e[0m"
    sed -i -r 's/.*guest-enabled=.*/guest-enabled=true/i' /etc/mos-auth/auth.conf
}

function function_disable_mos_guest(){
    echo -e "\e[92mОтключаю гостевой вход через mos-auth\e[0m"
    sed -i -r 's/.*guest-enabled=.*/guest-enabled=false/i' /etc/mos-auth/auth.conf
}


#     Перезагрузка
function function_reboot () {
    echo "Перезагрузка"
    reboot
}

#   Обработка опций меню
function function_main () {
    option=$1
    case $option in
        1 ) function_update;;
        2 ) function_rename;;
        3 ) function_default_users;;
        4 ) function_recreate_student;;
        5 ) function_block_desktop;;
        6 ) function_unblock_desktop;;
        7 ) function_autologin;;
        8 ) function_ssh_root;;
        9 ) function_veyon_setup;;
        10) function_grub;;
        11) function_instant_logout;;
        12) function_default_chrome;;
        13) function_delete_user;;
        14) function_reinstall_plasma;;
        15) function_enable_wol;;
        16) function_enable_mos;;
        17) function_disable_mos;;
        18) function_enable_mos_guest;;
        19) function_disable_mos_guest;;
        20) function_reboot;;
    esac
}

clear

d=-1
exitstatus=-1
while [[ "$exitstatus" != 1 ]]
do
    if [ "$use_gui" = true ]; then
#         echo "${exitstatus}"
        results=$(kdialog --separate-output --geometry 640x480 --checklist "Настройка системы" "${options_list[@]}")
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            for option in $results; do
                function_main $option
            done
        fi
    else
        echo -e "\e[36mНастройки системы\e[0m"
        for option in "${!options[@]}"; do
            index=$((option + 1))
            echo -e "${index}) ${options[$option]}"
        done
        read -p "Введите номера через пробел или exit для выхода: " line
        results=($line)
        if [ "$line" = "exit" ]; then
            exitstatus=1
        else
            for option in "${results[@]}"; do
                function_main $option
            done
            exitstatus=0
        fi
    fi
done

