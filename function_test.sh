#!/bin/bash

rm temp
echo_hi_to_file() {
	echo "hi">>temp
}

foo=$(echo_hi_to_file)
bar=$foo
wc -l temp

