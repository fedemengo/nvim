#!/usr/bin/env sh

TESTFILE="$PWD/nvim/test.fnl"

cat > $TESTFILE << EOF
(var vim {
  :keymap {:set (fn [] (print "set"))}
  :cmd (fn [args] (print args)) })

EOF

cat "$PWD/nvim/fnl/init.fnl" | sed '1d;/module/d;/require/d' >> $TESTFILE

cat "$PWD/nvim/test/test.fnl" | sed '1d;/module/d;/require/d' >> $TESTFILE

fennel --raw-errors --globals "*" $TESTFILE

EXITCODE=$?

rm -f $TESTFILE

echo $EXITCODE

exit $EXITCODE

