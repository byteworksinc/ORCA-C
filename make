unset exit
unset cc
unset cg

Newer 5/cc cc.rez
if {status} != 0
   set exit on
   echo compile -e cc.rez keep=5/cc
   compile -e cc.rez keep=5/cc
   unset exit
end


if {#} == 0
  Newer obj/asm.a asm.pas
  if {status} != 0
     set asm asm
     set cc cc
     set parser parser
  end

  Newer obj/cc.a cc.pas
  if {status} != 0
     set cc cc
  end

  Newer obj/ccommon.a ccommon.pas ccommon.asm
  if {Status} != 0
     set ccommon ccommon
     set asm asm
     set cc cc
     set cgc cgc
     set cgi cgi
     set expression expression
     set mm mm
     set parser parser
     set scanner scanner
     set symbol symbol
     set table table
     set objout objout
     set native native
     set dag dag
     set gen gen
     set header header
  end              

  Newer obj/cgc.a cgc.pas cgc.asm
  if {status} != 0
     set cgc cgc
     set objout objout
     set native native
  end

  Newer obj/cgi.a cgi.pas cgi.comments cgi.debug
  if {status} != 0
     set cgi cgi
     set asm asm
     set cc cc
     set cgc cgc
     set expression expression
     set parser parser
     set scanner scanner
     set symbol symbol
     set objout objout
     set native native
     set dag dag
     set header header
  end

  Newer obj/expression.a expression.pas expression.asm
  if {status} != 0
     set expression expression
     set asm asm
     set cc cc
     set parser parser
  end

  Newer obj/mm.a mm.pas mm.asm
  if {status} != 0
     set mm mm
     set asm asm
     set cc cc
     set expression expression
     set parser parser
     set scanner scanner
     set symbol symbol
     set header header
  end

  Newer obj/native.a native.pas native.asm
  if {status} != 0
     set native native
  end

  Newer obj/objout.a objout.pas objout.asm
  if {status} != 0
     set objout objout
     set native native
  end

  Newer obj/parser.a parser.pas
  if {status} != 0
     set parser parser
     set cc cc
  end

  Newer obj/scanner.a scanner.pas scanner.debug scanner.asm
  if {status} != 0
     set scanner scanner
     set asm asm
     set cc cc
     set expression expression
     set parser parser
     set symbol symbol
     set header header
  end

  Newer obj/symbol.a symbol.pas symbol.print symbol.asm
  if {status} != 0
     set symbol symbol
     set asm asm
     set cc cc
     set expression expression
     set parser parser
     set header header
  end
     
  Newer obj/table.a table.pas table.asm
  if {status} != 0
     set table table
     set asm asm
     set expression expression
     set parser parser
     set scanner scanner
  end

  Newer obj/dag.a dag.pas
  if {status} != 0
     set dag dag
  end

  Newer obj/gen.a gen.pas
  if {status} != 0
     set dag dag
     set gen gen
  end

  Newer obj/header.a header.pas
  if {status} != 0
     set cc cc
     set parser parser
     set header header
  end

else
  for i
    set {i} {i}
  end
end

set exit on

if "{table}" == table
   if "{ccommon}" == ccommon
      echo compile +t +e ccommon.pas keep=obj/ccommon
      compile +t +e ccommon.pas keep=obj/ccommon
      unset ccommon
   end
   echo compile +t +e table.pas keep=obj/table
   compile +t +e table.pas keep=obj/table
   echo assemble +t +e table.asm keep=obj/table
   assemble +t +e table.asm keep=obj/table
   echo delete obj/table.root
   delete obj/table.root
end

set list ""
set list        "{ccommon} {mm} {cgi} {scanner} {symbol} {header} {expression}"
set list {list} {cgc} {asm} {parser} {cc} {objout} {native} {gen} {dag}
if "{list}" != ""
   for i in {list}
      echo compile +t +e {i}.pas keep=obj/{i}
      compile +t +e {i}.pas keep=obj/{i}
   end
end

unset exit
set exit on
compile linkit
echo filetype 5/cc exe $DB01
filetype 5/cc exe $DB01
