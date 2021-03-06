set -e

if [ "x$debug" == "xon" ]; then #get core-dump on crash
    ulimit -c unlimited
fi

cmd=../src/ln_test

. ./options.sh

test_def() {
    test_file=$(basename $1)
    test_name=$(echo $test_file | sed -e 's/\..*//g')

    echo ===============================================================================
    echo "[${test_file}]: test for ${2}"
}

execute() {
    if [ "x$debug" == "xon" ]; then
	echo "======rulebase======="
	cat tmp.rulebase
	echo "====================="
	set -x
    fi
    echo "$1" | $cmd $ln_opts -r tmp.rulebase -e json > test.out 
    echo "Out:"
    cat test.out
    if [ "x$debug" == "xon" ]; then
	set +x
    fi
}

assert_output_contains() {
    cat test.out | grep -F "$1"
}

assert_output_json_eq() {
    ./json_eq "$1" "$(cat test.out)"
}

rulebase_file_name() {
    if [ "x$1" == "x" ]; then
	echo tmp.rulebase
    else
	echo $1.rulebase
    fi
}

reset_rules() {
    local rb_file=$(rulebase_file_name $1)
    rm -f $rb_file
}

add_rule() {
    local rb_file=$(rulebase_file_name $2)
    echo $1 >> $rb_file
}

cleanup_tmp_files() {
    rm -f test.out *.rulebase 
}

reset_rules
