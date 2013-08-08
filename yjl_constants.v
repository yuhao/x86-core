//---------------------------------------
//  Register
//---------------------------------------
`define EAX 3'd0
`define ECX 3'd1
`define EDX 3'd2
`define EBX 3'd3
`define ESP 3'd4
`define EBP 3'd5 
`define ESI 3'd6
`define EDI 3'd7

`define ES 3'd0
`define CS 3'd1
`define SS 3'd2
`define DS 3'd3
`define FS 3'd4
`define GS 3'd5

`define MMX0 3'd0
`define MMX1 3'd1
`define MMX2 3'd2
`define MMX3 3'd3
`define MMX4 3'd4
`define MMX5 3'd5
`define MMX6 3'd6
`define MMX7 3'd7


//--------------------------
//  Exception/Interrupt
//--------------------------
 
`define GE              1
`define PG              0
`define VECTOR_NUM      5:2
`define INT_OR_EXP      6


//-----------------------------------------
//  Word Length Related Constants
//----------------------------------------- 
`define BYTE 8
`define WORD 16
`define DOUBLE_WORD 32
`define QUAD_WORD 64
// icache cacheline
`define ICACHE_LINE_SIZE 4  // [3:0] --> 16 bytes



//---------------------------------------
//  BUS INTERFACE relevated PARAMETERS
//---------------------------------------
// scripts of BUS CONTROL 
`define DST0 0  // bus_cntl[`DST1:`DST0] ...
`define DST1 1
`define SRC0 2
`define SRC1 3
`define RW   4
`define WE0  5  // 1100 -> write high two bytes of 32bits of memory line
`define WE1  6
`define WE2  7
`define WE3  8
`define UNUSED 14:9
`define VALID 15 

// Address Marker
// if ffff_xxxx ===> DMA
`define DMA_ADDR 16'hffff

//  Request Priority
    // req[3:0] 
`define MEM     2'b11   //req[3]
`define DCACHE  2'b10    //req[2]
`define ICACHE  2'b01
`define IO      2'b00

//-------------------------------
// Control Signal
//-------------------------------
//`define PREFIX_CS_NUM   4

`define CS_NUM                  127:0  // total number of control signal
`define CS_REP                      0 
`define CS_OPERAND_SIZE_OVERRIDE    1
`define CS_SEGR_OVERRIDE            2
`define ADDRESS_MODE_RM             3  
`define ADDR_SEGR_OV_ALLOW          4 
`define DISP_OV_ALLOW               5
`define IMM_EXSIT                   6 
`define MOD_EXIST                   7   // decoding assistant
`define OP_EXT_EXIST                8
`define DISP_SEL0                   9   // literals  
`define DISP_SEL1                   10
`define DISP_SIZE0                  11
`define DISP_SIZE1                  12
`define DISP_SIZE2                  13
`define IMM_SEL0                    14
`define IMM_SEL1                    15
`define IMM_SIZE0                   16
`define IMM_SIZE1                   17
`define IMM_SIZE2                   18
`define DST_DATA_TYPE0              19  
`define DST_DATA_TYPE1              20
`define SRC_DATA_TYPE0              21
`define SRC_DATA_TYPE1              22
`define DST_GPR_SEL0                23     
`define DST_GPR_SEL1                24
`define DST_GPR_SEL2                25
`define WRITE_DST_GPR               26
`define READ_DST_GPR                27
`define SRC_GPR_SEL0                28    
`define SRC_GPR_SEL1                29
`define SRC_GPR_SEL2                30
`define WRITE_SRC_GPR               31 
`define READ_SRC_GPR                32
`define DST_SEGR_SEL0               33
`define DST_SEGR_SEL1               34
`define DST_SEGR_SEL2               35
`define WRITE_DST_SEGR              36
`define READ_DST_SEGR               37 
`define SRC_SEGR_SEL0               38
`define SRC_SEGR_SEL1               39
`define SRC_SEGR_SEL2               40
`define WRITE_SRC_SEGR              41
`define READ_SRC_SEGR               42
`define ADDR_SEGR_SEL0              43
`define ADDR_SEGR_SEL1              44
`define ADDR_SEGR_SEL2              45
`define READ_ADDR_SEGR              46
`define DST_MMX_SEL0                47
`define DST_MMX_SEL1                48
`define DST_MMX_SEL2                49
`define WRITE_DST_MMX               50
`define READ_DST_MMX                51
`define SRC_MMX_SEL0                52
`define SRC_MMX_SEL1                53
`define SRC_MMX_SEL2                54
`define READ_SRC_MMX                55
`define SREG_FLAG                   56 
`define DST_IS_INDEX                57      //
`define SRC_IS_INDEX                58      //
`define DATA_TYPE0                  59      //
`define DATA_TYPE1                  60      //
`define FORCE_DST_DATA				61
`define FORCE_SRC_DATA				62


`define SPLIT_INSTR                 64
`define SPLIT_UPC0                  65 
`define SPLIT_UPC1                  66  
`define SPLIT_UPC2                  67 
`define SPLIT_UPC3                  68 
`define SPLIT_UPC4                  69 
`define SPLIT_UPC5                  70 
`define SPLIT_UPC6                  71 
`define SPLIT_UPC7                  72 
`define PPMM_FLAG0                  73  // for push/pop/movs if  PPP_FLAG == 00, then normal situation
`define PPMM_FLAG1                  74  // for push/pop/movs if  PPP_FLAG == 00, then normal situation
`define MEM_WRITE                   75 // memory
`define MEM_READ                    76 
`define UNCOND_JMP                  77 
`define COND_JMP                    78 
`define EIP_LOAD                    79 
`define LOAD_CODE_SEGMENT           80 
`define TAKE_BR                     81 
`define SET_CC                      82 
`define LOAD_CC                     83 
`define ALU_OP0                     84 // may be changed due to ext_op
`define ALU_OP1                     85 
`define ALU_OP2                     86 
`define ALU_SRC1_SEL0               87 // ALU assistant
`define ALU_SRC1_SEL1               88 
`define ALU_SRC2_SEL0               89 
`define ALU_SRC2_SEL1               90 
`define ALU_SRC2_SEL2               91  
`define SHIFT_OP0                   92  
`define SHIFT_OP1                   93 
`define COUNT_SEL                   94
`define COUNT_LD                    95
`define RESULT_SEL                  96 
`define STD                         97 
`define CLD                         98 
`define HLT                         99 
`define CC_N                        100         // not used yet
`define CC_Z                        101
`define CC_P                        102
`define AUTO_INC_SEL2               103  // used to be ATOMIC
`define AUTO_INC_SEL0               104     //
`define AUTO_INC_SEL1               105     //

`define EIPMUX_SEL0                 106
`define EIPMUX_SEL1                 107
`define MEMMUX_SEL0                 108
`define MEMMUX_SEL1                 109
`define EFLAGSMUX_SEL               110

`define BASE_GPR_SEL0               111   // Output Registers
`define BASE_GPR_SEL1               112
`define BASE_GPR_SEL2               113
`define INDEX_GPR_SEL0              114
`define INDEX_GPR_SEL1              115
`define INDEX_GPR_SEL2              116
`define READ_BASE_GPR               117
`define READ_INDEX_GPR              118
`define SCALE0                      119
`define SCALE1                      120
`define CC_ZF_CHECK                 121
`define CC_ZF                       122
`define CC_CF_CHECK                 123
`define CC_CF                       124
`define EIPMUX_SEL2                 125
`define IDTR                        126
`define NEED_DF						127	


`define BASE_GPR_SEL `BASE_GPR_SEL2:`BASE_GPR_SEL0
`define INDEX_GPR_SEL `INDEX_GPR_SEL2:`INDEX_GPR_SEL0
`define ADDR_SEGR_SEL `ADDR_SEGR_SEL2:`ADDR_SEGR_SEL0
`define SCALE `SCALE1:`SCALE0
`define IMM_SEL `IMM_SEL1:`IMM_SEL0
`define DISP_SEL `DISP_SEL1:`DISP_SEL0
`define DST_SEGR_SEL `DST_SEGR_SEL2:`DST_SEGR_SEL0
`define DST_GPR_SEL `DST_GPR_SEL2:`DST_GPR_SEL0
`define SRC_SEGR_SEL `SRC_SEGR_SEL2:`SRC_SEGR_SEL0
`define DST_MMX_SEL `DST_MMX_SEL2:`DST_MMX_SEL0
`define SRC_MMX_SEL `SRC_MMX_SEL2:`SRC_MMX_SEL0
`define SPLIT_UPC `SPLIT_UPC7:`SPLIT_UPC0
`define ALU_SRC1_SEL `ALU_SRC1_SEL1:`ALU_SRC1_SEL0
`define ALU_SRC2_SEL `ALU_SRC2_SEL2:`ALU_SRC2_SEL0
`define ALU_OP `ALU_OP2:`ALU_OP0
`define SHIFT_OP `SHIFT_OP1:`SHIFT_OP0
`define SHIFT_AMOUNT `SHIFT_AMOUNT1:`SHIFT_AMOUNT0
`define DST_DATA_TYPE `DST_DATA_TYPE1:`DST_DATA_TYPE0
`define DATA_TYPE `DATA_TYPE1:`DATA_TYPE0
`define SRC_DATA_TYPE `SRC_DATA_TYPE1:`SRC_DATA_TYPE0
`define AUTO_INC_SEL  `AUTO_INC_SEL1:`AUTO_INC_SEL0
`define SRC_GPR_SEL   `SRC_GPR_SEL2:`SRC_GPR_SEL0
`define PPMM_FLAG   `PPMM_FLAG1:`PPMM_FLAG0
`define EIPMUX_SEL `EIPMUX_SEL1:`EIPMUX_SEL0
`define MEMMUX_SEL `MEMMUX_SEL1:`MEMMUX_SEL0










