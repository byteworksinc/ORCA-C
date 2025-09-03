{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  ORCA Code Generator Interface                                }
{                                                               }
{  This unit serves as the glue code attaching a compiler       }
{  to the code generator.  It provides subroutines in a         }
{  format that is convenient for the compiler during            }
{  semantic analysis, and produces intermediate code records    }
{  as output.  These intermediate code records are then         }
{  passed on to the code generator for optimization and         }
{  native code generation.                                      }
{                                                               }
{ copy 'cgi.comments'}
{---------------------------------------------------------------}

unit CodeGeneratorInterface;

interface

{$segment 'CG'}

{$LibPrefix '0/obj/'}

uses CCommon;

const
                                        {Error interface: these constants map  }
                                        {code generator error numbers into the }
                                        {numbers used by the compiler's Error  }
                                        {subroutine.                           }
                                        {--------------------------------------}
   cge1                 =       57;     {compiler error}
   cge2                 =       58;     {implementation restriction: too many local labels}
   cge3                 =       60;     {implementation restriction: string space exhausted}
   cge4                 =      188;     {local variable out of range for DP addressing}
   
                                        {65816 native code generation}
                                        {----------------------------}
                                        {instruction modifier flags}
   shift8                 =      1;     {shift operand right 8 bits}
   shift16                =      2;     {shift operand right 16 bits}
   toolCall               =      4;     {generate a tool call}
   stringReference        =      8;     {generate a string reference}
   isPrivate              =     32;     {is the label private?}
   constantOpnd           =     64;     {the absolute operand is a constant}
   localLab               =    128;     {the operand is a local lab}
   forFlags               =    256;     {instruction used for effect on flags only}
   subtract1              =    512;     {subtract 1 from address operand}
   shiftLeft8             =   1024;     {shift operand left 8 bits}
   labelUsedOnce          =   2048;     {only one branch targets this label}

   m_adc_abs              =    $6D;     {op code #s for 65816 instructions}
   m_adc_dir              =    $65;
   m_adc_imm              =    $69;
   m_adc_s                =    $63;
   m_adc_indl             =    $67;
   m_adc_indly            =    $77;
   m_and_abs              =    $2D;
   m_and_dir              =    $25;
   m_and_imm              =    $29;
   m_and_s                =    $23;
   m_and_indl             =    $27;
   m_and_indly            =    $37;
   m_asl_a                =    $0A;
   m_bcc                  =    $90;
   m_bcs                  =    $B0;
   m_beq                  =    $F0;
   m_bit_imm              =    $89;
   m_bmi                  =    $30;
   m_bne                  =    $D0;
   m_bpl                  =    $10;
   m_bra                  =    $80;
   m_brl                  =    $82;
   m_bvc                  =    $50;
   m_bvs                  =    $70;
   m_clc                  =    $18;
   m_cmp_abs              =    $CD;
   m_cmp_dir              =    $C5;
   m_cmp_dirX             =    $D5;
   m_cmp_imm              =    $C9;
   m_cmp_long             =    $CF;
   m_cmp_s                =    $C3;
   m_cmp_indl             =    $C7;
   m_cmp_indly            =    $D7;
   m_cop                  =    $02;
   m_cpx_abs              =    236;
   m_cpx_dir              =    228;
   m_cpx_imm              =    224;
   m_cpy_imm              =    $C0;
   m_dea                  =     58;
   m_dec_abs              =    206;
   m_dec_absX             =    $DE;
   m_dec_dir              =    198;
   m_dec_dirX             =    214;
   m_dex                  =    202;
   m_dey                  =    136;
   m_eor_abs              =     77;
   m_eor_dir              =     69;
   m_eor_imm              =     73;
   m_eor_s                =     67;
   m_eor_indl             =    $47;
   m_eor_indly             =   $57;
   m_ina                  =     26;
   m_inc_abs              =    238;
   m_inc_absX             =    $FE;
   m_inc_dir              =    230;
   m_inc_dirX             =    246;
   m_inx                  =    232;
   m_iny                  =    200;
   m_jml                  =     92;
   m_jmp_indX             =    $7C;
   m_jsl                  =     34;
   m_lda_abs              =    173;
   m_lda_absx             =    189;
   m_lda_dir              =    165;
   m_lda_dirx             =    181;
   m_lda_imm              =    169;
   m_lda_indl             =    167;
   m_lda_indly            =    183;
   m_lda_long             =    175;
   m_lda_longx            =    191;
   m_lda_s                =    163;
   m_ldx_abs              =    174;
   m_ldx_dir              =    166;
   m_ldx_imm              =    162;
   m_ldy_abs              =    172;
   m_ldy_absX             =    188;
   m_ldy_dir              =    164;
   m_ldy_dirX             =    180;
   m_ldy_imm              =    160;
   m_lsr_a                =     74;
   m_mvn                  =     84;
   m_ora_abs              =     13;
   m_ora_dir              =      5;
   m_ora_dirX             =     21;
   m_ora_imm              =      9;
   m_ora_long             =     15;
   m_ora_longX            =     31;
   m_ora_s                =      3;
   m_ora_indl             =    $07;
   m_ora_indly            =    $17;
   m_pea                  =    244;
   m_pei_dir              =    212;
   m_pha                  =     72;
   m_phb                  =    139;
   m_phd                  =     11;
   m_phx                  =    218;
   m_phy                  =     90;
   m_php                  =      8;
   m_pla                  =    104;
   m_plb                  =    171;
   m_pld                  =     43;
   m_plx                  =    250;
   m_ply                  =    122;
   m_plp                  =     40;
   m_rep                  =    194;
   m_rol_a                =    $2A;
   m_ror_a                =    $6A;
   m_rtl                  =    107;
   m_rts                  =     96;
   m_sbc_abs              =    237;
   m_sbc_dir              =    229;
   m_sbc_imm              =    233;
   m_sbc_s                =    227;
   m_sbc_indl             =    $E7;
   m_sbc_indly            =    $F7;
   m_sec                  =     56;
   m_sep                  =    226;
   m_sta_abs              =    141;
   m_sta_absX             =    157;
   m_sta_dir              =    133;
   m_sta_dirX             =    149;
   m_sta_indl             =    135;
   m_sta_indlY            =    151;
   m_sta_long             =    143;
   m_sta_longX            =    159;
   m_sta_s                =    131;
   m_stx_dir              =    134;
   m_stx_abs              =    142;
   m_sty_abs              =    140;
   m_sty_dir              =    132;
   m_sty_dirX             =    148;
   m_stz_abs              =    156;
   m_stz_absX             =    158;
   m_stz_dir              =    100;
   m_stz_dirX             =    116;
   m_tax                  =    170;
   m_tay                  =    168;
   m_tcd                  =     91;
   m_tcs                  =     27;
   m_tdc                  =    123;
   m_tsx                  =    $BA;
   m_txa                  =    138;
   m_txs                  =    $9A;
   m_txy                  =    155;
   m_tya                  =    152;
   m_tyx                  =    187;
   m_tsb_dir              =    $04;
   m_tsb_abs              =    $0C;
   m_tsc                  =     59;
   m_xba                  =    $EB;

   d_lab                  =    256;
   d_end                  =    257;
   d_bmov                 =    258;
   d_add                  =    259;
   d_pin                  =    260;
   d_wrd                  =    261;
   d_sym                  =    262;
   d_cns                  =    263;
   d_dcb                  =    264;
   d_dcw                  =    265;
   d_dcl                  =    266;

   max_opcode             =    266;
   
   asmFlag                =  $8000;     {or'd with opcode to indicate asm code}

                                        {Code Generation}
                                        {---------------}
   maxCBuff     =       191;            {length of constant buffer}
                                        {Note: maxlabel is also defined in CCommon.pas}
                                        {Note: maxlabel is also defined in CGC.asm}
   maxLabel     =       3275;           {max # of internal labels}
   maxLocalLabel =      512;            {max # local variables}
   maxString    =       32760;          {max # chars in string space}

                                        {size of internal types}
                                        {----------------------}
   cgByteSize           =       1;
   cgWordSize           =       2;
   cgLongSize           =       4;
   cgQuadSize           =       8;
   cgPointerSize        =       4;
   cgRealSize           =       4;
   cgDoubleSize         =       8;
   cgCompSize           =       8;
   cgExtendedSize       =      10;

type
  segNameType = packed array[1..10] of char; {segment name}
  stringSpaceType = packed array[1..maxstring] of char; {string space}

                                        {p code}
                                        {------}
   pcodes =                             {pcode names}
      (pc_adi,pc_adr,pc_and,pc_dvi,pc_dvr,pc_cnn,pc_cnv,pc_ior,pc_mod,pc_mpi,
       pc_mpr,pc_ngi,pc_ngr,pc_not,pc_sbi,pc_sbr,pc_sto,pc_dec,dc_loc,pc_ent,
       pc_fjp,pc_inc,pc_ind,pc_ixa,pc_lao,pc_lca,pc_ldo,pc_mov,pc_ret,pc_sro,
       pc_xjp,pc_cup,pc_equ,pc_geq,pc_grt,pc_lda,pc_ldc,pc_ldl,pc_leq,pc_les,
       pc_lil,pc_lld,pc_lli,pc_lod,pc_neq,pc_str,pc_ujp,pc_add,pc_lnm,pc_nam,
       pc_cui,pc_lad,pc_tjp,dc_lab,pc_usr,pc_umi,pc_udi,
       pc_uim,dc_enp,pc_stk,dc_glb,dc_dst,dc_str,pc_cop,pc_cpo,pc_tl1,
       dc_pin,pc_shl,pc_shr,pc_bnd,pc_bor,pc_bxr,pc_bnt,pc_bnl,pc_mpl,pc_dvl,
       pc_mdl,pc_sll,pc_slr,pc_bal,pc_ngl,pc_adl,pc_sbl,pc_blr,pc_blx,
       dc_sym,pc_lnd,pc_lor,pc_vsr,pc_uml,pc_udl,pc_ulm,pc_pop,pc_gil,
       pc_gli,pc_gdl,pc_gld,pc_cpi,pc_tri,pc_lbu,pc_lbf,pc_sbf,pc_cbf,dc_cns,
       dc_prm,pc_nat,pc_bno,pc_nop,pc_psh,pc_ili,pc_iil,pc_ild,pc_idl,
       pc_bqr,pc_bqx,pc_baq,pc_bnq,pc_ngq,pc_adq,pc_sbq,pc_mpq,pc_umq,pc_dvq,
       pc_udq,pc_mdq,pc_uqm,pc_slq,pc_sqr,pc_wsr,pc_rbo,pc_fix,pc_rev,pc_ckp,
       pc_ckn,pc_sxi,pc_sxl,pc_sxq,pc_zxi,pc_zxl,pc_zxq,pc_zni,pc_znl,pc_znq);

                                        {intermediate code}
                                        {-----------------}
   icptr = ^intermediate_code;
   intermediate_code = record           {intermediate code record}
      opcode: pcodes;                   {operation code}
      q,r,s: integer;                   {operands}
      lab: stringPtr;                   {named label pointer}
      next: icptr;                      {ptr to next statement}
      left, right: icptr;		{leaves for trees}
      parents: integer;			{number of parents}
      case optype: baseTypeEnum of
         cgByte,
         cgUByte,
         cgWord,
         cgUWord        : (opnd: longint; llab,slab: integer);
         cgLong,
         cgULong        : (lval: longint);
         cgQuad,
         cgUQuad        : (qval: longlong);
         cgReal,
         cgDouble,
         cgComp,
         cgExtended     : (rval: extended);
         cgString       : (
            case isByteSeq: boolean of
               false    : (str: longStringPtr);
               true     : (data: ptr; len: longint);
            );
         cgVoid,
         ccPointer      : (pval: longint; pstr: longStringPtr);
      end;

   codeRef = icptr;                     {reference to a code location}

					{basic blocks}
                                        {------------}
   iclist = ^iclistRecord;		{used to form lists of records}
   iclistRecord = record
      next: iclist;
      op: icptr;
      end;

   blockPtr = ^block;			{basic block edges}
   blockListPtr = ^blockListRecord;	{lists of blocks}
   block = record
      last, next: blockPtr;		{for doubly linked list of blocks}
      dfn: integer;			{depth first order index}
      visited: boolean;			{has this node been visited?}
      code: icptr;			{code in the block}
      c_in: iclist;			{list of reaching definitions}
      c_out: iclist;			{valid definitions on exit}
      c_gen: iclist;			{generated definitions}
      dom: blockListPtr;		{dominators of this block}
      end;

   blockListRecord = record		{lists of blocks}
      next, last: blockListPtr;
      dfn: integer;
      end;

                                        {65816 native code generation}
                                        {----------------------------}
   addressingMode = (implied,immediate, {65816 addressing modes}
      longabs,longrelative,relative,absolute,direct,gnrLabel,gnrSpace,
      gnrConstant,genaddress,special,longabsolute);

var
                                        {current instruction info}
                                        {------------------------}
   isJSL: boolean;                      {is the current opcode a jsl?}

                                        {65816 native code generation}
                                        {----------------------------}
   longA,longI: boolean;                {register sizes}

                                        {variables used to control the }
                                        {quality or characteristics of }
                                        {code                          }
                                        {------------------------------}
   checkNullPointers: boolean;          {check for null pointer dereferences?}
   checkStack: boolean;                 {check stack for stack errors?}
   cLineOptimize: boolean;		{+o flag set?}
   code: icptr;                         {current intermediate code record}
   codeGeneration: boolean;             {is code generation on?}
   commonSubexpression: boolean;        {do common subexpression removal?}
   currentSegment,defaultSegment: segNameType; {current & default seg names}
   segmentKind: integer;                {kind field of segment (ored with start/data)}
   defaultSegmentKind: integer;         {default segment kind}
   debugFlag: boolean;                  {generate debugger calls?}
   debugStrFlag: boolean;               {gsbug/niftylist debug names?}
   dataBank: boolean;                   {save, restore data bank?}
   fastMath: boolean;                   {do FP math opts that break IEEE rules?}
   floatCard: integer;                  {0 -> SANE; 1 -> FPE}
   floatSlot: integer;                  {FPE slot}
   loopOptimizations: boolean;          {do loop optimizations?}
   noroot: boolean;                     {prevent creation of .root file?}
   npeephole: boolean;                  {do native code peephole optimizations?}
   peephole: boolean;                   {do peephole optimization?}
   profileFlag: boolean;                {generate profiling code?}
   rangeCheck: boolean;                 {generate range checks?}
   registers: boolean;                  {do register optimizations?}
   rtl: boolean;                        {return with an rtl?}
   saveStack: boolean;                  {save, restore caller's stack reg?}
   smallMemoryModel: boolean;           {is the small model in use?}
   stackSize: integer;                  {amount of stack space to reserve}
   strictVararg: boolean;               {repair stack around vararg calls?}
   stringsize: 0..maxstring;            {amount of string space left}
   stringspace: ^stringSpaceType;       {string table}
   symLength: integer;                  {length of debug symbol table}
   toolParms: boolean;                  {generate tool format parameters?}
   volatile: boolean;			{has a volatile qualifier been used?}
   hasVarargsCall: boolean;             {does current function call any varargs fns?}
   
                                        {desk accessory variables}
                                        {------------------------}
   isNewDeskAcc: boolean;               {is this a new desk acc?}
   isClassicDeskAcc: boolean;           {is this a classic desk acc?}
   isCDev: boolean;                     {is this a control panel device?}
   isNBA: boolean;			{is this a new button action?}
   isXCMD: boolean;			{is this an XCMD?}
   openName,closeName,actionName,       {names of the required procedures}
      initName: stringPtr;
   refreshPeriod: integer;              {refresh period}
   eventMask: integer;                  {event mask}
   menuLine: pString;                   {name in menu bar}

					{DAG construction}
                                        {----------------}
   DAGhead: icPtr;			{1st ic in DAG list}
   DAGblocks: blockPtr;			{list of basic blocks}

{---------------------------------------------------------------}

procedure CodeGenFini;

{ terminal processing                                           }


procedure CodeGenInit (keepName: gsosOutStringPtr; keepFlag: integer;
                       partial: boolean);

{ code generator initialization                                 }
{                                                               }
{ parameters:                                                   }
{       keepName - name of the output file                      }
{       keepFlag - keep status:                                 }
{               0 - don't keep the output                       }
{               1 - create a new object module                  }
{               2 - a .root already exists                      }
{               3 - at least on .letter file exists             }
{       partial - is this a partial compile?                    }


procedure CodeGenScalarInit;

{ initialize codegen scalars                                    }


{procedure InitWriteCode;                    {debug}

{ initialize the intermediate code opcode table                 }


procedure Gen0 (fop: pcodes);

{ generate an implied operand instruction                       }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }


procedure Gen1 (fop: pcodes; fp2: integer);

{ generate an instruction with one numeric operand              }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp2 - operand                                           }


procedure Gen2 (fop: pcodes; fp1, fp2: integer);

{ generate an instruction with two numeric operands             }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
  

procedure Gen3 (fop: pcodes; fp1, fp2, fp3: integer);

{ generate an instruction with three numeric operands           }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       fp3 - third operand                                     }
  

procedure Gen0Name (fop: pcodes; name: stringPtr);

{ generate a p-code with a name                                 }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       name - named label                                      }


procedure Gen1Name (fop: pcodes; fp1: integer; name: stringPtr);

{ generate a one operand p-code with a name                     }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       name - named label                                      }


procedure Gen2Name (fop: pcodes; fp1, fp2: integer; name: stringPtr);

{ generate a two operand p-code with a name                     }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       name - named label                                      }


procedure Gen0tName (fop: pcodes; tp: baseTypeEnum; name: stringPtr);

{ generate a typed zero operand p-code with a name              }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       tp - base type                                          }
{       name - named label                                      }


procedure Gen1tName (fop: pcodes; fp1: integer; tp: baseTypeEnum;
                     name: stringPtr);

{ generate a typed one operand p-code with a name               }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       tp - base type                                          }
{       name - named label                                      }


procedure Gen2tName (fop: pcodes; fp1, fp2: integer; tp: baseTypeEnum;
                     name: stringPtr);

{ generate a typed two operand p-code with a name               }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       tp - base type                                          }
{       name - named label                                      }


procedure Gen0t (fop: pcodes; tp: baseTypeEnum);

{ generate a typed implied operand instruction                  }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       tp - base type                                          }

                                   
procedure Gen1t (fop: pcodes; fp1: integer; tp: baseTypeEnum);

{ generate a typed instruction with two numeric operands        }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - operand                                           }
{       tp - base type                                          }


procedure Gen2t (fop: pcodes; fp1, fp2: integer; tp: baseTypeEnum);

{ generate a typed instruction with two numeric operands        }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       tp - base type                                          }


procedure Gen3t (fop: pcodes; fp1, fp2, fp3: integer; tp: baseTypeEnum);

{ generate a typed instruction with three numeric operands      }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       fp3 - second operand                                    }
{       tp - base type                                          }


procedure GenPS (fop: pcodes; str: stringPtr);

{ generate an instruction that uses a p-string operand          }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       str - pointer to string                                 }


procedure GenS (fop: pcodes; str: longstringPtr);

{ generate an instruction that uses a string operand            }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       str - pointer to string                                 }


procedure GenBS (fop: pcodes; data: ptr; len: longint);

{ generate an instruction that uses a byte sequence operand     }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       data - pointer to data                                  }
{       data - length of data                                   }


procedure GenL1 (fop: pcodes; lval: longint; fp1: integer);

{ generate an instruction that uses a longint and an int        }
{                                                               }
{ parameters:                                                   }
{       lval - longint parameter                                }
{       fp1 - integer parameter                                 }


procedure GenQ1 (fop: pcodes; qval: longlong; fp1: integer);

{ generate an instruction that uses a longlong and an int       }
{                                                               }
{ parameters:                                                   }
{       qval - longlong parameter                               }
{       fp1 - integer parameter                                 }


procedure GenR1t (fop: pcodes; rval: extended; fp1: integer; tp: baseTypeEnum);

{ generate an instruction that uses a real and an int           }
{                                                               }
{ parameters:                                                   }
{       rval - real parameter                                   }
{       fp1 - integer parameter                                 }
{       tp - base type                                          }


procedure GenLdcLong (lval: longint);

{ load a long constant                                          }
{                                                               }
{ parameters:                                                   }
{       lval - value to load                                    }


procedure GenLdcQuad (qval: longlong);

{ load a long long constant                                     }
{                                                               }
{ parameters:                                                   }
{       qval - value to load                                    }


procedure GenLdcReal (rval: extended);

{ load a real constant                                          }
{                                                               }
{ parameters:                                                   }
{       rval - value to load                                    }


procedure GenTool (fop: pcodes; fp1, fp2: integer; dispatcher: longint);

{ generate a tool call                                          }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - tool number                                       }
{       fp2 - return size                                       }
{       dispatcher - tool entry point                           }


function GetCodeLocation: codeRef;

{ Get a reference to the current location in the generated      }
{ code, suitable to be passed to RemoveCode.                    }


procedure InsertCode (theCode: codeRef);

{ Insert a section of already-generated code that was           }
{ previously removed with RemoveCode.                           }
{                                                               }
{ parameters:                                                   }
{       theCode - code removed (returned from RemoveCode)       }


{procedure PrintBlocks (tag: stringPtr; bp: blockPtr); {debug}

{ print a series of basic blocks				}
{								}
{ parameters:							}
{    tag - label for lines					}
{    bp - first block to print					}


{procedure PrintDAG (tag: stringPtr; code: icptr); {debug}

{ print a DAG                                                   }
{                                                               }
{ parameters:                                                   }
{    tag - label for lines                                      }
{    code - first node in DAG                                   }


function RemoveCode (start: codeRef): codeRef;

{ Remove a section of already-generated code, from immediately  }
{ after start up to the latest code generated.  Returns the     }
{ code removed, so it may be re-inserted later.                 }
{                                                               }
{ parameters:                                                   }
{       start - location to start removing from                 }
{                                                               }
{ Note: start must be a top-level pcode (not a subexpression).  }
{ Note: The region removed must not include a dc_enp.           }


function TypeSize (tp: baseTypeEnum): integer;

{ Find the size, in bytes, of a variable			}
{								}
{ parameters:							}
{    tp - base type of the variable				}


{procedure WriteCode (code: icptr);      {debug}

{ print an intermediate code instruction                        }
{                                                               }
{ Parameters:                                                   }
{    code - intermediate code instruction to write              }


procedure LimitPrecision (var rval: extended; tp: baseTypeEnum);

{ limit the precision and range of a real value to the type.    }
{                                                               }
{ parameters:                                                   }
{       rval - real value                                       }
{       tp - type to limit precision to                         }

{------------------------------------------------------------------------------}

implementation

{var
   opt: array[pcodes] of packed array[1..3] of char; {debug}

{Imported from CGC.pas:}

function Calloc (bytes: integer): ptr; extern;

{ Allocate memory from a pool and clear it.                     }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }
{                                                               }
{ Globals:                                                      }
{       useGlobalPool - should the memory come from the global  }
{               (or local) pool                                 }


procedure Error (err: integer); extern; {in scanner.pas}

{ flag an error                                                 }
{                                                               }
{ err - error number                                            }


function Malloc (bytes: integer): ptr; extern;

{ Allocate memory from a pool.                                  }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }
{                                                               }
{ Globals:                                                      }
{       useGlobalPool - should the memory come from the global  }
{               (or local) pool                                 }


procedure InitLabels; extern;

{ initialize the labels array for a procedure                   }


{Imported from ObjOut.pas:}

procedure CloseObj; extern;

{ close the current obj file                                    }

{Imported from Native.pas:}

procedure InitFile (keepName: gsosOutStringPtr; keepFlag: integer; partial: boolean);
extern;

{ Set up the object file					}
{                                                               }
{ parameters:							}
{    keepName - name of the output file				}
{    keepFlag - keep status:					}
{       0 - don't keep the output				}
{       1 - create a new object module				}
{       2 - a .root already exists				}
{       3 - at least on .letter file exists			}
{    partial - is this a partial compile?			}
          

{Imported from DAG.pas:}

procedure DAG (code: icptr); extern;

{ place an op code in a DAG or tree				}
{                                                               }
{ parameters:                                                   }
{       code - opcode						}

{------------------------------------------------------------------------------}


{ copy 'cgi.debug'}                     {debug}

procedure CodeGenInit {keepName: gsosOutStringPtr; keepFlag: integer;
                       partial: boolean};

{ code generator initialization                                 }
{                                                               }
{ parameters:                                                   }
{       keepName - name of the output file                      }
{       keepFlag - keep status:                                 }
{               0 - don't keep the output                       }
{               1 - create a new object module                  }
{               2 - a .root already exists                      }
{               3 - at least on .letter file exists             }
{       partial - is this a partial compile?                    }

begin {CodeGenInit}
{initialize the debug tables		{debug}
{InitWriteCode;				{debug}

{initialize the label table}
InitLabels;

codeGeneration := true;                 {turn on code generation}

{set up the DAG variables}
DAGhead := nil;				{no ics in DAG list}

InitFile(keepName, keepFlag, partial);	{open the interface file}
end; {CodeGenInit}


procedure CodeGenFini;

{ terminal processing                                           }

begin {CodeGenFini}
CloseObj;                               {close the open object file}
end; {CodeGenFini}


procedure CodeGenScalarInit;

{ initialize codegen scalars                                    }

begin {CodeGenScalarInit}
isJSL := false;                         {the current opcode is not a jsl}
isNewDeskAcc := false;                  {assume a normal program}
isCDev := false;
isClassicDeskAcc := false;
isNBA := false;
isXCMD := false;
codeGeneration := false;                {code generation is not turned on yet}
currentSegment := '          ';         {start with the blank segment}
defaultSegment := '          ';
segmentKind := 0;                       {default to static code segments}
defaultSegmentKind := 0;
smallMemoryModel := true;               {small memory model}
dataBank := false;                      {don't save/restore data bank}
strictVararg :=                         {save/restore caller's stack around vararg}
   (not cLineOptimize) or strictMode;
saveStack := not cLineOptimize;         {save/restore caller's stack reg}
checkStack := false;                    {don't check stack for stack errors}
stackSize := 0;				{default to the launcher's stack size}
toolParms := false;                     {generate tool format parameters?}
noroot := false;                        {create a .root segment}
rtl := false;                           {return with a ~QUIT}
floatCard := 0;                         {use SANE}
floatSlot := 0;                         {default to slot 0}
stringSize := 0;			{no strings, yet}

rangeCheck := false;                    {don't generate range checks}
profileFlag := false;                   {don't generate profiling code}
debugFlag := false;                     {don't generate debug code}
debugStrFlag := false;                  {don't generate gsbug debug strings}
traceBack := false;                     {don't generate traceback code}
checkNullPointers := false;             {don't check null pointers}
volatile := false;			{no volatile qualifiers found}

registers := cLineOptimize;             {don't do register optimizations}
peepHole := cLineOptimize;              {not doing peephole optimization (yet)}
npeepHole := cLineOptimize;
fastMath := cLineOptimize;
commonSubexpression := cLineOptimize;	{not doing common subexpression elimination}
loopOptimizations := cLineOptimize;	{not doing loop optimizations, yet}

{allocate string space}
new(stringspace);

{allocate the initial p-code}
code := pointer(Calloc(sizeof(intermediate_code)));
code^.optype := cgWord;
end; {CodeGenScalarInit}


procedure Gen0 {fop: pcodes};

{ generate an implied operand instruction                       }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }

begin {Gen0}
if codeGeneration then begin

   {generate the intermediate code instruction}
   code^.opcode := fop;
{  if printSymbols then                 {debug}
{     WriteCode(code);                  {debug}
   DAG(code);				{generate the code}

   {initialize volatile variables for next intermediate code}
   code := pointer(Calloc(sizeof(intermediate_code)));
   {code^.lab := nil;}
   code^.optype := cgWord;
   end; {if}
end; {Gen0}


procedure Gen1 {fop: pcodes; fp2: integer};

{ generate an instruction with one numeric operand              }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp2 - operand                                           }

begin {Gen1}
if codeGeneration then begin
   if fop = pc_ret then
      code^.optype := cgVoid;
   code^.q := fp2;
   Gen0(fop);
   end; {if}
end; {Gen1}

 
procedure Gen2 {fop: pcodes; fp1, fp2: integer};

{ generate an instruction with two numeric operands             }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }

label 1;

var
   lcode: icptr;                        {local copy of code}

begin {Gen2}
if codeGeneration then begin
   lcode := code;
   case fop of

      pc_lnm,pc_tl1,pc_lda,dc_loc,pc_mov: begin
         lcode^.r := fp1;
         lcode^.q := fp2;
         end;

      pc_cnn,pc_cnv:
         if (fp1 = fp2)
            and not (baseTypeEnum(fp2) in [cgReal,cgDouble,cgComp]) then
            goto 1
         else if (baseTypeEnum(fp1) in [cgReal,cgDouble,cgComp,cgExtended])
            and (baseTypeEnum(fp2) = cgExtended) then
            goto 1
         else if (baseTypeEnum(fp1) in [cgUByte,cgWord,cgUWord])
            and (baseTypeEnum(fp2) in [cgWord,cgUWord]) then
            goto 1
         else if (baseTypeEnum(fp1) in [cgUByte])
            and (baseTypeEnum(fp2) in [cgByte,cgUByte]) then
            goto 1
         else if (baseTypeEnum(fp1) = cgByte)
            and (baseTypeEnum(fp2) = cgUByte) then
            lcode^.q := (ord(cgWord) << 4) | ord(cgUByte)
         else
            lcode^.q := (fp1 << 4) | fp2;

      otherwise:
         Error(cge1);
      end; {case}

   Gen0(fop);
   end; {if}
1:
end; {Gen2}

 
procedure Gen3 {fop: pcodes; fp1, fp2, fp3: integer};

{ generate an instruction with three numeric operands           }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       fp3 - third operand                                     }
  
var
   lcode: icptr;                        {local copy of code}

begin {Gen3}
if codeGeneration then begin
   lcode := code;
   lcode^.s := fp1;
   lcode^.q := fp2;
   lcode^.r := fp3;
   Gen0(fop);
   end; {if}
end; {Gen3}

 
procedure Gen0Name {fop: pcodes; name: stringPtr};

{ generate a p-code with a name                                 }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       name - named label                                      }

begin {Gen0Name}
if codeGeneration then begin
   code^.lab := name;
   Gen0(fop);
   end; {if}
end; {Gen0Name}
 

procedure Gen1Name {fop: pcodes; fp1: integer; name: stringPtr};

{ generate a one operand p-code with a name                     }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       name - named label                                      }

var
   lcode: icptr;                        {local copy of code}

begin {Gen1Name}
if codeGeneration then begin
   lcode := code;
   lcode^.q := fp1;
   lcode^.lab := name;
   Gen0(fop);
   end; {if}
end; {Gen1Name}
 

procedure Gen2Name {fop: pcodes; fp1, fp2: integer; name: stringPtr};

{ generate a two operand p-code with a name                     }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       name - named label                                      }

var
   lcode: icptr;                        {local copy of code}

begin {Gen2Name}
if codeGeneration then begin
   lcode := code;
   lcode^.q := fp2;
   lcode^.r := fp1;
   lcode^.lab := name;
   Gen0(fop);
   end; {if}
end; {Gen2Name}


procedure Gen0tName {fop: pcodes; tp: baseTypeEnum; name: stringPtr};

{ generate a typed zero operand p-code with a name              }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       tp - base type                                          }
{       name - named label                                      }

var
   lcode: icptr;                        {local copy of code}

begin {Gen0tName}
if codeGeneration then begin
   lcode := code;
   lcode^.lab := name;
   lcode^.optype := tp;
   Gen0(fop);
   end; {if}
end; {Gen0tName}


procedure Gen1tName {fop: pcodes; fp1: integer; tp: baseTypeEnum;
                     name: stringPtr};

{ generate a typed one operand p-code with a name               }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       tp - base type                                          }
{       name - named label                                      }

var
   lcode: icptr;                        {local copy of code}

begin {Gen1tName}
if codeGeneration then begin
   lcode := code;
   lcode^.q := fp1;
   lcode^.lab := name;
   lcode^.optype := tp;
   Gen0(fop);
   end; {if}
end; {Gen1tName}


procedure Gen2tName {fop: pcodes; fp1, fp2: integer; tp: baseTypeEnum;
                     name: stringPtr};

{ generate a typed two operand p-code with a name               }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       tp - base type                                          }
{       name - named label                                      }

var
   lcode: icptr;                        {local copy of code}

begin {Gen2tName}
if codeGeneration then begin
   lcode := code;
   lcode^.r := fp1;
   lcode^.q := fp2;
   lcode^.lab := name;
   lcode^.optype := tp;
   Gen0(fop);
   end; {if}
end; {Gen2tName}
 

procedure Gen0t {fop: pcodes; tp: baseTypeEnum};

{ generate a typed implied operand instruction                  }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       tp - base type                                          }
                                   
begin {Gen0t}
if codeGeneration then begin
   code^.optype := tp;
   Gen0(fop);
   end; {if}
end; {Gen0t}
 

procedure Gen1t {fop: pcodes; fp1: integer; tp: baseTypeEnum};

{ generate a typed instruction with one numeric operand         }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - operand                                           }
{       tp - base type                                          }

var
   lcode: icptr;                        {local copy of code}

begin {Gen1t}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := tp;
   lcode^.q := fp1;
   Gen0(fop);
   end; {if}
end; {Gen1t}


procedure Gen2t {fop: pcodes; fp1, fp2: integer; tp: baseTypeEnum};

{ generate a typed instruction with two numeric operands        }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       tp - base type                                          }

var
   lcode: icptr;                        {local copy of code}

begin {Gen2t}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := tp;
   lcode^.r := fp1;
   lcode^.q := fp2;
   Gen0(fop);
   end; {if}
end; {Gen2t}


procedure Gen3t {fop: pcodes; fp1, fp2, fp3: integer; tp: baseTypeEnum};

{ generate a typed instruction with three numeric operands      }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - first operand                                     }
{       fp2 - second operand                                    }
{       fp3 - second operand                                    }
{       tp - base type                                          }

var
   lcode: icptr;                        {local copy of code}

begin {Gen3t}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := tp;
   lcode^.s := fp1;
   lcode^.q := fp2;
   lcode^.r := fp3;
   Gen0(fop);
   end; {if}
end; {Gen3t}


procedure GenPS {fop: pcodes; str: stringPtr};

{ generate an instruction that uses a p-string operand          }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       str - pointer to string                                 }

var
   lcode: icptr;                        {local copy of code}

begin {GenPS}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := cgString;
   lcode^.q := length(str^);
   lcode^.str := pointer(ord4(str)-1);
   Gen0(fop);
   end; {if}
end; {GenPS}


procedure GenS {fop: pcodes; str: longstringPtr};

{ generate an instruction that uses a string operand            }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       str - pointer to string                                 }

var
   lcode: icptr;                        {local copy of code}

begin {GenS}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := cgString;
   lcode^.q := str^.length;
   lcode^.str := str;
   Gen0(fop);
   end; {if}
end; {GenS}


procedure GenBS {fop: pcodes; data: ptr; len: longint};

{ generate an instruction that uses a byte sequence operand     }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       data - pointer to data                                  }
{       len - length of data                                    }

var
   lcode: icptr;                        {local copy of code}

begin {GenBS}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := cgString;
   lcode^.isByteSeq := true;
   lcode^.data := data;
   lcode^.len := len;
   Gen0(fop);
   end; {if}
end; {GenBS}


procedure GenL1 {fop: pcodes; lval: longint; fp1: integer};

{ generate an instruction that uses a longint and an int        }
{                                                               }
{ parameters:                                                   }
{       lval - longint parameter                                }
{       fp1 - integer parameter                                 }

var
   lcode: icptr;                        {local copy of code}

begin {GenL1}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := cgLong;
   lcode^.lval := lval;
   lcode^.q := fp1;
   Gen0(fop);
   end; {if}
end; {GenL1}


procedure GenQ1 {fop: pcodes; qval: longlong; fp1: integer};

{ generate an instruction that uses a longlong and an int       }
{                                                               }
{ parameters:                                                   }
{       qval - longlong parameter                               }
{       fp1 - integer parameter                                 }

var
   lcode: icptr;                        {local copy of code}

begin {GenQ1}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := cgQuad;
   lcode^.qval := qval;
   lcode^.q := fp1;
   Gen0(fop);
   end; {if}
end; {GenQ1}


procedure GenR1t {fop: pcodes; rval: extended; fp1: integer; tp: baseTypeEnum};

{ generate an instruction that uses a real and an int           }
{                                                               }
{ parameters:                                                   }
{       rval - real parameter                                   }
{       fp1 - integer parameter                                 }
{       tp - base type                                          }

var
   lcode: icptr;                        {local copy of code}

begin {GenR1t}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := tp;
   lcode^.rval := rval;
   lcode^.q := fp1;
   Gen0(fop);
   end; {if}
end; {GenR1t}


procedure GenLdcLong {lval: longint};

{ load a long constant                                          }
{                                                               }
{ parameters:                                                   }
{       lval - value to load                                    }

var
   lcode: icptr;                        {local copy of code}

begin {GenLdcLong}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := cgLong;
   lcode^.lval := lval;
   Gen0(pc_ldc);
   end; {if}
end; {GenLdcLong}


procedure GenLdcQuad {qval: longlong};

{ load a long long constant                                     }
{                                                               }
{ parameters:                                                   }
{       qval - value to load                                    }

var
   lcode: icptr;                        {local copy of code}

begin {GenLdcQuad}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := cgQuad;
   lcode^.qval := qval;
   Gen0(pc_ldc);
   end; {if}
end; {GenLdcQuad}


procedure GenTool {fop: pcodes; fp1, fp2: integer; dispatcher: longint};

{ generate a tool call                                          }
{                                                               }
{ parameters:                                                   }
{       fop - operation code                                    }
{       fp1 - tool number                                       }
{       fp2 - return size                                       }
{       dispatcher - tool entry point                           }

var
   lcode: icptr;                        {local copy of code}

begin {GenTool}
if codeGeneration then begin
   lcode := code;
   lcode^.q := fp1;
   lcode^.r := fp2;
   lcode^.optype := cgLong;
   lcode^.lval := dispatcher;
   Gen0(fop);
   end; {if}
end; {GenTool}


procedure GenLdcReal {rval: extended};

{ load a real constant                                          }
{                                                               }
{ parameters:                                                   }
{       rval - value to load                                    }

var
   lcode: icptr;                        {local copy of code}

begin {GenLdcReal}
if codeGeneration then begin
   lcode := code;
   lcode^.optype := cgReal;
   lcode^.rval := rval;
   Gen0(pc_ldc);
   end; {if}
end; {GenLdcReal}


function GetCodeLocation{: codeRef};

{ Get a reference to the current location in the generated      }
{ code, suitable to be passed to RemoveCode.                    }

begin {GetCodeLocation}
GetCodeLocation := DAGhead;
end {GetCodeLocation};


procedure InsertCode {theCode: codeRef};

{ Insert a section of already-generated code that was           }
{ previously removed with RemoveCode.                           }
{                                                               }
{ parameters:                                                   }
{       theCode - code removed (returned from RemoveCode)       }

var
   lcode: icptr;

begin {InsertCode}
if theCode <> nil then
   if codeGeneration then begin
      lcode := theCode;
{     PrintDAG(@'Inserting: ', lcode);  {debug}
      while lcode^.next <> nil do
         lcode := lcode^.next;
      lcode^.next := DAGhead;
      DAGhead := theCode;
      end; {if}
end; {InsertCode}


function RemoveCode {start: codeRef): codeRef};

{ Remove a section of already-generated code, from immediately  }
{ after start up to the latest code generated.  Returns the     }
{ code removed, so it may be re-inserted later.                 }
{                                                               }
{ parameters:                                                   }
{       start - location to start removing from                 }
{                                                               }
{ Note: start must be a top-level pcode (not a subexpression).  }
{ Note: The region removed must not include a dc_enp.           }

var
   lcode: icptr;

begin {RemoveCode}
if start = DAGhead then
   RemoveCode := nil
else begin
   RemoveCode := DAGhead;
   if codeGeneration then begin
      lcode := DAGhead;
      while (lcode^.next <> start) and (lcode^.next <> nil) do
         lcode := lcode^.next;
      if (lcode^.next = nil) and (start <> nil) then
         Error(cge1);
      lcode^.next := nil;
{     PrintDAG(@'Removing: ', DAGhead); {debug}
      DAGhead := start;
      end; {if}
   end; {else}
end; {RemoveCode}


function TypeSize {tp: baseTypeEnum): integer};

{ Find the size, in bytes, of a variable			}
{								}
{ parameters:							}
{    tp - base type of the variable				}

begin {TypeSize}
case tp of
   cgByte,cgUByte:   TypeSize := cgByteSize;
   cgWord,cgUWord:   TypeSize := cgWordSize;
   cgLong,cgULong:   TypeSize := cgLongSize;
   cgQuad,cgUQuad:   TypeSize := cgQuadSize;
   cgReal:           TypeSize := cgRealSize;
   cgDouble:         TypeSize := cgDoubleSize;
   cgComp:           TypeSize := cgCompSize;
   cgExtended:       TypeSize := cgExtendedSize;
   cgString:	     TypeSize := cgByteSize;
   cgVoid,ccPointer: TypeSize := cgLongSize;
   end; {case}
end; {TypeSize}


procedure LimitPrecision {rval: var extended; tp: baseTypeEnum};

{ limit the precision and range of a real value to the type.    }
{                                                               }
{ parameters:                                                   }
{       rval - real value                                       }
{       tp - type to limit precision to                         }

var
   d: double;
   s: real;
   c: comp;

begin {LimitPrecision}
case tp of
   cgReal:   begin
             s := rval;
             rval := s;
             end;
   cgDouble: begin
             d := rval;
             rval := d;
             end;
   cgComp:   if rval < 0.0 then begin
                {work around SANE comp conversion bug}
                c := -rval;
                rval := -c;
                end {if}
             else begin
                c := rval;
                rval := c;
                end; {else}
   cgExtended: ;
   end; {case}
end; {LimitPrecision}

end.
