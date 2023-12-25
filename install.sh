#!/bin/bash

# Чтение значений из файла
number=$(less ./lines 2>/dev/null)

# Кол-во строк в файле
lines=$(wc ./access.log | awk '{print $1}')

# Если возвращается пустое значение, то считаем количество строк и записываем значение в файл
if [ -z "$number" ]
then
    # Дата начала и конца
    timestart=$(awk '{print $4 $5}' ./access.log  | sed 's/\[//; s/\]//' | sed -n 1p)o
    timeend=$(awk '{print $4 $5}' ./access.log | sed 's/\[//; s/\]//' | sed -n "$lines"p)
    # Запись кол-во строк в файле
    echo "$lines" > ./lines
    # Определение кол-ва запросов с IP адресов
    ip=$(awk "NR>$lines"  ./access.log | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 0 ) { print "Количество запросов:" $1, "IP:" $2 } }')
    addresses=$(awk '($9 ~ /200/)' ./access.log |awk '{print $7}'|sort|uniq -c|sort -rn|awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    # Ошибки c момента последнего запуска
    errors=$(less ./access.log | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn)
    # Формирование сообщения и отправка почты
    echo -e "Данные за период:$timestart-$timeend\n$ip\n\n"Часто запрашиваемые адреса:"\n$addresses\n\n"Частые ошибки:"\n$errors" > mail1 #| mail -s "access log" almadm@localhost
else
    # Дата начала и конца
    timestart=$(awk '{print $4 $5}' ./access.log | sed 's/\[//; s/\]//' | sed -n "$((number+1))"p)
    timeend=$(awk '{print $4 $5}' ./access.log | sed 's/\[//; s/\]//' | sed -n "$lines"p)
    # Запись кол-во строк в файле
    echo "$lines" > ./lines
    # Определение кол-ва запросов с IP адресов
    ip=$(awk "NR>$((number+1))" ./access.log | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 0 ) { print "Количество запросов:" $1, "IP:" $2 } }')
    addresses=$(awk '($9 ~ /200/)' ./access.log |awk '{print $7}'|sort|uniq -c|sort -rn|awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    # Ошибки c момента последнего запуска
    errors=$(less ./access.log | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn)
    # Формирование сообщения и отправка почты
    echo -e "Данные за период:$timestart-$timeend\n$ip\n\n"Часто запрашиваемые адреса:"\n$addresses\n\n"Частые ошибки:"\n$errors" > mail2 #| mail -s "access log" almadm@localhost
fi