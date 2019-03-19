#!/bin/sh
for file in scripts/*.sh
do echo "Checking $file ..."

   if bash -n "$file"
   then echo "  Syntax: OK"
   else echo "  Syntax: error"
        exit 1
   fi

   if shellcheck "$file"
   then echo "  Shellcheck: OK"
   else echo "  Shellcheck: errors or warnings."
        exit 1
   fi
done
