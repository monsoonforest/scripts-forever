## rename files sequentially based on modification time
## this script will only print the output and not execute
## copy the output and paste to execute in command-line

a=1, ls -tr | while read line; do printf "%s \'%s\' \'%03d_%s\'\n" mv "$line" $((a=a + 1)) "$line"; done

