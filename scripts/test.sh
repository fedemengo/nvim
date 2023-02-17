#!/usr/bin/env sh

TESTFILE="$PWD/test.fnl"

cat > $TESTFILE << EOF
(var vim {
  :keymap {:set (fn [] (print "set"))}
  :cmd (fn [args] (print args)) })

EOF

cat "$PWD/fnl/init.fnl" | sed '1d;/module/d;/require/d' >> $TESTFILE

cat "$PWD/test/test.fnl" | sed '1d;/module/d;/require/d' >> $TESTFILE

fennel --raw-errors --globals "*" $TESTFILE

EXITCODE=$?

rm -f $TESTFILE

echo $EXITCODE

exit $EXITCODE

