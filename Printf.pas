{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  Printf                                                       }
{                                                               }
{  Analyzes printf/scanf format and arguments to check for      }
{  potential problems.                                          }
{  Called from FunctionParms (Expression.pas)                   }
{  Enabled via #pragma lint 16                                  }
{---------------------------------------------------------------}

unit Printf;

interface

{$LibPrefix '0/obj/'}

uses CCommon, Scanner;

{$segment 'PRINTF'}

type

   fmtArgPtr = ^fmtArgRecord;

   fmtArgRecord = record
      next: fmtArgPtr;
      ty: typePtr;
      tk: tokenPtr;
   end;

   {
   format arg1: printf
   format arg2: fprintf, sprintf, asprintf, dprintf
   format arg3: snprintf

   format arg1: scanf
   format arg2: fscanf, sscanf
   }
   fmt_type = (fmt_none, fmt_printf1, fmt_printf2, fmt_printf3, fmt_scanf1, fmt_scanf2);


function FormatClassify(fname: stringPtr): fmt_type;

procedure FormatCheck(fmt: fmt_type; args: fmtArgPtr);


implementation

const
   feature_hh = true;
   feature_ll = true;
   feature_s_long = false;
   feature_n_size = true;
   feature_scanf_ld = true;

type
   length_modifier = (default, h, hh, l, ll, j, z, t, ld);

   state_enum = (st_text, st_flag, st_width,
      st_precision_dot, st_precision, st_precision_number,
      st_length, st_length_h, st_length_l, st_format,
      { scanf }
      st_suppress, st_set, st_set_1, st_set_2,
      st_error);

   types = set of baseTypeEnum;

function KeyPress: boolean; extern; {in Scanner.asm}



function FormatClassify {fname: stringPtr): fmt_type};
{
   Check if a function name is printf/scanf. Caller must check if
   it otherwise matches (variadic, direct call)
}

var
   l: integer;

begin {FormatClassify}

FormatClassify := fmt_none;

l := length(fname^);
if (l >= 5) and (l <= 8) then case fname^[1] of
   'a': if fname^ = 'asprintf' then FormatClassify := fmt_printf2;
   'd': if fname^ = 'dprintf' then FormatClassify := fmt_printf2;
   'p': if fname^ = 'printf' then FormatClassify := fmt_printf1;
   'f':
      if fname^ = 'fprintf' then FormatClassify := fmt_printf2
      else if fname^ = 'fscanf' then FormatClassify := fmt_scanf2;
   's':
      if fname^ = 'scanf' then FormatClassify := fmt_scanf1
      else if fname^ = 'snprintf' then FormatClassify := fmt_printf3
      else if fname^ = 'sprintf' then FormatClassify := fmt_printf2
      else if fname^ = 'sscanf' then FormatClassify := fmt_scanf2;
      otherwise: ;
   end; {case}
end; {FormatClassify}


procedure FormatCheck{fmt: fmt_type; args: fmtArgPtr};

var
   head: fmtArgPtr;
   s: longstringPtr;
   state: state_enum;
   has_length: length_modifier;
   error_count: integer;
   expected: integer;
   offset: integer;


   number_set : set of char;
   flag_set : set of char;
   length_set : set of char;
   format_set : set of char;



   procedure Warning(msg: stringPtr);
   {
      Pretty Print a warning.
      offset is the location of the current % character within s.
   }
   var 
      i: integer;
      ch: char;

   begin {Warning}
   if error_count = 0 then begin
      WriteLine;
      Error(124);
      WriteLine;
      if s <> nil then begin
         Write('   > "');
         for i := 1 to s^.length-1 do begin
            ch := s^.str[i];
            if ch in [' '..'~'] then begin
               if ch in ['"','\','?'] then
                  write('\');
               write(ch);
               end {if}
            else
               case ord(ch) of
                  7: write('\a');
                  8: write('\b');
                  9: write('\t');
                  10: write('\n');
                  11: write('\v');
                  12: write('\f');
                  13: write('\r');
                  otherwise: begin
                     write('\');
                     write((ord(ch)>>6):1);
                     write(((ord(ch)>>3) & $0007):1);
                     write((ord(ch) & $0007):1);
                     end;
                  end; {case}
            end; {for}
         WriteLn('"');
         end; {if}
      end; {if}
   error_count := error_count + 1;
   Write('     ');
   if offset = 0 then
      if s <> nil then begin
         offset := s^.length-1;
         write(' ');
         end; {if}
   if s <> nil then begin
      if offset > 0 then begin
         if offset > s^.length-1 then
            offset := s^.length-1;
         for i := 1 to offset do begin
            ch := s^.str[i];
            if ch in [' '..'~'] then begin
               if ch in ['"','\','?'] then
                  write(' ');
               write(' ');
               end {if}
            else
               case ord(ch) of
                  7,8,9,10,11,12,13: write('  ');
                  otherwise: write('    ');
                  end; {case}
            end; {for}
         end; {if}
      Write('^ ');
      end; {if}
   WriteLn(msg^);
   end; {Warning}


   procedure WarningConversionChar(c: char);
   { Warn that a conversion character is invalid, eg %z }
   var
      msg: stringPtr;

   begin {WarningConversionChar}
   if (ord(c) >= $20) and (ord(c) < $7f) then begin
      new(msg);
      msg^ := concat('unknown conversion type character ''', c, ''' in format');
      Warning(msg);
      dispose(msg);
      end {if}
   else Warning(@'unknown conversion type character in format');
   end; {WarningConversionChar}


   procedure WarningExtraArgs(i: integer);
   { Warn that too many arguments were provided }
   var
      msg: stringPtr;
   begin {WarningExtraArgs}
   new(msg);
   msg^ := concat('extra argument(s) provided (', cnvis(i), ' expected)');
   Warning(msg);
   dispose(msg);
   end; {WarningExtraArgs}



   function popType: typePtr;
   { Return the token type and advance the linked list. }
   begin {popType}
   expected := expected + 1;
   popType := nil;
   if args <> nil then begin
      popType := args^.ty;
      args := args^.next;
      end; {if}
   end; {popType}


   procedure expect_long;
   { Verify the current argument is a long int.}
   var
      ty: typePtr;

   begin {expect_long}
   ty := popType;
   if ty <> nil then begin
      if (ty^.kind <> scalarType) or (not (ty^.baseType in [cgLong, cgULong])) then begin
         Warning(@'expected long int');
         end; {if}
      end {if}
   else begin
      Warning(@'argument missing; expected long int');
      end; {else}
   end; {expect_long}


   procedure expect_long_long;
   { Verify the current argument is a long long int.}
   var
      ty: typePtr;

   begin {expect_long_long}
   ty := popType;
   if ty <> nil then begin
      if (ty^.kind <> scalarType) or (not (ty^.baseType in [cgQuad, cgUQuad])) then begin
         Warning(@'expected long long int');
         end; {if}
      end {if}
   else begin
      Warning(@'argument missing; expected long long int');
      end; {else}
   end; {expect_long_long}


   procedure expect_int;
   var
      ty: typePtr;

   begin {expect_int}
   ty := popType;
   if ty <> nil then begin
      if (ty^.kind <> scalarType) or 
         not (ty^.baseType in [cgWord, cgUWord, cgByte, cgUByte]) then begin
         Warning(@'expected int');
         end; {if}
      end {if}
   else begin
      Warning(@'argument missing; expected int');
      end; {else}
   end; {expect_int}


   procedure expect_char;
   var
      ty: typePtr;

   begin {expect_char}
   ty := popType;
   if ty <> nil then begin
      if (ty^.kind <> scalarType) or 
         not (ty^.baseType in [cgWord, cgUWord, cgByte, cgUByte]) then begin
         Warning(@'expected char');
         end; {if}
      end {if}
   else begin
      Warning(@'argument missing; expected char');
      end; {else}
   end; {expect_char}


   procedure expect_extended;
   { Verify the current argument is an extended*. }
   { * or float or double or comp since they're all passed as extended }
   var
      ty: typePtr;

   begin {expect_extended}
   ty := popType;
   if ty <> nil then begin
      if (ty^.kind <> scalarType) or
         not (ty^.baseType in [cgExtended, cgReal, cgDouble, cgComp]) then begin
         Warning(@'expected a floating-point value');
         end; {if}
      end {if}
   else begin
      Warning(@'argument missing; expected a floating-point value');
      end; {else}
   end; {expect_extended}


   procedure expect_pointer;
   { Verify the current argument is a pointer of some sort. }
   var
      ty: typePtr;

   begin {expect_pointer}
   ty := popType;
   if ty <> nil then begin
      if not (ty^.kind in [pointerType,arrayType]) then begin
         Warning(@'expected pointer');
         end; {if}
      end {if}
   else begin
      Warning(@'argument missing; expected pointer');
      end; {else}
   end; {expect_pointer}


   procedure expect_pointer_to_pointer;
   { Verify the current argument is a pointer to a pointer.}
   var
      ty: typePtr;
      ok: boolean;

   begin {expect_pointer_to_pointer}
   ok := false;
   ty := popType;

   if ty <> nil then
      if (ty^.kind = pointerType) or (ty^.kind = arrayType) then
         if ty^.pType <> nil then
            if ty^.pType^.kind = pointerType then
               ok := true;

   if not ok then begin
      if ty = nil then
         Warning(@'argument missing; expected pointer to a pointer')
      else Warning(@'expected pointer to a pointer');
      end; {if}

   end; {expect_pointer_to_pointer}


   procedure expect_pointer_to(expected: types; name: stringPtr);
   { Verify the current argument is a pointer to the expected set.}
   var
      ty: typePtr;
      baseTy: typePtr;
      ok: boolean;

      procedure error(prefix: stringPtr);
         var
            msg: stringPtr;
         begin
         new(msg);
         msg^ := concat(prefix^, name^);
         Warning(msg);
         dispose(msg);
         end; {error}

   begin {expect_pointer_to}
   ok := false;
   ty := popType;
   baseTy := nil;

   if ty <> nil then
      if (ty^.kind = pointerType) or (ty^.kind = arrayType) then begin
         baseTy := ty^.pType;
         if (baseTy <> nil)
            and (baseTy^.kind = scalarType)
            and (baseTy^.baseType in expected)
            then ok := true;
         end; {if}

   if not ok then begin
      if ty = nil then
         error(@'argument missing; expected pointer to ')
      else error(@'expected pointer to ');
      end; {if}

   end; {expect_pointer_to}


   procedure do_length(c: char);
   { helper to process the length modifier }
   begin {do_length}
   state := st_format;
   case c of
      'h': begin 
         has_length := h; 
         state := st_length_h; 
         end;
      'l': begin 
         has_length := l; 
         state := st_length_l; 
         end;
      'j': has_length := j;
      'z': has_length := z;
      't': has_length := t;
      'L': has_length := ld;
      end; {case}
   end; {do_length}



   procedure FormatScanf;
   { Check the scanf string and arguments. }

   label 1;

   var
      i: integer;
      c: char;
      has_suppress: boolean;



      procedure do_scanf_format;

      { check an individual scanf argument. }

      {
         (current) ORCALib limitations, wrt size modifiers:

         - ignored for string types
         - hh not supported
         - L not supported
         - ignored for 'n'
      }
      var
         expected: types;
         name: stringPtr;

      begin {do_scanf_format}

      name := nil;

      state := st_text;
      if c in format_set then begin

         case c of

            '%': begin
               if has_suppress or (has_length <> default) then
                  Warning(@'invalid element in %% conversion specification');
               has_suppress := true;
               end;

            'b', 'P': begin
               if has_length <> default then
                  Warning(@'length modifier may not be used with %b or %P');
               expected := [cgByte, cgUByte];
               name := @'char';
               end;

            'c', 's', '[' : begin
               { %ls, etc is a wchar_t *}

               expected := [cgByte, cgUByte];
               name := @'char';

               if has_length = l then begin
                  expected := [cgWord, cgUWord];
                  name := @'wchar_t';

                  if not feature_s_long then
                     Warning(@'%ls, %lc, or %l[ is not currently supported');

                  end {if}
               else if has_length <> default then
                  Warning(@'invalid length modifier');

               if c = '[' then state := st_set_1;
               end;

            'd', 'i', 'u', 'o', 'x', 'X': begin
               case has_length of
                  hh: begin
                     expected := [cgByte, cgUByte];
                     name := @'char';
                     end;
                  l, z, t: begin
                     expected := [cgLong, cgULong];
                     name := @'long';
                     end;
                  ll, j: begin
                     expected := [cgQuad, cgUQuad];
                     name := @'long long';
                     end;
                  h: begin
                     expected := [cgWord, cgUWord];
                     name := @'short';
                     end;
                  default: begin
                     expected := [cgWord, cgUWord];
                     name := @'int';
                     end;
                  otherwise: begin
                     Warning(@'invalid length modifier');
                     expected := [cgWord, cgUWord];
                     name := @'int';
                     end;
                  end; {case}
               end;

            'n': begin
               { n.b. - *n is  undefined; orcalib pops a parm but doesn't store.}
               { C99 - support for length modifiers }
               if has_suppress then Warning(@'behavior of %*n is undefined');
               has_suppress := false;

               if (not feature_n_size) and (has_length <> default) then
                  Warning(@'size modifier for %n is not currently supported');

               case has_length of
                  hh: begin
                     expected := [cgByte, cgUByte];
                     name := @'char';
                     end;
                  l, z, t: begin
                     expected := [cgLong, cgULong];
                     name := @'long';
                     end;
                  ll, j: begin
                     expected := [cgQuad, cgUQuad];
                     name := @'long long';
                     end;
                  h: begin
                     expected := [cgWord, cgUWord];
                     name := @'short';
                     end;
                  default: begin
                     expected := [cgWord, cgUWord];
                     name := @'int';
                     end;
                  otherwise: begin
                     Warning(@'invalid length modifier');
                     expected := [cgWord, cgUWord];
                     name := @'int';
                     end;
                  end; {case}
               end;
            'p': begin
               if has_length <> default then
                  Warning(@'length modifier may not be used with %p');
               if not has_suppress then expect_pointer_to_pointer;
               has_suppress := true;
               end;
            'a', 'A', 'f', 'F', 'g', 'G', 'e', 'E': begin

                  case has_length of
                     ld: begin
                        if not feature_scanf_ld then
                           if not has_suppress then
                              Warning(@'L length modifier is not currently supported');
                        expected := [cgExtended];
                        name := @'long double';
                        end;
                     l: begin
                        expected := [cgDouble];
                        name := @'double';
                        end;
                     default: begin
                        expected := [cgReal];
                        name := @'float';
                        end;
                     otherwise: begin
                        Warning(@'invalid length modifier');
                        expected := [cgReal];
                        name := @'float';
                        end;
                     end; {case}
               end;
            end; { case }

         if not has_suppress then begin
            expect_pointer_to(expected, name);
            end; {if}

         end {if}
      else WarningConversionChar(c);


      end; {do_scanf_format}



   begin {FormatScanf}

   {
      '%'
      '*'?                         - assignment suppression
      \d*                          - maximum field width
      (h|hh|l|ll|j|z|t|L)?         - length modifier
      [%bcsdiuoxXnaAeEfFgGp] | set - format

      set: '[[' [^]]* ']'
      set: '[^[' [^]]* ']'
      set: '[' [^]]+ ']'

   }
   state := st_text;
   expected := 0;
   offset := 0;

   number_set := ['0' .. '9'];
   length_set := ['h', 'l', 'j', 't', 'z', 'L']; 
   flag_set := ['#', '0', '-', '+', ' '];
   format_set := ['%', '[', 'b', 'c', 's', 'd', 'i', 'o', 'x', 'X', 'u', 
      'f', 'F', 'e', 'E', 'a', 'A', 'g', 'G', 'n', 'p', 'P'];


   for i := 1 to s^.length do begin
      c := s^.str[i];
      case state of
         st_text:  if c = '%' then begin
            state := st_suppress;
            offset := i;
            has_length := default;
            has_suppress := false;
            end; {if}

         st_suppress: { suppress? width? length? format }
            if c = '*' then begin
               state := st_width;
               has_suppress := true;
               end {if}
            else if c in number_set then state := st_width
            else if c in length_set then do_length(c)
            else do_scanf_format;

         st_width: {width? length? format }
            if c in number_set then state := st_width
            else if c in length_set then do_length(c)
            else do_scanf_format;

         st_length_h: { h? format }
            if c = 'h' then begin
               has_length := hh;
               state := st_format;
               if not feature_hh then
                  Warning(@'hh modifier is not currently supported');
               end {if}
            else do_scanf_format;

         st_length_l: { l? format }
            if c = 'l' then begin
               has_length := ll;
               state := st_format;
               if not feature_ll then
                  Warning(@'ll modifier is not currently supported');
               end {if}
            else do_scanf_format;

         st_format: { format }
            do_scanf_format;

         { first char of a [set]. ']' does not end the set.   }
         st_set_1:
            if c = '^' then state := st_set_2
            else state := st_set;

         st_set_2:
            state := st_set;

         st_set:
            if c = ']' then state := st_text;

         st_error: goto 1;
         end; { case }
      end; { for }

   if state <> st_text then
      Warning(@'incomplete format specifier');

   if args <> nil then begin
      offset := 0;
      WarningExtraArgs(expected);
      end;

1:

   end; {FormatScanf}



   procedure FormatPrintf;
   { Check the printf string and arguments. }

   label 1;

   var

      i : integer;
      c : char;

      has_flag : boolean;
      has_width: boolean;
      has_precision : boolean;

      procedure do_printf_format;
      { check an individual printf argument. }

      begin {do_printf_format}
      state := st_text;
      if c in format_set then begin
         case c of
            'p': begin
               if has_length <> default then
                  Warning(@'length modifier may not be used with %p');
               expect_pointer;
               end;

             { %b: orca-specific - pascal string }
            'b', 'P': begin
               if has_length <> default then
                  Warning(@'length modifier may not be used with %b or %P');
               expect_pointer_to([cgByte, cgUByte], @'char');
               end;
            
            's':
               if has_length = l then begin
                  if not feature_s_long then 
                     Warning(@'%ls is not currently supported');

                  expect_pointer_to([cgWord, cgUWord], @'wchar_t')
                  end {if}
               else begin
                  if has_length <> default then
                     Warning(@'invalid length modifier');
                  expect_pointer_to([cgByte, cgUByte], @'char');
                  end; {else}

            'n': begin

               if (not feature_n_size) and (has_length <> default) then
                  Warning(@'length modifier for %n is not currently supported');

               case has_length of
                  hh:
                     expect_pointer_to([cgByte, cgUByte], @'char');

                  l, z, t:
                        expect_pointer_to([cgLong, cgULong], @'long');

                  ll, j:
                        expect_pointer_to([cgQuad, cgUQuad], @'long long');

                  otherwise: begin
                     if feature_n_size and (has_length = ld) then
                        Warning(@'invalid length modifier');
                     expect_pointer_to([cgWord, cgUWord], @'int');
                     end;
                  end; {case}

               end;

            'c':
               if has_length = l then begin
                  if not feature_s_long then
                     Warning(@'%lc is not currently supported');
                  expect_int;
                  end
               else if has_length <> default then begin
                  Warning(@'invalid length modifier');
                  expect_char;
                  end
               else begin
                  expect_char;
                  end;

            { chars are passed as ints so %hhx can be ignored here. }
            'd', 'i', 'o', 'x', 'X', 'u':
               if has_length in [l, z, t] then begin
                  expect_long;
                  end
               else if has_length in [ll, j] then begin
                  expect_long_long;
                  end
               else if has_length = ld then begin
                  Warning(@'invalid length modifier');
                  expect_int;
                  end
               else begin
                  expect_int;
                  end;

            'f', 'F', 'e', 'E', 'a', 'A', 'g', 'G': begin
               if not (has_length in [l, ld, default]) then
                  Warning(@'invalid length modifier');
               expect_extended;
               end;
                  
            '%': 
               if has_flag or has_width or has_precision
                  or (has_length <> default) then
                  Warning(@'invalid element in %% conversion specification');
            end; {case}
         end {if}
      else WarningConversionChar(c);


      end; {do_printf_format}

   begin {FormatPrintf}

   state := st_text;
   expected := 0;
   offset := 0;

   number_set := ['0' .. '9'];
   length_set := ['h', 'l', 'j', 't', 'z', 'L']; 
   flag_set := ['#', '0', '-', '+', ' '];
   format_set := ['%', 'b', 'c', 's', 'd', 'i', 'o', 'x', 'X', 'u', 
      'f', 'F', 'e', 'E', 'a', 'A', 'g', 'G', 'n', 'p', 'P'];

   for i := 1 to s^.length do begin
      c := s^.str[i];
      case state of
         st_text:
            if c = '%' then begin
               state := st_flag;
               offset := i;
               has_length := default;
               has_flag := false;
               has_width := false;
               has_precision := false;
               end;

         st_flag: { flags* width? precision? length? format }
            if c in flag_set then begin
               state := st_flag;
               has_flag := true;
               end
            else if c in number_set then begin
               state := st_width;
               has_width := true;
               end
            else if c = '*' then begin
               { * for the width }
               has_width := true;
               expect_int;
               state := st_precision;
               end
            else if c = '.' then state := st_precision_dot
            else if c in length_set then do_length(c)
            else do_printf_format;

         st_width: { width? precision? length? format }
            if c in number_set then state := st_width
            else if c = '.' then state := st_precision_dot
            else if c in length_set then do_length(c)
            else do_printf_format;

         st_precision: { (. precision)? length? format }
            if c = '.' then state := st_precision_dot
            else if c in length_set then do_length(c)
            else do_printf_format;


         st_precision_dot: begin { * | [0-9]+ }
            has_precision := true;
            if c = '*' then begin
               expect_int;
               state := st_length;
               end
            else if c in number_set then state := st_precision_number
            else state := st_error;
            end;

         st_precision_number: { [0-9]*  length? format }
            if c in number_set then state := st_precision_number
            else if c in length_set then do_length(c)
            else do_printf_format;  

         st_length: { length? format }
            if c in length_set then do_length(c)
            else do_printf_format;

         st_length_h: { h? format }
            if c = 'h' then begin
               has_length := hh;
               state := st_format;
               if not feature_hh then
                  Warning(@'hh modifier is not currently supported');
               end
            else do_printf_format;

         st_length_l: { l? format}
            if c = 'l' then begin
               has_length := ll;
               state := st_format;
               if not feature_ll then
                  Warning(@'ll modifier is not currently supported');
               end
            else do_printf_format;

         st_format: do_printf_format;

         st_error: { error }
            goto 1;

         end; { case  }
      end; { for i }

   if state <> st_text then
      Warning(@'incomplete format specifier');

   if args <> nil then begin
      offset := 0;
      WarningExtraArgs(expected);
      end;
1:

   end; {FormatPrintf}





   function get_format_string(pos: integer): longstringPtr;
   { get the format string from the pos'th argument. }
   var
      tk: tokenPtr;

   begin {get_format_string}
   get_format_string := nil;

   while (args <> nil) and (pos > 1) do begin
      args := args^.next;
      pos := pos - 1;
      end; {while}

   if (pos = 1) and (args <> nil) then begin
      tk := args^.tk;
      args := args^.next;

      if (tk <> nil) and (tk^.token.kind = stringconst) then
         get_format_string := tk^.token.sval
      else
         {Error(125) - disabled for now};
      end; {if}
      { no format string -> Error(85) }
   end; {get_format_string}



begin {FormatCheck}

head := args;
error_count := 0;
offset := 0;

case fmt of
   fmt_printf1, fmt_scanf1:
      s := get_format_string(1);

   fmt_printf2, fmt_scanf2:
      s := get_format_string(2);

   fmt_printf3:
      s := get_format_string(3);

   otherwise: s := nil;
   end; {case}

if (s <> nil) then case fmt of
   fmt_printf1, fmt_printf2, fmt_printf3:
      FormatPrintf;

   fmt_scanf1, fmt_scanf2:
      FormatScanf;
   end; {case}

{ clean up linked list }
while head <> nil do begin
   args := head^.next;
   dispose(head);
   head := args;
   end;

{handle pauses}
if ((error_count <> 0) and wait) or KeyPress then begin
   DrawHourglass;
   while not KeyPress do {nothing};               
   ClearHourglass;
   end; {if}
end; {FormatCheck}

end.
