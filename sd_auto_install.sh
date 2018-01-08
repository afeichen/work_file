#!/bin/bash

if [ $UID -ne 0 ];then
	echo "pls use root login in"
	exit 9
fi

/bin/ping www.baidu.com -c 2 &>/dev/null
if [ $? -ne 0 ];then
	echo "the network is have a trouble,pls check!!!"
	exit 1
else
	test ! -d /application && mkdir /application && cd /application
	wget https://github.com/afeichen/work_file/raw/master/hiredis-0.10.1-3.el6.x86_64.rpm
	wget https://github.com/afeichen/work_file/blob/master/redis-2.8.19.tar.gz
	wget https://github.com/afeichen/work_file/blob/master/redis.conf
	wget https://github.com/afeichen/work_file/blob/master/sd_pro.tgz
	wget https://github.com/afeichen/work_file/blob/master/sd_script.tgz
fi

df -h

read -p "pls enter your dir for sd's data: " data_dir

sd_mkdir() {
	mkdir -p /opt/cap/tcpreassembly
	mkdir -p $data_dir && cd $data_dir && mkdir hour hourdb script data count
}

sd_mkdir

sd_xf_tgz() {
	cd /application
	cp sd_pro.tgz /opt/cap/tcpreassembly && tar xf sd_pro.tgz
	cp sd_script.tgz $data_dir/script && tar xf sd_script.tgz
	cp redis.conf /etc
	tar xf redis-2.8.19.tar.gz
}

sd_xf_tgz

sd_install() {
	cd /application/redis-2.8.19 && make 
	if [ $? -eq 0 ];then
	cp src/* /usr/sbin/
	mkdir /redis
	redis-server /etc/redis.conf
	    if [ `ps auxf| grep 'redis-server'| grep -v grep| wc -l` -ne 0 ];then
	    cd /application && rpm -ivh hiredis-0.10.1-3.el6.x86_64.rpm
	    sh /opt/cap/tcpreassembly/start.sh
	    fi
	fi 
}

sd_install

sd_sed() {
	read -p "would you want to change file,pls input y/n " aaa
	if [ $aaa == y -o $aaa == Y ];then
		sed -i 's/\/data\/log/\/home\/log/g' $data_dir/script/cron_control.sh
		sed -i 's/\/data\/log/\/home\/log/g' /opt/cap/tcpreassembly/conf/dc.conf
		sed -i 's/\/data\/log/\/home\/log/g' /opt/cap/tcpreassembly/start.sh
		sed -i 's/\/data\/log/\/home\/log/g' /opt/cap/tcpreassembly/stop.sh
		sh $data_dir/script/cron_control.sh cron_add
		sh /opt/cap/tcpreassembly/stop.sh
		sh /opt/cap/tcpreassembly/start.sh
	elif [ $aaa == n -o $aaa == N ];then
		echo "ok,now check the program"
	fi
	
}

sd_sed

sd_check() {
	if [ `ps auxf| grep 'conf/dc'| grep -v grep| wc -l` -ne 0 ];then
	echo "sd is install successful"
	fi
}
sd_check
