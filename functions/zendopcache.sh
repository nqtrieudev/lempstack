#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
#
# This script's project home is:
#       https://lempstack.com
#       https://github.com/lj2007331/lempstack

Install_ZendOPcache()
{
cd $lemp_dir/src
. ../functions/download.sh
. ../options.conf

src_url=https://pecl.php.net/get/zendopcache-$zendopcache_version.tgz && Download_src
tar xzf zendopcache-$zendopcache_version.tgz 
cd zendopcache-$zendopcache_version 
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
Mem=`free -m | awk '/Mem:/{print $2}'`
if [ $Mem -gt 1024 -a $Mem -le 1500 ];then
        Memory_limit=192
elif [ $Mem -gt 1500 -a $Mem -le 3500 ];then
        Memory_limit=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ];then
        Memory_limit=320
elif [ $Mem -gt 4500 ];then
        Memory_limit=448
else
        Memory_limit=128
fi
if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/opcache.so" ];then
        cat >> $php_install_dir/etc/php.ini << EOF
[opcache]
zend_extension="$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/opcache.so"
opcache.memory_consumption=$Memory_limit
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache.optimization_level=0
EOF
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
        echo -e "\033[31meZend OPcache module install failed, Please contact the author! \033[0m"
fi
cd ..
/bin/rm -rf zendopcache-$zendopcache_version 
cd ..
}
