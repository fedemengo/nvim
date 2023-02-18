#!/usr/bin/env sh

TESTFILE="$PWD/nvim/test.fnl"

cat > $TESTFILE << EOF
(var vim {
  :keymap {:set (fn [] (print "set"))}
  :cmd (fn [args] (print args)) })

EOF

cat "$PWD/nvim/fnl/init.fnl" | sed '/module/d;/require/d' >> $TESTFILE

cat "$PWD/nvim/tests/test.fnl" | sed '/module/d;/require/d' >> $TESTFILE

fennel --raw-errors --globals "*" $TESTFILE

EXITCODE=$?

rm -f $TESTFILE

echo $EXITCODE

exit $EXITCODE

