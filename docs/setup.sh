#!/bin/sh

cd "`dirname "$0"`"
TEXTDOMAINDIR=./locale
TEXTDOMAIN=drweb-scripts

export TEXTDOMAINDIR
export TEXTDOMAIN

includes="gettext.sh strings.sh global.sh platform.sh defaults.sh setup_inc.sh"
for f in $includes ; do
    [ -f "scripts/$f" ] && . scripts/$f
done

INSTALLATION_ERROR=99
INSTALLATION_CANCEL=50

softwaredir=/etc/drweb/software
bindir=/opt/drweb
case `GetPlatform` in
    *freebsd*)
        softwaredir=/usr/local/etc/drweb/software
        bindir=/usr/local/drweb
    ;;
esac

uninstall_drweb6() {
    if [ -x $bindir/remove.sh ] ; then
        $bindir/remove.sh
    fi
}

if [ "$PRODUCT_NAME_SHORT" = "drweb-workstations" ]; then
    while true; do
        # Check if workstations 6 installed.
        if [ -f $softwaredir/drweb-cc.remove ] ; then
            if [ "$DRWEB_NON_INTERACTIVE" = yes ] ; then
                eval_gettext 'Version 6 of Dr.Web for Linux is currently installed. Please remove it first.' ; echo
                exit $INSTALLATION_ERROR
            fi
            quest="`eval_gettext \"Version 6 of Dr.Web for Linux is currently installed and will be removed on the next installation step. Do you want to continue and remove the previous version of the product?\"`"
            if [ -n "$DISPLAY" ]; then
                gui_ask "$quest" \
                    "`eval_gettext \"Dr.Web Anti-virus installation\"`"
                ret=$?
                if [ $ret = 2 ]; then
                    echo
                    eval_gettext 'No GUI dialog program found.' ; echo
                    echo
                    showyesno "$quest" || exit $INSTALLATION_CANCEL
                else
                    [ $ret = 0 ] || exit $INSTALLATION_CANCEL
                fi
            else
                showyesno "$quest" || exit $INSTALLATION_CANCEL
            fi
        else
            break
        fi

        # Uninstall workstations 6.
        uninstall_drweb6
        if [ -x $bindir/drweb-cc ] ; then
            true
        else
            #kill drweb-cc
            cc_sessions="`ps aux |grep drweb-cc| awk '{print $1}'|sort -u`"
            for session in $cc_sessions ; do
                #use ~$session for non-standard home
                eval session_home=~$session
                if [ -f "$session_home/.drweb/.drweb-cc.pid" ] ; then
                    kill `cat "$session_home/.drweb/.drweb-cc.pid" 2>/dev/null`
                fi
            done
        fi
    done
elif [ "$PRODUCT_NAME_SHORT" = "drweb-file-servers" ]; then
    while true; do
        # Check if file-servers 6 installed.
        if [ -f $softwaredir/drweb-smbspider.remove ] ; then
            if [ "$DRWEB_NON_INTERACTIVE" = yes ] ; then
                eval_gettext 'Version 6 of Dr.Web for Unix File Servers is currently installed. Please remove it first.' ; echo
                exit $INSTALLATION_ERROR
            fi
            quest="`eval_gettext \"Version 6 of Dr.Web for Unix File Servers is currently installed and will be removed on the next installation step. Do you want to continue and remove the previous version of the product?\"`"
            showyesno "$quest" || exit $INSTALLATION_CANCEL
        else
            break
        fi
        uninstall_drweb6
    done
elif [ "$PRODUCT_NAME_SHORT" = "drweb-internet-gateways" ]; then
    while true; do
        # Check if internet-gateways 6 installed.
        if [ -f $softwaredir/drweb-icapd.remove ] ; then
            if [ "$DRWEB_NON_INTERACTIVE" = yes ] ; then
                eval_gettext 'Version 6 of Dr.Web for Unix Internet Gateways is currently installed. Please remove it first.' ; echo
                exit $INSTALLATION_ERROR
            fi
            quest="`eval_gettext \"Version 6 of Dr.Web for Unix Internet Gateways is currently installed and will be removed on the next installation step. Do you want to continue and remove the previous version of the product?\"`"
            showyesno "$quest" || exit $INSTALLATION_CANCEL
        else
            break
        fi
        uninstall_drweb6
    done
elif [ "$PRODUCT_NAME_SHORT" = "drweb-mail-servers" ]; then
    while true; do
        # Check if mail-servers 6 installed.
        if [ -f $softwaredir/drweb-maild.remove ] ; then
            if [ "$DRWEB_NON_INTERACTIVE" = yes ] ; then
                eval_gettext 'Version 6 of Dr.Web for Unix Mail Servers is currently installed. Please remove it first.' ; echo
                exit $INSTALLATION_ERROR
            fi
            quest="`eval_gettext \"Version 6 of Dr.Web for Unix Mail Servers is currently installed and will be removed on the next installation step. Do you want to continue and remove the previous version of the product?\"`"
            showyesno "$quest" || exit $INSTALLATION_CANCEL
        else
            break
        fi
        uninstall_drweb6
    done
elif [ "$PRODUCT_NAME_SHORT" = "drweb-kerio-control" ]; then
    if [ -f /var/opt/drweb.com/opt/lib/kerio/avir_drweb.so ] && \
        grep -qF drweb_kerio_plugin_9.0.0 /var/opt/drweb.com/opt/lib/kerio/avir_drweb.so
    then
        showyesno "`eval_gettext 'Version 9 of Dr.Web Kerio Control plugin is currently installed and will be removed on the next installation step. Do you want to continue and remove the previous version of the product?'`" || exit $INSTALLATION_CANCEL
        /var/opt/drweb.com/opt/bin/remove-kerio-control.sh now
    fi

fi

softwaredir=/etc/opt/drweb.com/software
bindir=/opt/drweb.com/bin

case `GetPlatform` in
    *freebsd*)
        softwaredir=/usr/local/etc/drweb.com/software
        bindir=/usr/local/libexec/drweb.com/bin
    ;;
esac

while [ -n "`find \"$softwaredir\" -type f -name '*.remove' ! -name 'drweb-esuite*' ! -name 'drweb-avdesk*' 2>/dev/null`" ]; do
    if [ "$DRWEB_NON_INTERACTIVE" = yes ] ; then
        eval_gettext 'Earlier version of some Dr.Web product(s) is currently installed. Please remove it first.' ; echo
        exit $INSTALLATION_ERROR
    fi
    quest="`eval_gettext \"Earlier version of some Dr.Web product(s) is currently installed and will be removed on the next installation step. Do you want to continue and remove the previous version of the product?\"`"
    if [ -n "$DISPLAY" ]; then
        gui_ask "$quest" \
            "`eval_gettext \"Dr.Web Anti-virus installation\"`"
        ret=$?
        if [ $ret = 2 ]; then
            echo
            eval_gettext 'No GUI dialog program found.' ; echo
            echo
            showyesno "$quest" || exit $INSTALLATION_CANCEL
        else
            [ $ret = 0 ] || exit $INSTALLATION_CANCEL
        fi
    else
        showyesno "$quest" || exit $INSTALLATION_CANCEL
    fi

    if [ -x $bindir/remove.sh ] ; then
        $bindir/remove.sh
    else
        eval_gettext 'Cannot uninstall the previous version of product. Please remove it manually and run installer again.' ; echo
    fi
done

if [ -x ./"scripts/$PRODUCT_NAME_SHORT-preinstall.sh" ]; then
    "./scripts/$PRODUCT_NAME_SHORT-preinstall.sh" || exit $INSTALLATION_ERROR
fi

# run graphical setup if possible
if [ -n "$DISPLAY" -a "$DRWEB_NON_INTERACTIVE" != yes -a -x ./setup ]; then
    ./setup
    r=$?
    if [ $r -eq 0 ]; then
        [ -x scripts/postinstall.sh ] && scripts/postinstall.sh
        exit 0
    elif [ $r -eq $INSTALLATION_ERROR -o $r -eq $INSTALLATION_CANCEL -o $r -gt 128 ]; then
        exit $r
    fi
fi

# fallback to console setup

packageListLoop=true

WelcomePane || exit $INSTALLATION_CANCEL

ShowProblems || exit $INSTALLATION_CANCEL

loop=1
while [ $loop -ne 0 ] ; do
    TypePane
    loop=$?
done

begin=`$GREP -n "$selected" setup.types | cut -f1 -d:`
if [ -z "`$SED -e "1,${begin}d" setup.types`" ] ; then
    customInstallation=1
else
    customInstallation=0
    if [ "$DRWEB_NON_INTERACTIVE" != yes ] ; then
        showLic
        echo
        if ( shownoyes "$lic_accept_str" ) ; then
            :
        else
            echo "$lic_not_accepted_str"
            exit $INSTALLATION_CANCEL
        fi
    fi
fi

INST_PACKAGES="`\"$SED\" -n -e \"1,${begin}d;s/^INSTALL  *//p;/^TYPE /q\" setup.types | \"$TR\" '\n' ' '`"

if [ -n "$INST_PACKAGES" ] ; then
    ./scripts/installpkg.sh $INST_PACKAGES 3>/dev/null || exit $INSTALLATION_ERROR
fi

#run non-interactive
[ -x scripts/postinstall.sh ] && scripts/postinstall.sh
#run interactive
if [ "$DRWEB_NON_INTERACTIVE" != yes ] ; then
  [ -x scripts/postinstall-i.sh ] && scripts/postinstall-i.sh console
fi
[ -x "./scripts/$PRODUCT_NAME_SHORT-postinstall.sh" ] && "./scripts/$PRODUCT_NAME_SHORT-postinstall.sh"

exit 0
