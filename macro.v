`include "/misc/collaboration/382nGPS/382nG6/yjl/yjl_constants.v"
module Macro();
	`define CF 0
	`define PF 2
	`define AF 4
	`define ZF 6
	`define SF 7
	`define DF 10
	`define OF 11
	
	// used by RL
	`define DEST_GPR_SEL `DST_GPR_SEL 
	//`define SRC_GPR_SEL 5:3
	//`define BASE_GPR_SEL 8:6
	//`define INDEX_GPR_SEL 11:9
	`define DEST_SEGR_SEL `DST_SEGR_SEL 
	//`define SRC_SEGR_SEL 17:15
	`define SEGMENT_SEGR_SEL    `ADDR_SEGR_SEL 
	`define DEST_GPR_RD         `READ_DST_GPR 
	`define SRC_GPR_RD          `READ_SRC_GPR
	`define BASE_GPR_RD         `READ_BASE_GPR
	`define INDEX_GPR_RD        `READ_INDEX_GPR
	`define DEST_SEGR_RD        `READ_DST_SEGR
	`define SRC_SEGR_RD         `READ_SRC_SEGR
	`define SEGMENT_SEGR_RD     `READ_ADDR_SEGR
	`define DEST_GPR_TYPE       `DST_DATA_TYPE
	`define SRC_GPR_TYPE        `SRC_DATA_TYPE 
	`define DEST_MMX_SEL        `DST_MMX_SEL
	//`define SRC_MMX_SEL         `SRC_MMX_SEL
	`define DEST_MMX_RD         `READ_DST_MMX
	`define SRC_MMX_RD          `READ_SRC_MMX


	// used by AG
	
	//`define DISP_SEL 47:46
	//`define INDEX_SCALE_SEL 49:48
	//`define STACK_ADDR_SEL 50
	//`define MEM_RD_ADDR_SEL 51
	//`define MEM_ST_ADDR_SEL 52
	//`define MODRM_CHECK_LIMIT 53
	//`define STACK_CHECK_LIMIT 54
	//`define PPMM 56:55
	//
	//`define DEST_GPR_WT 57
	//`define SRC_GPR_WT 58
	//`define BASE_GPR_WT 59
	//`define INDEX_GPR_WT 60
	//`define DEST_SEGR_WT 61
	//`define SRC_SEGR_WT 62
	//`define SEGMENT_SEGR_WT 63


	
	//`define DISP_SEL 47:46
	`define INDEX_SCALE_SEL             `SCALE
	//`define STACK_ADDR_SEL              50            // not known exactly
	`define MEM_RD_ADDR_SEL 51
	`define MEM_ST_ADDR_SEL 52
	`define MODRM_CHECK_LIMIT 53
	`define STACK_CHECK_LIMIT 54
	`define PPMM                        `PPMM_FLAG
	
	`define DEST_GPR_WT                 `WRITE_DST_GPR
	`define SRC_GPR_WT                  `WRITE_SRC_GPR
	//`define BASE_GPR_WT 59              
	//`define INDEX_GPR_WT 60
	`define DEST_SEGR_WT                `WRITE_DST_SEGR
	`define SRC_SEGR_WT                 `WRITE_SRC_SEGR
    `define DEST_MMX_WT                 `WRITE_DST_MMX
	//`define SEGMENT_SEGR_WT 63
	

	
	// used by EX
	`define S1MUX_SEL                   `ALU_SRC1_SEL 
	`define S2MUX_SEL                   `ALU_SRC2_SEL
	//`define ALU_OP                      ` 
	`define SHF_OP                      `SHIFT_OP 
	`define RESULTMUX_SEL               `RESULT_SEL
	`define EFLAGS_SET_SEL 77
	`define NEW_DF 78
	
	// used WB

	
	
	
	
	/*
	
	// used by AG
	`define SR1_SEL 2:0
	`define SR2_SEL 5:3
	`define SR3_SEL 8:6
	`define SEGMENT_SEL 11:9
	`define SSEGR_SEL 14:12
	`define SMMX1_SEL 17:15
	`define SMMX2_SEL 20:18
	
	// used by WB
	`define DR1_SEL 23:21
	`define DR2_SEL 26:24
	`define DSEGR_SEL 29:27
	`define DMMX_SEL 32:30
	`define DR1_LD 33
	`define DR2_LD 34
	`define DSEGR_LD 35
	`define DMMX_LD 36
	
	`define DR1_PREMEM_V 37
	`define DR1_MEM_V 38
	`define DR1_EX_V 39
	`define DR2_PREMEM_V 41
	`define DR2_MEM_V 42
	`define DR2_EX_V 43
	`define DSEGR_PREMEM_V 45
	`define DSEGR_MEM_V 46
	`define DSEGR_EX_V 47
	`define DMMX_PREMEM_V 49
	`define DMMX_MEM_V 50
	`define DMMX_EX_V 51
	`define DR1_TYPE 54:53
	`define DR2_TYPE 56:55
	`define MEM_WT_EN 57
	`define MEM_DATA_TYPE 59:58
	`define COND_NZP 62:60
	`define EIP_LD 63
	`define EFLAGS_LD 64
	`define BR 65
	`define DR1MUX_SEL 66
	`define DR2MUX_SEL 67
	`define DMMXMUX_SEL 68
	`define MEMWTMUX_SEL 69
	`define EIPMUX_SEL 70
	
	// used by EX
	`define S1MUX_SEL 73:71
	`define S2MUX_SEL 76:74
	`define SHF_OP 78:77
	`define ALU_OP 81:79
	`define EFLAGS_SEL 83:82
	`define S1_TYPE 85:84
	`define S2_TYPE 87:86
	*/
	
	
	
	
	
	
	
endmodule

