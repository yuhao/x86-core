`include "/misc/collaboration/382nGPS/382nG6/yjl/yjl_gates.v"
//`uselib file=/misc/collaboration/382nGPS/382nG6/yjl/yjl_gates.v

//===============================================
//  Decoding
//===============================================
// 1. dst_gpr
// 2. src_gpr
// 3. index_gpr
// 4. base_gpr
// 5. dst_segr
// 6. src_segr
// 7. addr_segr     // for push/pop and rep movs, ds, and ss are src_segr, r/m use addr_segr

module decode_stage(
    clk, reset, set,
    F2D_instruction,
    F2D_upc,
    F2D_upc_valid,
    F2D_current_eip,
    F2D_next_eip,
    F2D_instr_valid_gt_16,
    F2D_valid,
    F2D_exception,

    L2D_stall,
    X2D_flush,

    D2L_control_signal,
    D2L_next_eip,
    D2L_current_eip,
    D2L_exception,

    D2L_imm,
    D2L_disp,
    D2L_stall_n,
    D2L_valid,
    D2F_instr_length,
    D2F_decode_failed,
    D2F_atomic,
    D2F_stall,
    D2F_split_instr
);
    //------------------------------- 
    //  Input Ports
    //------------------------------- 
    input           clk, reset, set;
    input [127:0]   F2D_instruction; 
    input [7:0]     F2D_upc;
    input           F2D_upc_valid;
    input [31:0]    F2D_current_eip;
    input [31:0]    F2D_next_eip;
    input           F2D_instr_valid_gt_16;
    input           F2D_valid;
    input [31:0]    F2D_exception;

    input           L2D_stall;
    input           X2D_flush;


    //------------------------------- 
    //  Output Ports
    //------------------------------- 
    output [`CS_NUM]    D2L_control_signal;
    output [31:0]       D2L_next_eip;
    output [31:0]       D2L_current_eip;
    output [31:0]       D2L_exception;
    output [31:0]       D2L_imm;
    output [31:0]       D2L_disp;
    output              D2L_valid;
    output              D2L_stall_n;

    output [3:0]        D2F_instr_length;
    output              D2F_decode_failed;
    output              D2F_atomic;
    output              D2F_split_instr;
    output              D2F_stall;
   

    //:::::::::::::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::::::::::::

    //  Control Signals
    wire [`CS_NUM]      cs_prefix;      // prefix informations: REP, SEGR_OVERRIDE, OPERAND_SIZE OVERRIDE
    wire [`CS_NUM]      cs_opcode;      // control signal of opcode word (one or two opcode)
    wire [`CS_NUM]      cs_ext;         // control_signal of extention opcode map
    wire [`CS_NUM]      control_signal; // one/two opcode, ext_opcode, special_opcode 
    wire [`CS_NUM]      cs_special;

    //--------------------------------
    //
    // Prefix Decoding
    //
    //--------------------------------

    // control signal (calling prefix_cs):
    //  SEGR_INDEX      override
    //  DISP_SIZE       or logic because no other will set it
    //  IMM_SIZE        or logic because no other will set it
    //  REP             or logic because no other will set it
    // operand_size_sel
    //  0: sel 32 bit for all 32-bit operands
    //  1:  16 bit ...
    // segment_index_sel
    //  0: select default segr index
    //  1: select overrided segr index

    //  prefix_detector and analyzer
    wire [3*`BYTE-1:0] prefix;          // get all possible prefixes
    wire [1:0]         prefix_size;     // 0, 1, 2, 3 
    wire [1:0]         pure_prefix_size;
    wire [2:0]         size_bitmap_neg;
    wire               opcode_size;

    wire [1:0] imm_sel;
    wire [1:0] disp_sel;


    assign prefix = F2D_instruction[127:127-(3*`BYTE-1)];   
 
    prefix_logic decode_prefix_logic(
        .prefix(prefix), 
        .control_signal(cs_prefix), 
        .prefix_size(prefix_size),
        .pure_prefix_size(pure_prefix_size),
        .size_bitmap_neg(size_bitmap_neg),
        .opcode_size(opcode_size)
    );


    //---------------------------------------------
    //
    //  Opcode Decoding
    //
    //---------------------------------------------
    // input: opcode 
    // output: ucode (mainly)
    //         mod_exist

    // disp_size is decided by either opcode or addressing mode 
    // imm_size is decided by either opcode or addressing mode
    // apart from segrment_override and operand_override, all other control signals is only by one part of the instruction => or logic
    wire [7:0]      opcode0;    
    wire [7:0]      opcode1;    
    wire [7:0]      opcode2;    
    wire [7:0]      opcode3;    
    assign opcode0 = F2D_instruction[127-0*`BYTE:127-1*`BYTE+1]; 
    assign opcode1 = F2D_instruction[127-1*`BYTE:127-2*`BYTE+1]; 
    assign opcode2 = F2D_instruction[127-2*`BYTE:127-3*`BYTE+1]; 
    assign opcode3 = F2D_instruction[127-3*`BYTE:127-4*`BYTE+1]; 
    
    wire [`CS_NUM]  cs_one_op0;
    wire [`CS_NUM]  cs_one_op1;
    wire [`CS_NUM]  cs_one_op2;
    wire [`CS_NUM]  cs_one_op3;
    wire [`CS_NUM]  cs_two_op0;
    wire [`CS_NUM]  cs_two_op1;
    wire [`CS_NUM]  cs_two_op2;
    wire [`CS_NUM]  cs_two_op3;
    
    // 1. Get the control_signal for all the four possibble opcode.
    opcode_analyzer oa_0(.opcode(opcode0), .cs_one_op(cs_one_op0), .cs_two_op(cs_two_op0), .opcode_size(opcode_size));
    opcode_analyzer oa_1(.opcode(opcode1), .cs_one_op(cs_one_op1), .cs_two_op(cs_two_op1), .opcode_size(opcode_size));
    opcode_analyzer oa_2(.opcode(opcode2), .cs_one_op(cs_one_op2), .cs_two_op(cs_two_op2), .opcode_size(opcode_size));
    opcode_analyzer oa_3(.opcode(opcode3), .cs_one_op(cs_one_op3), .cs_two_op(cs_two_op3), .opcode_size(opcode_size));
   
    // 2. get the correct cs_opcode according to the size of prefix;
    wire [`CS_NUM]  cs_opcode0; 
    wire [`CS_NUM]  cs_opcode1; 
    wire [`CS_NUM]  cs_opcode2; 
    wire [`CS_NUM]  cs_opcode3; 

    wire [3:0]      opcode_bitmap;
    size_bitmap2cs_op_sel gate_opcode_bitmap(.out(opcode_bitmap), .in(size_bitmap_neg));
    // select one-op-map or two-op-map
    // |opcode0|opcode1|opcode2|opcode3|
    mux2_128 mux_cs_op_0(cs_opcode0, cs_one_op0, cs_two_op0, opcode_size); // actually cs_two_op0 is useless
    mux2_128 mux_cs_op_1(cs_opcode1, cs_one_op1, cs_two_op1, opcode_size);
    mux2_128 mux_cs_op_2(cs_opcode2, cs_one_op2, cs_two_op2, opcode_size);
    mux2_128 mux_cs_op_3(cs_opcode3, cs_one_op3, cs_two_op3, opcode_size);     

    tristate128L tri_cs_op0(opcode_bitmap[3], cs_opcode0, cs_opcode);
    tristate128L tri_cs_op1(opcode_bitmap[2], cs_opcode1, cs_opcode);
    tristate128L tri_cs_op2(opcode_bitmap[1], cs_opcode2, cs_opcode);
    tristate128L tri_cs_op3(opcode_bitmap[0], cs_opcode3, cs_opcode);

    //mux4_128 mux_cs_opcode(cs_opcode, cs_opcode0, cs_opcode1, cs_opcode2, cs_opcode3, prefix_size[0], prefix_size[1]);



    //-------------------------------------------------
    //
    //  Special Ucode Store
    //
    //--------------------------------------------------
    // get ucode from upc_control store
    // the index of special upc is F2D_upc
    wire        next_split_upc_valid;   // next: select split upc
    wire [7:0]  next_split_upc;         // next: split upc to load into upc_reg
    wire [7:0]  split_upc;
    wire [7:0]  upc;                    // current: upc
    wire        ld_split_upc;           // next cycle:
    wire        split_upc_sel;          // next cycle: used to select split_upc next cycle
    wire        upc_sel;                // current :select special ucode this cycle
   
    initial
    begin
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_split_00.list", special_upc_map.rom0.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_split_01.list", special_upc_map.rom0.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_split_10.list", special_upc_map.rom1.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_split_11.list", special_upc_map.rom1.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_split_20.list", special_upc_map.rom2.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_split_21.list", special_upc_map.rom2.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_split_30.list", special_upc_map.rom3.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_split_31.list", special_upc_map.rom3.rom1.mem);
    end

    rom128b128w special_upc_map(.A(upc[6:0]), .OE(1'b1), .DOUT(cs_special));

   
    // >> upc
    // get upc information from opcode ucode (for split instruction)
    assign next_split_upc_valid = control_signal[`SPLIT_INSTR];
    assign next_split_upc = control_signal[`SPLIT_UPC7:`SPLIT_UPC0];
    assign ld_split_upc = next_split_upc_valid & D2L_stall_n;
    
    // split upc 
    reg8e upc_reg(.CLK(clk), .Din(next_split_upc), .Q(split_upc), .CLR(reset), .PRE(set), .en(ld_split_upc));

    mux2_8$ mux_upc(upc, F2D_upc, split_upc, split_upc_sel);
    
    // >> upc sel
    // split instruction will affect control flow at the next cycyle, so it need to be stored in a flip-flop
    reg1e upc_sel_reg(.CLK(clk), .Din(next_split_upc_valid), .Q(split_upc_sel), .CLR(reset), .PRE(set), .en(D2L_stall_n));

    or2$ or_upc_select(upc_sel, split_upc_sel, F2D_upc_valid);

    // use to stall Fetch stage
    // since split_upc_sel tells that the current cycle need to select split
    // we need to use next_split_upc_valid
    wire upc_stall;
    assign upc_stall = next_split_upc_valid & F2D_valid;

	assign D2F_atomic = upc_stall;		// if atomis is true, stall load eip


    //----------------------------------------------
    //
    //  ModR/M  +  SIB Analyzer
    //
    //----------------------------------------------
    
    //-----------------------------------
    //  Get modR/M, SIB bits
    //-----------------------------------
    wire        mod_exist;
    assign mod_exist = control_signal[`MOD_EXIST];

    wire [7:0]  modrm0;
    wire [7:0]  modrm1;
    wire [7:0]  modrm2;
    wire [7:0]  modrm3;
    wire [7:0]  sib0;
    wire [7:0]  sib1;
    wire [7:0]  sib2;
    wire [7:0]  sib3;

    // get possible modrm sib position
    assign modrm0 = F2D_instruction[127-1*`BYTE:127-2*`BYTE+1]; 
    assign modrm1 = F2D_instruction[127-2*`BYTE:127-3*`BYTE+1]; 
    assign modrm2 = F2D_instruction[127-3*`BYTE:127-4*`BYTE+1]; 
    assign modrm3 = F2D_instruction[127-4*`BYTE:127-5*`BYTE+1]; 

    assign sib0 = F2D_instruction[127-2*`BYTE:127-3*`BYTE+1]; 
    assign sib1 = F2D_instruction[127-3*`BYTE:127-4*`BYTE+1]; 
    assign sib2 = F2D_instruction[127-4*`BYTE:127-5*`BYTE+1]; 
    assign sib3 = F2D_instruction[127-5*`BYTE:127-6*`BYTE+1]; 
  
    wire [2:0]  modsib_gpr_reg_id;     
    wire [2:0]  modsib_base_reg_id;
    wire [2:0]  modsib_segr_reg_id;
    wire [2:0]  modsib_index_reg_id;
    wire [3:0]  modsib_and_disp_size;
    wire        modsib_need_base_reg;
    wire        modsib_need_index_reg;
    wire [1:0]  modsib_scale;
    wire [1:0]  modsib_shift_size;
    wire [2:0]  modsib_disp_size;
    wire [1:0]  modsib_disp_sel;
    wire        modsib_mem_or_reg;
      
    wire [2:0]  modsib_gpr_reg_id0;     
    wire [2:0]  modsib_base_reg_id0;
    wire [2:0]  modsib_segr_reg_id0;
    wire [2:0]  modsib_index_reg_id0;
    wire [3:0]  modsib_and_disp_size0;
    wire        modsib_need_base_reg0;
    wire        modsib_need_index_reg0;
    wire [1:0]  modsib_scale0;
    wire [1:0]  modsib_shift_size0;
    wire [2:0]  modsib_disp_size0;
    wire [1:0]  modsib_disp_sel0;
    wire        modsib_mem_or_reg0;

    wire [2:0]  modsib_gpr_reg_id1;     
    wire [2:0]  modsib_base_reg_id1;
    wire [2:0]  modsib_segr_reg_id1;
    wire [2:0]  modsib_index_reg_id1;
    wire [3:0]  modsib_and_disp_size1;
    wire        modsib_need_base_reg1;
    wire        modsib_need_index_reg1;
    wire [1:0]  modsib_scale1;
    wire [1:0]  modsib_shift_size1;
    wire [2:0]  modsib_disp_size1;
    wire [1:0]  modsib_disp_sel1;
    wire        modsib_mem_or_reg1;

    wire [2:0]  modsib_gpr_reg_id2;     
    wire [2:0]  modsib_base_reg_id2;
    wire [2:0]  modsib_segr_reg_id2;
    wire [2:0]  modsib_index_reg_id2;
    wire [3:0]  modsib_and_disp_size2;
    wire        modsib_need_base_reg2;
    wire        modsib_need_index_reg2;
    wire [1:0]  modsib_scale2;
    wire [1:0]  modsib_shift_size2;
    wire [2:0]  modsib_disp_size2;
    wire [1:0]  modsib_disp_sel2;
    wire        modsib_mem_or_reg2;

    wire [2:0]  modsib_gpr_reg_id3;     
    wire [2:0]  modsib_base_reg_id3;
    wire [2:0]  modsib_segr_reg_id3;
    wire [2:0]  modsib_index_reg_id3;
    wire [3:0]  modsib_and_disp_size3;
    wire        modsib_need_base_reg3;
    wire        modsib_need_index_reg3;
    wire [1:0]  modsib_scale3; 
    wire [1:0]  modsib_shift_size3;
    wire [2:0]  modsib_disp_size3;
    wire [1:0]  modsib_disp_sel3;
    wire        modsib_mem_or_reg3;

    wire [`CS_NUM]      cs_ext0;         // control_signal of extention opcode map
    wire [`CS_NUM]      cs_ext1;         // control_signal of extention opcode map
    wire [`CS_NUM]      cs_ext2;         // control_signal of extention opcode map
    wire [`CS_NUM]      cs_ext3;         // control_signal of extention opcode map


    wire op_ext_exist;
    assign op_ext_exist = cs_opcode[`OP_EXT_EXIST];

    modrm_sib_analyzer modrm_sib_logic_0(
        .opcode(opcode0),             // used to select modrm
        .modrm(modrm0),
        .sib(sib0),
        .op_ext_exist(op_ext_exist),
        .gpr_reg_id(modsib_gpr_reg_id0),
        .base_reg_id(modsib_base_reg_id0),
        .segr_reg_id(modsib_segr_reg_id0),
        .index_reg_id(modsib_index_reg_id0),
        .disp_size(modsib_disp_size0),
        .disp_sel(modsib_disp_sel0),
        .need_base_reg(modsib_need_base_reg0),
        .need_index_reg(modsib_need_index_reg0),
        .scale(modsib_scale0),
        .modsib_size(modsib_shift_size0),
        .modsib_disp_size(modsib_and_disp_size0),
        .mem_or_reg(modsib_mem_or_reg0),
        .cs_ext(cs_ext0)
    );

    modrm_sib_analyzer modrm_sib_logic_1(
        .opcode(opcode1),             // used to select modrm
        .modrm(modrm1),
        .sib(sib1),
        .op_ext_exist(op_ext_exist),
        .gpr_reg_id(modsib_gpr_reg_id1),
        .base_reg_id(modsib_base_reg_id1),
        .segr_reg_id(modsib_segr_reg_id1),
        .index_reg_id(modsib_index_reg_id1),
        .disp_size(modsib_disp_size1),
        .disp_sel(modsib_disp_sel1),
        .need_base_reg(modsib_need_base_reg1),
        .need_index_reg(modsib_need_index_reg1),
        .scale(modsib_scale1),
        .modsib_size(modsib_shift_size1),
        .modsib_disp_size(modsib_and_disp_size1),
        .mem_or_reg(modsib_mem_or_reg1),
        .cs_ext(cs_ext1)
    );


    modrm_sib_analyzer modrm_sib_logic_2(
        .opcode(opcode2),             // used to select modrm
        .modrm(modrm2),
        .sib(sib2),
        .op_ext_exist(op_ext_exist),
        .gpr_reg_id(modsib_gpr_reg_id2),
        .base_reg_id(modsib_base_reg_id2),
        .segr_reg_id(modsib_segr_reg_id2),
        .index_reg_id(modsib_index_reg_id2),
        .disp_size(modsib_disp_size2),
        .disp_sel(modsib_disp_sel2),
        .need_base_reg(modsib_need_base_reg2),
        .need_index_reg(modsib_need_index_reg2),
        .scale(modsib_scale2),
        .modsib_size(modsib_shift_size2),
        .modsib_disp_size(modsib_and_disp_size2),
        .mem_or_reg(modsib_mem_or_reg2),
        .cs_ext(cs_ext2)
    );

    modrm_sib_analyzer modrm_sib_logic_3(
        .opcode(opcode3),             // used to select modrm
        .modrm(modrm3),
        .sib(sib3),
        .op_ext_exist(op_ext_exist),
        .gpr_reg_id(modsib_gpr_reg_id3),
        .base_reg_id(modsib_base_reg_id3),
        .segr_reg_id(modsib_segr_reg_id3),
        .index_reg_id(modsib_index_reg_id3),
        .disp_size(modsib_disp_size3),
        .disp_sel(modsib_disp_sel3),
        .need_base_reg(modsib_need_base_reg3),
        .need_index_reg(modsib_need_index_reg3),
        .scale(modsib_scale3),
        .modsib_size(modsib_shift_size3),
        .modsib_disp_size(modsib_and_disp_size3),
        .mem_or_reg(modsib_mem_or_reg3),
        .cs_ext(cs_ext3)
    );

  
    tristate3L tri_modsib_gpr_reg_id_0(opcode_bitmap[3], modsib_gpr_reg_id0, modsib_gpr_reg_id);
    tristate3L tri_modsib_gpr_reg_id_1(opcode_bitmap[2], modsib_gpr_reg_id1, modsib_gpr_reg_id);
    tristate3L tri_modsib_gpr_reg_id_2(opcode_bitmap[1], modsib_gpr_reg_id2, modsib_gpr_reg_id);
    tristate3L tri_modsib_gpr_reg_id_3(opcode_bitmap[0], modsib_gpr_reg_id3, modsib_gpr_reg_id);
    
    tristate3L tri_modsib_base_reg_id_0(opcode_bitmap[3], modsib_base_reg_id0, modsib_base_reg_id);
    tristate3L tri_modsib_base_reg_id_1(opcode_bitmap[2], modsib_base_reg_id1, modsib_base_reg_id);
    tristate3L tri_modsib_base_reg_id_2(opcode_bitmap[1], modsib_base_reg_id2, modsib_base_reg_id);
    tristate3L tri_modsib_base_reg_id_3(opcode_bitmap[0], modsib_base_reg_id3, modsib_base_reg_id);
 
    tristate3L tri_modsib_index_reg_id_0(opcode_bitmap[3], modsib_index_reg_id0, modsib_index_reg_id);
    tristate3L tri_modsib_index_reg_id_1(opcode_bitmap[2], modsib_index_reg_id1, modsib_index_reg_id);
    tristate3L tri_modsib_index_reg_id_2(opcode_bitmap[1], modsib_index_reg_id2, modsib_index_reg_id);
    tristate3L tri_modsib_index_reg_id_3(opcode_bitmap[0], modsib_index_reg_id3, modsib_index_reg_id);
 
    tristate3L tri_modsib_segr_reg_id_0(opcode_bitmap[3], modsib_segr_reg_id0, modsib_segr_reg_id);
    tristate3L tri_modsib_segr_reg_id_1(opcode_bitmap[2], modsib_segr_reg_id1, modsib_segr_reg_id);
    tristate3L tri_modsib_segr_reg_id_2(opcode_bitmap[1], modsib_segr_reg_id2, modsib_segr_reg_id);
    tristate3L tri_modsib_segr_reg_id_3(opcode_bitmap[0], modsib_segr_reg_id3, modsib_segr_reg_id);

    tristate2L tri_modsib_scale_0(opcode_bitmap[3], modsib_scale0, modsib_scale);
    tristate2L tri_modsib_scale_1(opcode_bitmap[2], modsib_scale1, modsib_scale);
    tristate2L tri_modsib_scale_2(opcode_bitmap[1], modsib_scale2, modsib_scale);
    tristate2L tri_modsib_scale_3(opcode_bitmap[0], modsib_scale3, modsib_scale);

    tristate3L tri_modsib_disp_size_0(opcode_bitmap[3], modsib_disp_size0, modsib_disp_size);
    tristate3L tri_modsib_disp_size_1(opcode_bitmap[2], modsib_disp_size1, modsib_disp_size);
    tristate3L tri_modsib_disp_size_2(opcode_bitmap[1], modsib_disp_size2, modsib_disp_size);
    tristate3L tri_modsib_disp_size_3(opcode_bitmap[0], modsib_disp_size3, modsib_disp_size);
    
    tristate2L tri_modsib_shift_size_0(opcode_bitmap[3], modsib_shift_size0, modsib_shift_size);
    tristate2L tri_modsib_shift_size_1(opcode_bitmap[2], modsib_shift_size1, modsib_shift_size);
    tristate2L tri_modsib_shift_size_2(opcode_bitmap[1], modsib_shift_size2, modsib_shift_size);
    tristate2L tri_modsib_shift_size_3(opcode_bitmap[0], modsib_shift_size3, modsib_shift_size);
    
    tristateL$ tri_modsib_need_base_0(opcode_bitmap[3], modsib_need_base_reg0, modsib_need_base_reg);
    tristateL$ tri_modsib_need_base_1(opcode_bitmap[2], modsib_need_base_reg1, modsib_need_base_reg);
    tristateL$ tri_modsib_need_base_2(opcode_bitmap[1], modsib_need_base_reg2, modsib_need_base_reg);
    tristateL$ tri_modsib_need_base_3(opcode_bitmap[0], modsib_need_base_reg3, modsib_need_base_reg);
    
    tristateL$ tri_modsib_need_index_0(opcode_bitmap[3], modsib_need_index_reg0, modsib_need_index_reg);
    tristateL$ tri_modsib_need_index_1(opcode_bitmap[2], modsib_need_index_reg1, modsib_need_index_reg);
    tristateL$ tri_modsib_need_index_2(opcode_bitmap[1], modsib_need_index_reg2, modsib_need_index_reg);
    tristateL$ tri_modsib_need_index_3(opcode_bitmap[0], modsib_need_index_reg3, modsib_need_index_reg);

    tristate4L tri_modsib_and_disp_size_0(opcode_bitmap[3], modsib_and_disp_size0, modsib_and_disp_size);
    tristate4L tri_modsib_and_disp_size_1(opcode_bitmap[2], modsib_and_disp_size1, modsib_and_disp_size);
    tristate4L tri_modsib_and_disp_size_2(opcode_bitmap[1], modsib_and_disp_size2, modsib_and_disp_size);
    tristate4L tri_modsib_and_disp_size_3(opcode_bitmap[0], modsib_and_disp_size3, modsib_and_disp_size);
   
    tristateL$ tri_modsib_mem_or_reg_0(opcode_bitmap[3], modsib_mem_or_reg0, modsib_mem_or_reg);
    tristateL$ tri_modsib_mem_or_reg_1(opcode_bitmap[2], modsib_mem_or_reg1, modsib_mem_or_reg);
    tristateL$ tri_modsib_mem_or_reg_2(opcode_bitmap[1], modsib_mem_or_reg2, modsib_mem_or_reg);
    tristateL$ tri_modsib_mem_or_reg_3(opcode_bitmap[0], modsib_mem_or_reg3, modsib_mem_or_reg);
    
    tristate2L tri_modsib_disp_sel_0(opcode_bitmap[3], modsib_disp_sel0, modsib_disp_sel);
    tristate2L tri_modsib_disp_sel_1(opcode_bitmap[2], modsib_disp_sel1, modsib_disp_sel);
    tristate2L tri_modsib_disp_sel_2(opcode_bitmap[1], modsib_disp_sel2, modsib_disp_sel);
    tristate2L tri_modsib_disp_sel_3(opcode_bitmap[0], modsib_disp_sel3, modsib_disp_sel);

    tristate128L tri_cs_ext_0(opcode_bitmap[3], cs_ext0, cs_ext);
    tristate128L tri_cs_ext_1(opcode_bitmap[2], cs_ext1, cs_ext);
    tristate128L tri_cs_ext_2(opcode_bitmap[1], cs_ext2, cs_ext);
    tristate128L tri_cs_ext_3(opcode_bitmap[0], cs_ext3, cs_ext);
    
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::

    //-------------------------------------------------
    // Merge Control Signal 
    //-------------------------------------------------
    // till now, cs_opcode, cs_ext are all generated.
    //      upc_sel,op_ext_sel
    //      00      cs_opcode        // one/two byte op map
    //      01      cs_ext
    //      10      cs_special
    //      11      cs_special
    wire op_ext_sel;
    assign op_ext_sel = cs_opcode[`OP_EXT_EXIST];
    mux4_128 mux_select_control_signal(control_signal, cs_opcode, cs_ext, cs_special, cs_special, op_ext_sel, upc_sel);

    //::::::::::::::::::::::::::::::::::::::::::::::::::::::


    //================================================
    //
    //  DATA TYPE  
    //
    //================================================
    
    //...........................................................
    // operand_size_override (imm_size, datatype)
    // 2, merge data_type
    // reg, mem (dtat_tyoe) 
    // 32 -> 16     10 -> 01
    // data_type: byte, word, doubleword, quadword 
    // assign data_type_10 = cs_opcode[`DST_DATA_TYPE1] & !cs_opcode[`DST_DATA_TYPE0];
    //...........................................................
    
    wire dst_is_not_data;
    wire src_is_not_data;
    wire [1:0] data_type;
    wire [1:0] dst_data_type;
    wire [1:0] src_data_type;
    wire data_type_override;
    wire imm_ov_allow;
    wire imm_override_n;
    wire disp_override_n;           // disp_ov_allow && ov_prefix
    
    assign dst_is_not_data  = control_signal[`DST_IS_INDEX];
    assign src_is_not_data  = control_signal[`SRC_IS_INDEX];

    // >> data_type
    mux2_2 mux_data_type_ov(data_type, control_signal[`DATA_TYPE], 2'b01, data_type_override);
    
    // >> dst_gpr
    // >> src_gpr
    assign data_type_override  = cs_prefix[`CS_OPERAND_SIZE_OVERRIDE] & control_signal[`CS_OPERAND_SIZE_OVERRIDE];
        // override operand size from 32 bits into 16 bits
    mux2_2 mux_dst_data_type(dst_data_type, data_type, 2'b10, dst_is_not_data);
    mux2_2 mux_src_data_type(src_data_type, data_type, 2'b10, src_is_not_data);
    
    // >> imm
        // if data_type is overridden, then imm = data_type, other wise, imm = cs[`IMM_SEL]
    assign imm_ov_allow        = control_signal[`IMM_SIZE2]; 
    mux2_2 mux_imm_sel(imm_sel, 2'b10, control_signal[`IMM_SEL1:`IMM_SEL0], imm_override_n);    
    nand2$ nand_imm_override(imm_override_n, imm_ov_allow, data_type_override);
    
    // >> disp
        // if modrm exist, disp_sel = modsib_disp_sel, else disp_sel might be overridden
    wire [1:0]  opcode_disp_sel;           // disp_sel decided by opcode
    nand2$ nand_disp_ov_enbar(disp_override_n, control_signal[`DISP_OV_ALLOW], data_type_override);
    mux2_2 mux_opcode_disp_sel(opcode_disp_sel, 2'b10, control_signal[`DISP_SEL], disp_override_n);
    mux2_2 mux_disp_sel(disp_sel, opcode_disp_sel, modsib_disp_sel, mod_exist);



    //==========================================
    //  
    //  SEGR/GPR INDEX
    //
    //==========================================

    //-------------------------------------
    //  SEGR INDEX
    //-------------------------------------
    // >> segr_index
        //    merge address_mode(r/m) v.s. opcode decided(ds:esi)
    wire [2:0]  addr_segr_no_ov;
    wire        addr_segr_override_enbar;      // actually only override addressing mode
    wire [2:0]  addr_segr_id;
    nand2$ nand_segr_override_enable(addr_segr_override_enbar, control_signal[`ADDR_SEGR_OV_ALLOW], cs_prefix[`CS_SEGR_OVERRIDE]);
    
        // if no overridden prefix exist
        // determine segr (from opcode or modrm) according to mod_exist or not
    mux2_3 mux_segr_id0(addr_segr_no_ov, control_signal[`ADDR_SEGR_SEL2:`ADDR_SEGR_SEL0], modsib_segr_reg_id, mod_exist);
    
        // modify the control_signal
    mux2_3 mux_addr_segr(addr_segr_id, cs_prefix[`ADDR_SEGR_SEL2:`ADDR_SEGR_SEL0], addr_segr_no_ov, addr_segr_override_enbar);
    assign D2L_control_signal[`ADDR_SEGR_SEL] = addr_segr_id;


    //-------------------------------
    //  GPR INDEX
    //-------------------------------
    // dst_gpr_force mod_exist
    //  00,     control_signal[DST_GPR_SEL]
    //  01,     dst_gpr_mod
    //  10,     control_signal[DST_GPR_SEL]
    //  11,     control_signal[DST_GPR_SEL] 

    wire [2:0] dst_gpr_mod; 
    wire [2:0] src_gpr_mod;
    wire [2:0] dst_gpr; 
    wire [2:0] src_gpr;
    wire dst_gpr_force;
    wire src_gpr_force;
    assign dst_gpr_force = control_signal[`DST_IS_INDEX];
    assign src_gpr_force = control_signal[`SRC_IS_INDEX];

    mux2_3 mux_dst_gpr_mod(dst_gpr_mod, modsib_base_reg_id, modsib_gpr_reg_id, control_signal[`ADDRESS_MODE_RM]);
    mux2_3 mux_src_gpr_mod(src_gpr_mod, modsib_gpr_reg_id, modsib_base_reg_id, control_signal[`ADDRESS_MODE_RM]);
    // merged modrm and opcode decided gpr id
    mux4_3 mux_src_gpr(src_gpr, control_signal[`SRC_GPR_SEL2:`SRC_GPR_SEL0], src_gpr_mod, control_signal[`SRC_GPR_SEL2:`SRC_GPR_SEL0], control_signal[`SRC_GPR_SEL2:`SRC_GPR_SEL0], mod_exist, src_gpr_force); 
    mux4_3 mux_dst_gpr(dst_gpr, control_signal[`DST_GPR_SEL2:`DST_GPR_SEL0], dst_gpr_mod, control_signal[`DST_GPR_SEL2:`DST_GPR_SEL0], control_signal[`DST_GPR_SEL2:`DST_GPR_SEL0], mod_exist, dst_gpr_force); 

    wire [2:0] src_mmx; 
    wire [2:0] dst_mmx; 
    mux2_3 mux_mmx_src(src_mmx, src_gpr_mod, control_signal[`SRC_MMX_SEL2:`SRC_MMX_SEL0], src_gpr_force);
    mux2_3 mux_mmx_dst(dst_mmx, dst_gpr_mod, control_signal[`DST_MMX_SEL2:`DST_MMX_SEL0], dst_gpr_force);


    //==============================================
    //
    //  WRITE/READ
    //
    //===============================================

    //-----------------------------
    //  write/read signal
    //-----------------------------
    wire wr_dst_gpr;             
    wire rd_dst_gpr;
    wire wr_src_gpr;             
    wire rd_src_gpr;
    wire modsib_mem_or_reg_n;
    wire mem_write_n;
    wire mem_write;
    wire mem_read_n;
    wire mem_read;
    wire mode_rm_n;             // rm = 0;  r/m <- r
    wire mode_rm;               // rm = 1;  r   <- r/m
    wire mem_write_rm_n;
    wire mem_read_rm;
    wire mem_read_rm_n;

    inv1$ inv_modsib_mem_or_reg(modsib_mem_or_reg_n, modsib_mem_or_reg);
    assign mode_rm = control_signal[`ADDRESS_MODE_RM];
    inv1$ inv_mode_rm_n(mode_rm_n, control_signal[`ADDRESS_MODE_RM]);

    wire mem_write0;        // generated by r/m
    wire mem_write1;        // direct guided by control_signal 
    assign mem_write0 = control_signal[`MEM_WRITE]; 
    wire write_dst_reg;
    or2$ or_write_dst_reg(write_dst_reg, control_signal[`WRITE_DST_GPR], control_signal[`WRITE_DST_MMX]);

    and4$ and_mod_mem_write(mem_write1, modsib_mem_or_reg, mode_rm_n, write_dst_reg, mod_exist);
    or2$ or_mem_write(mem_write, mem_write0, mem_write1);

    //  mem_read 
    //  1. opcode (ES:ESI <- DS:EDI)            
    //  2. r/m <- r AND read_dst
    //  3. r <- r/m AND read_src
    wire mem_read0;
    wire mem_read1;
    wire mem_read2;
        

    wire read_dst_reg;
    wire read_src_reg;

    or2$ or_read_src_reg(read_src_reg, control_signal[`READ_SRC_GPR], control_signal[`READ_SRC_MMX]);
    or2$ or_read_dst_reg(read_dst_reg, control_signal[`READ_DST_GPR], control_signal[`READ_DST_MMX]);


    assign mem_read0 = control_signal[`MEM_READ];
    assign mem_read1 = ~control_signal[`ADDRESS_MODE_RM] & modsib_mem_or_reg & read_dst_reg & mod_exist;
    assign mem_read2 = control_signal[`ADDRESS_MODE_RM] & modsib_mem_or_reg & read_src_reg & mod_exist;
    assign mem_read  = mem_read0 | mem_read1 | mem_read2;
    assign mem_read_n = ~mem_read;
    //and4$ and_mem_read(mem_read, cs_opcode[`ADDRESS_MODE_RM], modsib_mem_or_reg, cs_opcode[`READ_SRC_GPR], mod_exist);
    //nand4$ nand_mem_read(mem_read_n, cs_opcode[`ADDRESS_MODE_RM], modsib_mem_or_reg, cs_opcode[`READ_SRC_GPR], mod_exist);
    
    wire wr_dst_gpr_rm;
    wire wr_dst_gpr_reg;
    wire wr_dst_gpr_base;
    nand2$ and_wr_dst_gpr_reg(wr_dst_gpr_reg, control_signal[`WRITE_DST_GPR], mode_rm);     // mode_rm => r/m occur as src
    nand3$ and_wr_dst_gpr_base(wr_dst_gpr_base, control_signal[`WRITE_DST_GPR], !modsib_mem_or_reg, !mode_rm);     // r/m <- r
    nand2$ or_wr_dst_gpr(wr_dst_gpr_rm, wr_dst_gpr_base, wr_dst_gpr_reg);

    mux4$ mux_wr_dst_gpr(wr_dst_gpr, control_signal[`WRITE_DST_GPR], wr_dst_gpr_rm, control_signal[`WRITE_DST_GPR], control_signal[`WRITE_DST_GPR], mod_exist, dst_gpr_force);

    wire rd_dst_gpr_base;
    wire rd_dst_gpr_reg;
    wire rd_dst_gpr_rm;
    nand2$ and_read_dst_gpr_reg(rd_dst_gpr_reg, control_signal[`READ_DST_GPR], mode_rm);     // mode_rm => r/m occur as src
    nand3$ and_read_dst_gpr_base(rd_dst_gpr_base, control_signal[`READ_DST_GPR], !modsib_mem_or_reg, !mode_rm);     // r/m <- r
    nand2$ or_read_dst_gpr(rd_dst_gpr_rm, rd_dst_gpr_base, rd_dst_gpr_reg);
    mux4$ mux_read_dst_gpr(rd_dst_gpr, control_signal[`READ_DST_GPR], rd_dst_gpr_rm, control_signal[`READ_DST_GPR], control_signal[`READ_DST_GPR], mod_exist, dst_gpr_force);

    assign wr_src_gpr = control_signal[`WRITE_SRC_GPR];           // this abuse will occur only when it is used by PPMM

    wire rd_src_gpr_rm;
    wire rd_src_gpr_base;
    wire rd_src_gpr_reg;
    nand2$ and_read_src_gpr_reg(rd_src_gpr_reg, control_signal[`READ_SRC_GPR], !mode_rm);     // mode_rm => r/m occur as src
    nand3$ and_read_src_gpr_base(rd_src_gpr_base, control_signal[`READ_SRC_GPR], !modsib_mem_or_reg, mode_rm);     // r/m <- r
    nand2$ or_read_src_gpr(rd_src_gpr_rm, rd_src_gpr_base, rd_src_gpr_reg);
    mux4$ mux_read_src_gpr(rd_src_gpr, control_signal[`READ_SRC_GPR], control_signal[`READ_SRC_GPR], control_signal[`READ_SRC_GPR], rd_src_gpr_rm, mod_exist, src_gpr_force);
   


    //=============================================
    //
    //  Length Computation
    //
    //=============================================

    //............................................................................
    // Technique: first get modsib_and_disp_size from modsib analyzer
    // select it between overridden size according to disp_override_n
    // when you have the information decided by modrm
    // and the information from opcode, you can get the *modrm (1byte) + disp*
    //............................................................................

    wire [3:0] instr_length;
    wire instr_length_clear_n;

    // >>> *ModR/M + SIB + Disp*
        // s1s0 
        // 00: 16       // no r/m
        // 01: XX
        // 10: opcode decide
        // 11: modsib decide
    wire [2:0] instr_length_part1;   // determined by opcode or modsib
    mux4_3 mux_modsib_andor_size(instr_length_part1, 3'b010, 3'b000, control_signal[`DISP_SIZE2:`DISP_SIZE0], modsib_and_disp_size, mod_exist, disp_override_n);
    
    // >>> *Prefix + Opcode + Imm*
        // prefix_size + imm_size , cin = 1 (one opcode)
    wire [3:0] instr_length_part2;       
    wire [3:0] length_no_operand_ov;       
    wire [3:0] length_operand_ov;       
        // assume no operand override // imm_size is decide by opcode    
    adder4b adder_len00(length_no_operand_ov, {2'b0, prefix_size}, {1'b0, control_signal[`IMM_SIZE2:`IMM_SIZE0]}, 1'b1);   
        // assume the operand is overriden  // imm16 + one opcode
    adder4b adder_len0_op_override(length_operand_ov, {2'b0, prefix_size}, 4'b010, 1'b1);   
    mux2_4 mux_instr_length0(instr_length_part2, length_operand_ov, length_no_operand_ov, imm_override_n);

    // >>> * prefix + opcode + || mod + sib + disp
    adder4b adder_len1(instr_length, instr_length_part2, {1'b0, instr_length_part1}, 1'b0);   
    
    // if decode_failed_n=0 or reset = 0
    wire [3:0]  instr_length_wb;
    
    wire instr_length_clear;
    // decode_failed or F2D_valid not valid
    wire flush_n;
    inv1$ inv_flush(flush_n, X2D_flush);
    //nand4$ nand_length_clear(instr_length_clear, decode_failed_n, F2D_valid, flush_n, !upc_sel);
	// if other stage stall Decode, clear instr_length so that eip won't change
	// if F2D_v is invalid, length should be cleared
    nand4$ nand_length_clear(instr_length_clear, decode_failed_n, F2D_valid, flush_n, !L2D_stall);


    mux2_4 mux_instr_length_wb(instr_length_wb, instr_length, 4'b0, instr_length_clear);

    
    // if D2L_valid == 0, instr_length = 0
    wire D2F_stall_n;
    latch4 reg_instr_length(.CLR(reset), .D(instr_length_wb), .Q(D2F_instr_length), .EN(1'b1), .PRE(set));
    




    //=====================================
    //
    // Literal Decoding 
    // 
    //=====================================
    //..................................................................................
    // till now, we've found out disp_size and imm_size
    // shift the instruction to get the starting of literals, at the decode stage, 
    // we can analyze the literals and get imm32, imm8...
    //..................................................................................

    //--------------------------------
    //  Shift the instruction
    //--------------------------------
    wire [127:0]    instr_aft_pf;  // actually, 12 byte is enough
    wire [127:0]    instr_aft_modsib;
    wire [127:0]    instr_aft_opcode;
    wire [63:0] literal;    // max: disp32, imm32

    // aft *PREFIX* 
    lshifter128_2_byte lshift_0(instr_aft_pf, F2D_instruction, prefix_size);

    // aft *OPCODE*     // just one byte
    assign instr_aft_opcode[127:`BYTE] = instr_aft_pf[127-`BYTE:0];    // shift left by one byte
    assign instr_aft_opcode[`BYTE-1:0] = 8'b0;

    // aft *MODRM, SIB*
    // decide the length of modrm and sib according to mod_exist or not.
    wire [1:0] modsib_shift_size_v;
    and2$ and_modsib_shift_size0(modsib_shift_size_v[1], modsib_shift_size[1], mod_exist);
    and2$ and_modsib_shift_size1(modsib_shift_size_v[0], modsib_shift_size[0], mod_exist);

    lshifter128_2_byte lshift_1(instr_aft_modsib, instr_aft_opcode, modsib_shift_size_v);

    assign literal = instr_aft_modsib[127:64];
    
    // Literal Analyzer
    literal_analyzer literal_logic(
        .literal(literal),
        .disp_sel(disp_sel),
        .disp_part(D2L_disp),
        .imm_part(D2L_imm)
    );


    //=================================
    //
    //  Decode Failed
    //
    //=================================

    // if only 8 byte valid instruction is sent to Decode stage,
    //  1. but the instruction length is bigger than 8, 
    //  2. then we have to stall the fetch stage, flush the decode stage, 
    //  3. feedback signal back to fetch stage
    //      a. don't change eip
    //      b. fetch more instruction from i-cache (change icache_addr)
    // 11 -> 100
    // 10 -> 010
    // 01 -> 001
    // 00 -> 0000

    // if instr_length + eip >  (instr_length[3] == 1)  && F2D_instr_tvalid_gt_16 == 0
    //  ==> decoding failed

    wire decode_failed;
    
    wire instr_valid_lt_16;
    inv1$ inv_instr_valid(instr_valid_lt_16, F2D_instr_valid_gt_16);
    wire instr_gt_16;
    wire [4:0] instr_location_adder;
    assign instr_location_adder = instr_length + F2D_current_eip[3:0]; 
    assign instr_gt_16 = instr_location_adder[4];
    and2$ and_decode_failed(decode_failed, instr_gt_16, instr_valid_lt_16); 
    nand2$ nand_decode_failed_n(decode_failed_n, instr_gt_16, instr_valid_lt_16); 


    //======================================
    //
    //  Output 
    //
    //======================================
    // 1. decide base_reg(pointed by r/m) or gpr_reg(pointed by reg_op) is dst or src
    //  OP, r/m, r. r/m is dst, r is src; OP r, r/m. r is dst_gpr, r/m is src_gpr
    assign D2L_control_signal[`DST_GPR_SEL2:`DST_GPR_SEL0] = dst_gpr;
    assign D2L_control_signal[`SRC_GPR_SEL2:`SRC_GPR_SEL0] = src_gpr;

    // 2. select reg_id determined by opcode or address_mode
    //mux2_3 mux_dst_gpr_id(D2L_dst_gpr_id, dst_gpr_tmp, cs_opcode[`DST_GPR_SEL2:`DST_GPR_SEL0], ); 
   //mux2_3 mux_src_gpr_id(D2L_src_gpr_id, src_gpr_tmp, cs_opcode[`SRC_GPR_SEL2:`SRC_GPR_SEL0]); 
    //assign D2L_src_gpr_id = D2L_control_signal[`DST_GPR_SEL2:`DST_GPR_SEL0];
    
    // 3. literal_sel
    assign D2L_control_signal[`DISP_SEL1:`DISP_SEL0] = disp_sel;
    assign D2L_control_signal[`IMM_SEL1:`IMM_SEL0] = imm_sel;

    // 4. rep prefix
    assign D2L_control_signal[`CS_REP] = cs_prefix[`CS_REP];

    // 4. used in AGLR stage: addressing mode 
    wire need_base_gpr;
    wire need_index_gpr;
    mux2$ mux_need_base_reg(need_base_gpr, 1'b0, modsib_need_base_reg, mod_exist);
    mux2$ mux_need_index_gpr(need_index_gpr, 1'b0, modsib_need_index_reg, mod_exist);

    assign D2L_control_signal[`BASE_GPR_SEL2:`BASE_GPR_SEL0]   = modsib_base_reg_id; 
    assign D2L_control_signal[`INDEX_GPR_SEL2:`INDEX_GPR_SEL0] = modsib_index_reg_id;
    assign D2L_control_signal[`READ_BASE_GPR]                  = need_base_gpr;
    assign D2L_control_signal[`READ_INDEX_GPR]                 = need_index_gpr;
    assign D2L_control_signal[`ADDR_SEGR_SEL2:`ADDR_SEGR_SEL0]  = addr_segr_id; 
    assign D2L_control_signal[`SCALE1:`SCALE0]                 = modsib_scale;

    //assign D2L_control_signal[`WRITE_DST_GPR]   = cs_opcode[`WRITE_DST_GPR];
    //assign D2L_control_signal[`READ_DST_GPR]    = cs_opcode[`READ_DST_GPR];
    assign D2L_control_signal[`WRITE_DST_GPR]   = wr_dst_gpr;
    assign D2L_control_signal[`READ_DST_GPR]    = rd_dst_gpr; 

    //assign D2L_control_signal[`WRITE_SRC_GPR]   = control_signal[`WRITE_SRC_GPR];
    //assign D2L_control_signal[`READ_SRC_GPR]    = cs_opcode[`READ_SRC_GPR];
    assign D2L_control_signal[`WRITE_SRC_GPR]   = wr_src_gpr;
    assign D2L_control_signal[`READ_SRC_GPR]    = rd_src_gpr; 

    //--------------------------------------------
    // for MOV Sreg, r/m or MOV r/m Sreg.
    //--------------------------------------------
    wire [2:0]  dst_segr;
    wire [2:0]  src_segr;
    wire        wr_dst_segr;
    wire        rd_dst_segr;
    wire        wr_src_segr;
    wire        rd_src_segr;
    mux2_3 mux_dst_segr(dst_segr, control_signal[`DST_SEGR_SEL], dst_gpr, control_signal[`SREG_FLAG]);
    mux2_3 mux_src_segr(src_segr, control_signal[`SRC_SEGR_SEL], src_gpr, control_signal[`SREG_FLAG]);

    //mux2$ mux_wr_dst_segr(wr_dst_segr, control_signal[`WRITE_DST_SEGR], wr_dst_gpr, control_signal[`SREG_FLAG]);
    //mux2$ mux_wr_src_segr(wr_src_segr, control_signal[`WRITE_SRC_SEGR], wr_src_gpr, control_signal[`SREG_FLAG]);
    //mux2$ mux_rd_dst_segr(rd_dst_segr, control_signal[`READ_DST_SEGR], rd_dst_gpr, control_signal[`SREG_FLAG]);
    //mux2$ mux_rd_src_segr(rd_src_segr, control_signal[`READ_SRC_SEGR], rd_src_gpr, control_signal[`SREG_FLAG]);

    //:::::::::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::::::::
    assign D2L_control_signal[`DST_SEGR_SEL] = dst_segr;
    assign D2L_control_signal[`SRC_SEGR_SEL] = src_segr;


    assign D2L_control_signal[`DATA_TYPE]       = data_type;
    assign D2L_control_signal[`DST_DATA_TYPE]   = dst_data_type;
    assign D2L_control_signal[`SRC_DATA_TYPE]   = src_data_type;

    assign D2L_control_signal[`MEM_WRITE]        = mem_write;
    assign D2L_control_signal[`MEM_READ]         = mem_read;

    // wr/rd segr is decided by opcode, whihc is  nothign to do with the gpr
    assign D2L_control_signal[`WRITE_DST_SEGR] = wr_dst_segr;
    assign D2L_control_signal[`WRITE_SRC_SEGR] = wr_src_segr;
    assign D2L_control_signal[`READ_DST_SEGR]  = rd_dst_segr;
    assign D2L_control_signal[`READ_SRC_SEGR]  = rd_src_segr;


    assign D2L_control_signal[`WRITE_DST_SEGR]  = control_signal[`WRITE_DST_SEGR];
    assign D2L_control_signal[`READ_DST_SEGR]   = control_signal[`READ_DST_SEGR];
    assign D2L_control_signal[`WRITE_SRC_SEGR]  = control_signal[`WRITE_SRC_SEGR];
    assign D2L_control_signal[`READ_SRC_SEGR]   = control_signal[`READ_SRC_SEGR];

    mux2$ or_rd_addr_segr(D2L_control_signal[`READ_ADDR_SEGR], control_signal[`READ_ADDR_SEGR], 1'b1, mod_exist);

    // other control signal not affected by prefix, modsib.
    assign D2L_control_signal[`DST_MMX_SEL]     = dst_mmx; 
    assign D2L_control_signal[`SRC_MMX_SEL]     = src_mmx;
    assign D2L_control_signal[`WRITE_DST_MMX]   = control_signal[`WRITE_DST_MMX];
    assign D2L_control_signal[`READ_DST_MMX]    = control_signal[`READ_DST_MMX];
    assign D2L_control_signal[`READ_SRC_MMX]    = control_signal[`READ_SRC_MMX];
    

    assign D2L_control_signal[`SPLIT_INSTR]     = control_signal[`SPLIT_INSTR];
    assign D2L_control_signal[`SPLIT_UPC]       = control_signal[`SPLIT_UPC];
    assign D2L_control_signal[`PPMM_FLAG]       = control_signal[`PPMM_FLAG];

    
    assign D2L_control_signal[`UNCOND_JMP]       = control_signal[`UNCOND_JMP];
    assign D2L_control_signal[`COND_JMP]         = control_signal[`COND_JMP];
    assign D2L_control_signal[`EIP_LOAD]         = control_signal[`EIP_LOAD];


    assign D2L_control_signal[`LOAD_CODE_SEGMENT]         = control_signal[`LOAD_CODE_SEGMENT];
    assign D2L_control_signal[`TAKE_BR]          = control_signal[`TAKE_BR];
    assign D2L_control_signal[`SET_CC]           = control_signal[`SET_CC];
    assign D2L_control_signal[`LOAD_CC]          = control_signal[`LOAD_CC];


    assign D2L_control_signal[`CC_ZF_CHECK]     = control_signal[`CC_ZF_CHECK];
    assign D2L_control_signal[`CC_ZF]           = control_signal[`CC_ZF];
    assign D2L_control_signal[`CC_CF_CHECK]     = control_signal[`CC_CF_CHECK];
    assign D2L_control_signal[`CC_CF]           = control_signal[`CC_CF];
   

    assign D2L_control_signal[`ALU_OP]              = control_signal[`ALU_OP];
    assign D2L_control_signal[`ALU_SRC1_SEL]        = control_signal[`ALU_SRC1_SEL];
    assign D2L_control_signal[`ALU_SRC2_SEL]        = control_signal[`ALU_SRC2_SEL];
    assign D2L_control_signal[`SHIFT_OP]            = control_signal[`SHIFT_OP];
    assign D2L_control_signal[`RESULT_SEL]          = control_signal[`RESULT_SEL];
    
    
    assign D2L_control_signal[`STD]        = control_signal[`STD];
    assign D2L_control_signal[`CLD]        = control_signal[`CLD];
    assign D2L_control_signal[`HLT]        = control_signal[`HLT];

    assign D2L_control_signal[`CC_N]        = control_signal[`CC_N];
    assign D2L_control_signal[`CC_Z]        = control_signal[`CC_Z];
    assign D2L_control_signal[`CC_P]        = control_signal[`CC_P];

    assign D2L_control_signal[`AUTO_INC_SEL2]        = control_signal[`AUTO_INC_SEL2];

    assign D2L_control_signal[`MOD_EXIST]     = control_signal[`MOD_EXIST];
    assign D2L_control_signal[`ADDRESS_MODE_RM]     = control_signal[`ADDRESS_MODE_RM];

    assign D2L_control_signal[`AUTO_INC_SEL]     = control_signal[`AUTO_INC_SEL];

    // EIP selecting cs
    assign D2L_control_signal[`EIPMUX_SEL]      = control_signal[`EIPMUX_SEL];
    assign D2L_control_signal[`MEMMUX_SEL]       = control_signal[`MEMMUX_SEL];
    assign D2L_control_signal[`EFLAGSMUX_SEL]    = control_signal[`EFLAGSMUX_SEL];

    assign D2L_control_signal[`EIPMUX_SEL2]    = control_signal[`EIPMUX_SEL2];
    assign D2L_control_signal[`IDTR]    = control_signal[`IDTR];
    assign D2L_control_signal[`NEED_DF]    = control_signal[`NEED_DF];


    assign D2L_control_signal[`COUNT_SEL] = control_signal[`COUNT_SEL];
    assign D2L_control_signal[`COUNT_LD] = control_signal[`COUNT_LD];

        
    assign D2L_control_signal[`FORCE_DST_DATA] = control_signal[`FORCE_DST_DATA];
    assign D2L_control_signal[`FORCE_SRC_DATA] = control_signal[`FORCE_SRC_DATA];


	assign D2L_control_signal[102] = control_signal[102];	// JACK

    //:::::::::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::::::::

    // direct *passed* signals
    assign D2L_current_eip = F2D_current_eip;
    assign D2L_next_eip    = F2D_next_eip;
    assign D2L_exception[10:0] = F2D_exception[10:0];
    assign D2L_exception[31:24] = upc; 

    //................................................................................................
    // automic
    //  for split_instruction, and int/exp sub-operations
    //  Fetch stage cannot change eip's value. (until the final instruction is changing eip and cs => control_flow_change = true)
    //  there should be a exception_handling flag for Fetch, this flag will be cleared until the address of exp_handler routine
    //  is loaded.
    //  difference between automic and split_instr
    //  automic is used to mask interrupt/exception
    //  split_instr is used to stop eip being changed.
    //................................................................................................

    assign split_instr  = D2L_control_signal[`SPLIT_INSTR];
    //latch$ atomic_latch(.d(atomic), .q(D2F_atomic), .r(reset), .s(set));
    latch$ split_instr_latch(.d(split_instr), .q(D2F_split_instr), .r(reset), .s(set));

    

    //------------------------------
    //
    //  Stall/Flush Logic
    //
    //------------------------------

    // stall, flush...
    decode_stall_logic stall_logic(
        .decode_failed(decode_failed),
        .other_stage_stall(L2D_stall),
        .other_stage_flush(X2D_flush),
        .F2D_valid(F2D_valid),
        .upc_stall(upc_stall),

        .D2L_valid(D2L_valid),
        .D2F_stall(D2F_stall),
        .D2F_stall_n(D2F_stall_n),
        .D2L_stall_n(D2L_stall_n)
    );
    
    assign D2F_decode_failed = decode_failed;

    debugger aaa_helper(
        .clk(clk),
        .D2L_current_eip(D2L_current_eip),
        .cs_ext(cs_ext),
        .cs_op(cs_opcode),
        .cs_split(cs_special),
        .cs_sel({upc_sel, op_ext_sel}),
        .cs_prefix(cs_prefix),
        .D2L_cs(D2L_control_signal),
        .D2L_v(D2L_valid),
        .stall_L2D(L2D_stall),
        .stall_D2F(D2F_stall),
        .upc(upc),
        .upc_valid(upc_sel)
    );

 endmodule


module debugger(
    clk,
    D2L_current_eip,
    cs_ext,
    cs_op,
    cs_split,
    cs_prefix,
    D2L_cs,
    D2L_v,
    stall_L2D,
    stall_D2F,
    cs_sel,
    upc,
    upc_valid
);

    input           clk;
    input [31:0]    D2L_current_eip;
    input [127:0]   cs_ext;
    input [127:0]   cs_op;
    input [127:0]   cs_split;
    input [127:0]   cs_prefix;
    input [127:0]   D2L_cs;
    input [7:0]     upc;
    input           upc_valid;
    input [1:0]     cs_sel;
    input           D2L_v;
    input           stall_L2D;
    input           stall_D2F;

    // get info about which ucode rom is selected
    reg CS_OPCODE;
    reg CS_EXT_OPCODE;
    reg CS_SPT_OPCODE;

    always@(*)
    begin
        case(cs_sel)
        2'b00:
        begin
            CS_OPCODE <= 1;
            CS_EXT_OPCODE <= 0;
            CS_SPT_OPCODE <= 0;
        end
        2'b01:
        begin
            CS_OPCODE <= 0;
            CS_EXT_OPCODE <= 1;
            CS_SPT_OPCODE <= 0;
        end
        2'b10:
        begin
            CS_OPCODE <= 0;
            CS_EXT_OPCODE <= 0;
            CS_SPT_OPCODE <= 1;
        end
        2'b11:
        begin
            CS_OPCODE <= 0;
            CS_EXT_OPCODE <= 0;
            CS_SPT_OPCODE <= 1;
        end
        endcase
    end

    wire [2:0] segr_index;
    assign segr_index = cs_prefix[`ADDR_SEGR_SEL];


endmodule


//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::                                                    ::
//::      Supporting Sub Modules of DECODE Module       ::  
//::                                                    ::
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

//----------------------------------------------
//  Prefix Logic
//  G1 - G4 prefix + opcode_size_marker
//  output: prefix_size (prefix_size + opcode_size)
//          opcode_size
//          control_signal(part of it is valid)
//              CS_REP
//              CS_SEGR_INDEX
//              CS_SEGR_OVERRIDE
//              CS_OPERAND_OVERRIDE
//----------------------------------------------
module prefix_logic(prefix, control_signal, prefix_size, opcode_size, pure_prefix_size, size_bitmap_neg);
    input [23:0]    prefix;

    output [`CS_NUM]    control_signal;
    output [1:0]        prefix_size;     // 0, 1, 2, 3
    output [1:0]        pure_prefix_size;     // 0, 1, 2, 3
    output              opcode_size;
    output [2:0]        size_bitmap_neg;
    //output              operand_size_sel;   // 0:32, 1:16 

    wire [7:0] prefix0; 
    wire [7:0] prefix1; 
    wire [7:0] prefix2; 
    
    assign prefix2 = prefix[7:0];
    assign prefix1 = prefix[15:8];
    assign prefix0 = prefix[23:16];

    //------------------------------- 
    // prefix_analyzer
    //------------------------------- 
    // segr_index is used to override addr_segr of control_signal
    wire [2:0] segr_index0;
    wire [2:0] segr_index1;
    wire [2:0] segr_index2;
    wire operand_size_sel0;
    wire operand_size_sel1;
    wire operand_size_sel2;
    wire cs_rep0;
    wire cs_rep1;
    wire cs_rep2;
    wire segr_override0;
    wire segr_override1;
    wire segr_override2;
    wire isPrefix0_neg;
    wire isPrefix1_neg;
    wire isPrefix2_neg;

    prefix_analyzer pa_0(
        .prefix_part(prefix0),
        .segr_override(segr_override0),
        .operand_size_sel(operand_size_sel0),
        .cs_rep(cs_rep0),         // cs_signal
        .cs_segr_index(segr_index0),  // cs_signal
        .isPrefix_neg(isPrefix0_neg)
    );

    prefix_analyzer pa_1(
        .prefix_part(prefix1),
        .segr_override(segr_override1),
        .operand_size_sel(operand_size_sel1),
        .cs_rep(cs_rep1),         // cs_signal
        .cs_segr_index(segr_index1),  // cs_signal
        .isPrefix_neg(isPrefix1_neg)
    );

    prefix_analyzer pa_2(
        .prefix_part(prefix2),
        .segr_override(segr_override2),
        .operand_size_sel(operand_size_sel2),
        .cs_rep(cs_rep2),         // cs_signal
        .cs_segr_index(segr_index2),  // cs_signal
        .isPrefix_neg(isPrefix2_neg)
    );
   

    //---------------------------------------
    // Output Prefix_Control_Signals 
    //---------------------------------------
    // since two opcode's 2nd opcode might be like prefixes, so we need to delete the wrong opcodes by finding out the number of prefixes and their locaion
    // 1. Prefix Bitmap
    // {isPrefix0, isPrefix1, isPrefix2}
    //  100 -> 100
    //  110 -> 110
    //  111 -> 111      //though no 3 prefix is detected in the list of instructions
    //  else-> 000

    wire [2:0] prefix_bitmap; // 110 -> first two are prefixes 
    wire [2:0] ffz_in;
    assign ffz_in = {isPrefix0_neg, isPrefix1_neg, isPrefix2_neg};
    continuous_zeros_priority3b ffz_0(prefix_bitmap, ffz_in);

    // 2. mask out ucode of wrong prefixes.
    //   prefix_bitmap: 100 ---> clear the value of last two one.
    wire [2:0] masked_segr_index0;   
    wire [2:0] masked_segr_index1;
    wire [2:0] masked_segr_index2;
    wire masked_operand_size_sel0;
    wire masked_operand_size_sel1;
    wire masked_operand_size_sel2;
    wire masked_cs_rep0;
    wire masked_cs_rep1;
    wire masked_cs_rep2;
    wire masked_segr_override0;
    wire masked_segr_override1;
    wire masked_segr_override2;

    // {isPrefix0, isPrefix1, isPrefix2}
    and3_1 and_0(masked_segr_index0, segr_index0, prefix_bitmap[2]);
    and3_1 and_1(masked_segr_index1, segr_index1, prefix_bitmap[1]);
    and3_1 and_2(masked_segr_index2, segr_index2, prefix_bitmap[0]);

    and2$ and_3(masked_operand_size_sel0, operand_size_sel0, prefix_bitmap[2]);
    and2$ and_4(masked_operand_size_sel1, operand_size_sel1, prefix_bitmap[1]);
    and2$ and_5(masked_operand_size_sel2, operand_size_sel2, prefix_bitmap[0]);

    and2$ and_6(masked_cs_rep0, cs_rep0, prefix_bitmap[2]);
    and2$ and_7(masked_cs_rep1, cs_rep1, prefix_bitmap[1]);
    and2$ and_8(masked_cs_rep2, cs_rep2, prefix_bitmap[0]);

    and2$ and_9(masked_segr_override0, segr_override0, prefix_bitmap[2]);
    and2$ and10(masked_segr_override1, segr_override1, prefix_bitmap[1]);
    and2$ and_11(masked_segr_override2, segr_override2, prefix_bitmap[0]);

    // 3. generate operand_size, cs_rep, segr_index, segr_override according to all the three prefix analyzers
    wire operand_size_sel;
    wire cs_rep;
    wire [2:0] segr_index;
    wire segr_override;
    or3$ or_0(operand_size_sel, masked_operand_size_sel0, masked_operand_size_sel1, masked_operand_size_sel2);
    or3$ or_1(cs_rep, masked_cs_rep0, masked_cs_rep1, masked_cs_rep2);
    or3_3_3 or_2(segr_index, masked_segr_index0, masked_segr_index1, masked_segr_index2);
    or3$ or_3(segr_override, masked_segr_override0, masked_segr_override1, masked_segr_override2);

     
    // 4. generate all control signals decided by prefix alone
    assign control_signal[`CS_OPERAND_SIZE_OVERRIDE] = operand_size_sel;
    assign control_signal[`CS_REP] = cs_rep;
    assign control_signal[`ADDR_SEGR_SEL2:`ADDR_SEGR_SEL0] = segr_index; 
    assign control_signal[`CS_SEGR_OVERRIDE] = segr_override;


    //------------------------------------------------
    //  Opcode-size Decoding
    //------------------------------------------------
    // since the opcode-size marker can be either 1st, 2nd, 3rd of the instruction, we need to speculate three possibilities.
    // if opcode-size marker is the second opcode, there must be one prefix, 
    // if opcode-size marker is the third opcode, there must be two prefixes.
    // if the opcode bitmap might be 
    // 000, 100, 010, 001, 
    // it must be complement with the prefix-bitmap... 
    // 100 -> 000, 010 -> 100, 001 -> 110

    wire [7:0]  opcode_part0;
    wire [7:0]  opcode_part1;
    wire [7:0]  opcode_part2;
    wire        opcode_size0;
    wire        opcode_size1;
    wire        opcode_size2;

    assign opcode_part0 = prefix0;
    assign opcode_part1 = prefix1;
    assign opcode_part2 = prefix2;
    
    // 1. compare opcode with 0F
    opcode_size_analyzer op_analyzer0(.opcode_part(opcode_part0), .opcode_size(opcode_size0));
    opcode_size_analyzer op_analyzer1(.opcode_part(opcode_part1), .opcode_size(opcode_size1));
    opcode_size_analyzer op_analyzer2(.opcode_part(opcode_part2), .opcode_size(opcode_size2));
    
    // 2. get the locations of the opcode_markers
    wire [2:0] opcode_marker_bitmap;  // since only one opcode-size marker is possible, so we use find_first_first method.
    wire [2:0] opcode_size_tmp;
    assign opcode_size_tmp = {opcode_size0, opcode_size1, opcode_size2};
    find_first_one3b ffo_opcode_size(opcode_marker_bitmap, opcode_size_tmp);        

    // 3. count the #byte of prefixes + opcode sizes
    // since never three prefixes occurs in the instruction, I can assume that the third byte of an instruction can and only can be a opcode-size marker, if it is not a opcode/...
    // since opcode_location won't have two contiguous 1s, if the first one is valid, so if we xor(prefix_bitmap, opcode_location), 
    // if the first one of size_bitmap is 1 and is a opcode_size marker, then the second won't be one.  ===> count continuous ones to find out the size of prefix (including opcode_size_marker)
    wire [2:0] size_bitmap_neg;        
    xnor2_3 xnor_0(size_bitmap_neg, prefix_bitmap, opcode_marker_bitmap);
    count_continuous_zeros3b ccz_0(prefix_size, size_bitmap_neg);

    // 4. use the prefix_size to select the opcode_size (if prefix is 0, 1, 2, 3)
    // prefix_bitmap:   000, 100, 110, 111
    // opcode_location: 000, 010, 000, 000
    //                  100, 00x, 001, 000
    //                   
    wire        opcode_size;
    count_continuous_ones3b count_pure_prefix(pure_prefix_size, prefix_bitmap);
    
    // prefix_bitmap[i] == 0 && opcode_marker_bitmap[i+1] == 1
    wire [2:0]  prefix_bitmap_neg;
    wire        op_size0;
    wire        op_size1;
    wire        op_size2;
    inv3 inv_prefix_bitmap(prefix_bitmap_neg, prefix_bitmap);
    nand2$ nand_op_0(op_size0, prefix_bitmap[1], opcode_marker_bitmap[0]);
    nand2$ nand_op_1(op_size1, prefix_bitmap[2], opcode_marker_bitmap[1]);
    nand2$ nand_op_2(op_size2, 1'b1, opcode_marker_bitmap[2]);
    nand3$ nand_op_3(opcode_size, op_size0, op_size1, op_size2);

 endmodule


//------------------------------------
//
//  *PREFIX* 
//  Operand_size ov
//  Segr_index ov
//  Repeat prefix
//
//-------------------------------------

 module prefix_analyzer(
    prefix_part,
    segr_override,
    operand_size_sel,
    cs_rep,         // cs_signal
    cs_segr_index,   // cs_signal
    isPrefix_neg
);
    input [7:0]     prefix_part;

    output          operand_size_sel;
    output          segr_override;
    output [2:0]    cs_segr_index;
    output          cs_rep;
    output          isPrefix_neg;      // 1: this byte is prefix
    // control signal (calling prefix_cs):
    //  SEGR_INDEX      override
    //  REP             or logic because no other will set it

    // all 8 possible values of prefix:
    //  - 2EH   CS      // seg od
    //  - 36H   SS
    //  - 3EH   DS
    //  - 26H   ES
    //  - 63H   FS
    //  - 65H   GS  
    //  - F3H   REP, or REPE/REPZ   
    //  - 66H   32bi6 -> 16bit
    parameter CS = 8'h2E;
    parameter SS = 8'h36;
    parameter DS = 8'h3E;
    parameter ES = 8'h26;
    parameter FS = 8'h64;
    parameter GS = 8'h65;
    parameter REP = 8'hF3;
    parameter OP_SIZE = 8'h66;

    
    //-------------------------------
    //  Segment Override
    //-------------------------------
    wire [5:0]  segr_cmp;
    wire        cmp_rep;
    wire        cmp_op_size;
    wire [7:0]  prefix_buf;
    
    buffer8$ buffer_prefix(prefix_buf, prefix_part);
    cmp8b cmp_0(segr_cmp[`CS], prefix_buf, CS);
    cmp8b cmp_1(segr_cmp[`SS], prefix_buf, SS);
    cmp8b cmp_2(segr_cmp[`DS], prefix_buf, DS);
    cmp8b cmp_3(segr_cmp[`ES], prefix_buf, ES);
    cmp8b cmp_4(segr_cmp[`FS], prefix_buf, FS);
    cmp8b cmp_5(segr_cmp[`GS], prefix_buf, GS);

    // decide segment index + whether or not segr_override
    pencoder8_3v$ segr_analyzer(.enbar(1'b0), .X({2'b0, segr_cmp}), .Y(cs_segr_index)); 
    
    // segr_override // if any match of the 6 segr_prefixes
    wire segr_override0;
    wire segr_override1;
    nor3$ nor_segr_override0(segr_override0, segr_cmp[0], segr_cmp[1], segr_cmp[2]);
    nor3$ nor_segr_override1(segr_override1, segr_cmp[3], segr_cmp[4], segr_cmp[5]);
    nand2$ nand2_segr_override(segr_override, segr_override0, segr_override1);
              
    // segr override or not
    //and3$ and_0(cmp_012, cmp0, cmp1, cmp2);
    //and3$ and_1(cmp_345. cmp3, cmp4, cmp5);
    //and2$ and_2(segr_override, cmp_012, cmp_456);  
    
    //-------------------------------
    //  Operand Size
    //------------------------------- 
    cmp8b cmp_6(cmp_op_size, prefix_part, OP_SIZE);
    assign operand_size_sel = cmp_op_size;

    //------------------------------- 
    //  REP 
    //------------------------------- 
    cmp8b cmp_7(cmp_rep, prefix_part, REP);
    assign cs_rep = cmp_rep;

    
    // Decide whether it is prefix
    wire isPrefix_0;        // cs_rep OR operand_size_sel
    or2$ or_isPrefix_0(isPrefix_0, operand_size_sel, cs_rep);

    nor2$ or_is_prefix(isPrefix_neg, segr_override, isPrefix_0);

 endmodule


//----------------------------------------------
// Opcode *MARKER*
// Decidde One or Two Byte Opcode
// Assumption of this analyzer:
//  no three opcode in the manual
//  no three prefixes  =>  prefix + two_opcode_marker <= 3
//----------------------------------------------
module opcode_size_analyzer(opcode_part, opcode_size);
    input [7:0] opcode_part;
    output opcode_size;     //0: one byte 1: two byte

    parameter TWO_OPCODE_MARKER = 8'h0F;

    // compare the possible opcode with 0FH
    cmp8b cmp_0(opcode_size, opcode_part, TWO_OPCODE_MARKER);
endmodule



//------------------------------------------
//
//  *MOD_R/M* 
//
//------------------------------------------

// < 1ns
module modrm_analyzer(
    modrm, 
    sib_exist,
    gpr_reg_id,
    base_reg_id,
    segr_reg_id,
    disp_size,
    disp_sel,
    mod,
    mem_or_reg,             // if r/m is reg => 0, else => 1
    need_base_reg
);
    input [7:0] modrm;
    output sib_exist;
    output [2:0] gpr_reg_id;
    output [2:0] base_reg_id;
    output [2:0] segr_reg_id;
    output [2:0] disp_size;
    output [1:0] disp_sel;
    output [1:0] mod;
    output       mem_or_reg;        // r/m is reg or m
    
    output       need_base_reg;
    //output       need_gpr_reg;    decided by opcode

    wire [2:0] reg_op;
    wire [2:0] r_m;

    assign mod = modrm[7:6];
    assign reg_op = modrm[5:3];
    assign r_m = modrm[2:0];
    
    // lookup map for mod and r/m
    //  sib_exist
    //  r/m == 100 && mod != 11
    wire r_m_100; 
    wire mod_no_11;
    wire mod_is_11;
    cmp3b cmp_0(r_m_100, r_m, 3'b100);
    nand2$ nand_0(mod_no_11, mod[1], mod[0]);       // if mod != 11, => reg => mem_or_reg = 1;
    and2$ and_mod11(mod_is_11, mod[1], mod[0]);       // if mod != 11, => reg => mem_or_reg = 1;
    and2$ and_0(sib_exist, r_m_100, mod_no_11);

    //----------------------------
    //  disp_size
    //----------------------------
    // mod :
    // 00 -> 000 // or if r_m = 101->100
    // 01 -> 001
    // 10 -> 100
    // 11 -> 000
    wire r_m_101_neg;
    wire mod_00_neg;
    wire disp32_special_case;
    // mod == 00
    or2$ nor_mod_00(mod_00_neg, mod[0], mod[1]);      //0.45
    // r/m == 101
    cmp3bL cmp_r_m_101_neg(r_m_101_neg, r_m, 3'b101);    //0.45
    // mod == 00 && r/m = 101
    nor2$ and_disp32_first_case(disp32_special_case, mod_00_neg, r_m_101_neg); //0.2 
    // mod[1] != mod[0]  
    xor2$ xor_0(disp_size0_t, mod[0], mod[1]);          //0.25
    //or2$ or_disp_size0(disp_size[0], disp_size0_t, disp32_special_case); // 0.35
    cmp2b cmp_disp_size0(disp_size[0], mod, 2'b01);
    wire mod_10;
    // mod[0] != 1
    cmp2b cmp_mod_10(mod_10, mod, 2'b10);
    //or2$ or_disp_size1(disp_size[1], mod_10, disp32_special_case);
    assign disp_size[1] = 0;
    //
    //wire disp_size2_t;
    //nand2$ nand_disp_size_t(disp_size2_t, mod[1], mod[0]);
    //nand2$ nand_disp_size(disp_size[2], disp_size2_t, disp32_special_case);
    or2$ or_disp_size2(disp_size[2], mod_10, disp32_special_case);


    // 00 -> 00 special_case 11
    // 01 -> 01
    // 10 -> 11 
    // 11 -> 00
    assign disp_sel[0] = mod[0] ^ mod[1];
    assign disp_sel[1] = mod_10 | disp32_special_case; 
    


    //  segr_index
    // default segrment:
    // esp, ebp --> ss
    // all others --> ds
    wire base_is_ebp_n;
    //wire segr_ss_sel;
    //cmp3bL cmp_esp(base_is_esp, r_m, `ESP);
    cmp3bL cmp_ebp(base_is_ebp_n, r_m, `EBP);
    //nand2$ or_ss_sel(segr_ss_sel, base_is_ebp, base_is_esp);

    mux2_3 mux_segr_index(segr_reg_id, `SS, `DS, base_is_ebp_n);
    
    // sib_exist --> decided by sib
     
    assign base_reg_id = r_m; 
    assign gpr_reg_id = reg_op;
    
    // need base reg
    // r/m ! 101 and  mod==!11
    // 0.25 + 0.2 = 0.45
    wire r_m_no_101;
    cmp3bL cmp_r_m_101(r_m_no_101, r_m, 3'b101);
    assign need_base_reg = mod_no_11;
    //and2$ and_need_base_reg(need_base_reg, mod_no_11, r_m_no_101);

    assign mem_or_reg = mod_no_11;
    assign mem_or_reg_n = mod_is_11;

endmodule



//--------------------------
//  Analyze *SIB*
//
//--------------------------
module sib_analyzer(
    mod,
    sib, 
    index_reg_id, 
    scale,
    base_reg_id,
    need_base_reg,
    segr_reg_id,
    index_reg_id
);
    input [7:0] sib;
    input [1:0] mod;
    
    output [1:0] scale; 
    output [2:0] base_reg_id;
    output [2:0] index_reg_id;
    output [2:0] segr_reg_id;
    output       need_base_reg;

    wire [1:0] ss;
    assign scale = sib[7:6];
    assign index_reg_id = sib[5:3];
    assign base_reg_id = sib[2:0];

    wire index_is_ebp_n;
    wire base_is_esp_n;
    wire use_ss_segr;
    cmp3bL cmp_esp(base_is_esp_n, base_reg_id, `ESP);
    cmp3bL cmp_ebp(index_is_ebp_n, index_reg_id, `EBP);
    nand2$ or_use_segr(use_ss_segr, base_is_esp_n, index_is_ebp_n);
    mux2_3 mux_segr_index(segr_reg_id, `DS, `SS, use_ss_segr);

    // if base = 101 && mod = 00, there is no base_reg;
    wire base_101;
    wire mod_00;
    cmp3b cmp_base(base_101, base_reg_id, 3'b101);
    cmp2b cmp_mod(mod_00, mod, 2'b00);
    nand2$ nand_base_reg(need_base_reg, base_101, mod_00);
    
endmodule


//---------------------------------
//
//  Analyze *BOTH* ModR/M and SIB
//
//
//---------------------------------
module modrm_sib_analyzer(
    opcode,
    modrm,
    sib,
    op_ext_exist,
    gpr_reg_id,         // reg referenced by modR/M's reg part.
    base_reg_id,        // reg referenced by modR/M's r/m part
    segr_reg_id,        
    index_reg_id,
    disp_size,
    disp_sel,
    need_base_reg,
    need_index_reg,
    scale,
    cs_ext,
    modsib_disp_size,
    mem_or_reg,
    modsib_size

);
    input [7:0] modrm;
    input [7:0] sib;
    input       op_ext_exist;
    input [7:0] opcode;
    

    output [2:0]  gpr_reg_id;
    output [2:0]  base_reg_id;
    output [2:0]  segr_reg_id;
    output [2:0]  index_reg_id;
    output [2:0]  disp_size;
    output [1:0]  disp_sel;
    output        need_base_reg;
    output        need_index_reg;
    output [1:0]  scale;
    output [`CS_NUM] cs_ext;
    output [3:0]  modsib_disp_size;         // actually, it means mod sib disp's total size (0 -- 6)
    output [1:0]  modsib_size;
    output        mem_or_reg;               // if mod==11, use r/m as reg, else, use r/m as mem

    wire [1:0]  mod; 
    wire        sib_exist;
    
    //wire [7:0] modrm0;
    //wire [7:0] modrm1;
    //wire [7:0] sib0;
    //wire [7:0] sib1;
    
    wire [2:0] mod_base_reg_id;
    wire [2:0] mod_segr_reg_id;
    wire [2:0] mod_gpr_reg_id;
    wire [2:0] mod_disp_size;
    wire [1:0] mod_disp_sel;
    wire       mod_need_base_reg;
    modrm_analyzer modrm_logic(
        .modrm(modrm), 
        .sib_exist(sib_exist),
        .gpr_reg_id(mod_gpr_reg_id),
        .base_reg_id(mod_base_reg_id),
        .segr_reg_id(mod_segr_reg_id),
        .disp_size(mod_disp_size),
        .disp_sel(mod_disp_sel),
        .mod(mod),
        .mem_or_reg(mem_or_reg),
        .need_base_reg(mod_need_base_reg)
    );
     
    //------------------------------- 
    // SiB    Decoding
    //-------------------------------
    // SIB might change the segr_id, need_segr   
    
   wire [1:0] sib_scale;
   wire [2:0] sib_base_reg_id;
   wire [2:0] sib_index_reg_id;
   wire [2:0] sib_segr_reg_id;

   sib_analyzer sib_logic(
        .sib(sib), 
        .mod(mod),
        .scale(sib_scale),
        .base_reg_id(sib_base_reg_id),
        .index_reg_id(sib_index_reg_id),
        .segr_reg_id(sib_segr_reg_id)
    );

    // combine the ucode of sib and mod
    // sib_exist
    
    // disp_size
    assign disp_size = mod_disp_size;
    assign disp_sel  = mod_disp_sel;
    // scale
    assign scale = sib_scale;
    // base_reg_id
    mux2_3 mux_base_reg(base_reg_id, mod_base_reg_id, sib_base_reg_id, sib_exist);
    // index_reg_id
    assign index_reg_id = sib_index_reg_id;
    // gpr_reg_id
    assign gpr_reg_id = mod_gpr_reg_id;
    // segr_reg_id
    mux2_3 mux_segr_reg(segr_reg_id, mod_segr_reg_id, sib_segr_reg_id, sib_exist);
    
    // need_base_reg
    mux2$ mux_need_base(need_base_reg, mod_need_base_reg, 1'b1, sib_exist);
    // need_index_reg
    assign need_index_reg = sib_exist; 


    //----------------------------------
    //
    //-----------------------------------

    // if sib_exist -> 2  else -> 1
    // 1 -> 10
    // 0 -> 01
    wire [1:0] modsib_size;
    mux2_2 mux_modsib_size(modsib_size, 2'b01, 2'b10, sib_exist); 
    

    //--------------------------------------
    //  opcode extension analyzer
    //--------------------------------------
    wire [2:0]  opcode_extension;    // /0 - /7
    assign opcode_extension = modrm[5:3];
    
    // the index of extension opcode is /digit
    // 000_000 - 000_111 (00 - 07 is used by opcode_ext)
    // 111_000 - 111_111 (70 - 77) is used by exception/interrupt
    // others are used by split instructions
    wire [6:0] ext_op_index;  // 7 bit index to the ext op_map
    assign ext_op_index[3] = opcode[4];
    assign ext_op_index[2:0] = opcode[2:0];
    assign ext_op_index[6:4] = opcode_extension;

    rom128b128w extension_op_map(.A(ext_op_index), .OE(op_ext_exist), .DOUT(cs_ext));
    
    initial
    begin
        // extension opcode map
        // map_00: low  64 bits 
        // map_01: high 64 bits
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_ext_00.list", extension_op_map.rom0.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_ext_01.list", extension_op_map.rom0.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_ext_10.list", extension_op_map.rom1.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_ext_11.list", extension_op_map.rom1.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_ext_20.list", extension_op_map.rom2.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_ext_21.list", extension_op_map.rom2.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_ext_30.list", extension_op_map.rom3.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map_ext_31.list", extension_op_map.rom3.rom1.mem);
    end

    adder4b adder_modsib_disp(modsib_disp_size, {2'b0, modsib_size}, {1'b0, disp_size}, 1'b0);
endmodule


// The location of the literal is correct because of the shifting of the instruction, however, we don't have a smart output module that can exact 8, or 32 bits according to the disp_size. 
module literal_analyzer(
       literal,
       disp_sel,
       disp_part,
       imm_part
);
    input [63:0] literal;
    input [1:0] disp_sel;

    output [31:0] disp_part;
    output [31:0] imm_part;

    wire [31:0] imm_part0;
    wire [31:0] imm_part1;
    wire [31:0] imm_part2;
    wire [31:0] imm_part3;
    
    // the location of displacement is fixed
    // little endian
    assign disp_part[7:0] = literal[63:63-`BYTE+1];
    assign disp_part[15:8] = literal[63-`BYTE:63-2*`BYTE+1];
    assign disp_part[23:16] = literal[63-2*`BYTE:63-3*`BYTE+1];
    assign disp_part[31:24] = literal[63-3*`BYTE:32];

    assign imm_part0[7:0] = literal[63:63-`BYTE+1];
    assign imm_part0[15:8] = literal[63-`BYTE:63-2*`BYTE+1];
    assign imm_part0[23:16] = literal[63-2*`BYTE:63-3*`BYTE+1];
    assign imm_part0[31:24] = literal[63-3*`BYTE:32];
   
    assign imm_part1[7:0]  = literal[63-`BYTE:63-2*`BYTE+1];
    assign imm_part1[15:8] = literal[63-2*`BYTE:63-3*`BYTE+1];
    assign imm_part1[23:16] = literal[63-3*`BYTE:32];
    assign imm_part1[31:24] = literal[31:31-`BYTE+1];
    
    assign imm_part2[7:0] = literal[63-2*`BYTE:63-3*`BYTE+1];
    assign imm_part2[15:8] = literal[63-3*`BYTE:32];
    assign imm_part2[23:16] = literal[31:31-`BYTE+1];
    assign imm_part2[31:24] = literal[31-`BYTE:31-2*`BYTE+1];
 
    assign imm_part3[7:0] = literal[31:24];
    assign imm_part3[15:8] = literal[23:16];
    assign imm_part3[23:16] = literal[15:8];
    assign imm_part3[31:24] = literal[7:0];
  
    //assign imm_part3[7:0] = literal[31:31-`BYTE+1];
    //assign imm_part3[15:8] = literal[31-`BYTE+1:31-2*`BYTE+1];
    //assign imm_part3[23:16] = literal[31-2*`BYTE:31-3*`BYTE+1];
    //assign imm_part3[31:24] = literal[7:0];
 
    // select imm according to imm_size
    mux4_32 mux_imm(imm_part, imm_part0, imm_part1, imm_part2, imm_part3, disp_sel[0], disp_sel[1] ); 

endmodule




//-------------------------------------------
//
//  Use Opcode Part of the Instruction 
//  to access ROM 
//  Output: one opcode map & two opcode map
//
//-------------------------------------------

module opcode_analyzer(opcode, cs_one_op, cs_two_op, opcode_size);
    input  [7:0]     opcode;
    input            opcode_size;
    output [`CS_NUM] cs_one_op; 
    output [`CS_NUM] cs_two_op; 

    // one-byte opcode lookup
    rom128b256w one_byte_op_map(.A(opcode), .OE(1'b1), .DOUT(cs_one_op));
    // two-byte opcode lookup
    rom128b256w two_byte_op_map(.A(opcode), .OE(1'b1), .DOUT(cs_two_op));
     
    initial 
    begin
     // one-byte opcode map
        // low 64 bits of one-opcode map
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_00.list", one_byte_op_map.rom0.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_10.list", one_byte_op_map.rom1.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_20.list", one_byte_op_map.rom2.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_30.list", one_byte_op_map.rom3.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_40.list", one_byte_op_map.rom4.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_50.list", one_byte_op_map.rom5.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_60.list", one_byte_op_map.rom6.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_70.list", one_byte_op_map.rom7.rom0.mem);
        
        // high 64 bits of one-opcode map
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_01.list", one_byte_op_map.rom0.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_11.list", one_byte_op_map.rom1.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_21.list", one_byte_op_map.rom2.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_31.list", one_byte_op_map.rom3.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_41.list", one_byte_op_map.rom4.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_51.list", one_byte_op_map.rom5.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_61.list", one_byte_op_map.rom6.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map1_71.list", one_byte_op_map.rom7.rom1.mem);

        // two-byte/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/ opcode map
        // low 64 bits of one-opcode map
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_00.list", two_byte_op_map.rom0.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_10.list", two_byte_op_map.rom1.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_20.list", two_byte_op_map.rom2.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_30.list", two_byte_op_map.rom3.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_40.list", two_byte_op_map.rom4.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_50.list", two_byte_op_map.rom5.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_60.list", two_byte_op_map.rom6.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_70.list", two_byte_op_map.rom7.rom0.mem);

        // high 64 bits of two-opcode map
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_01.list", two_byte_op_map.rom0.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_11.list", two_byte_op_map.rom1.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_21.list", two_byte_op_map.rom2.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_31.list", two_byte_op_map.rom3.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_41.list", two_byte_op_map.rom4.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_51.list", two_byte_op_map.rom5.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_61.list", two_byte_op_map.rom6.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_71.list", two_byte_op_map.rom7.rom1.mem);
        
        /*
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_00.list", two_byte_op_map.rom0.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_10.list", two_byte_op_map.rom1.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_20.list", two_byte_op_map.rom2.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_30.list", two_byte_op_map.rom3.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_40.list", two_byte_op_map.rom4.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_50.list", two_byte_op_map.rom5.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_60.list", two_byte_op_map.rom6.rom0.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_70.list", two_byte_op_map.rom7.rom0.mem);

        // high 64 bits of two-opcode map
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_01.list", two_byte_op_map.rom0.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_11.list", two_byte_op_map.rom1.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_21.list", two_byte_op_map.rom2.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_31.list", two_byte_op_map.rom3.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_41.list", two_byte_op_map.rom4.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_51.list", two_byte_op_map.rom5.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_61.list", two_byte_op_map.rom6.rom1.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/dump_cs/op_map2_71.list", two_byte_op_map.rom7.rom1.mem);
        */
    end    

endmodule
    
//  000 -> 1110
//  001 -> 1101
//  011 -> 1011
//  111 -> 0111
//  101 -> 0111
//  time: 0.15 + 0.25 = 0.4
module size_bitmap2cs_op_sel(out, in);
    input [2:0]     in;
    output [3:0]    out;

    wire [2:0]  in_neg;
    inv3 inv_0(in_neg, in);
    
    or3$ or_0(out[0], in[2], in[1], in[0]);
    nand3$ nand_0(out[1], in_neg[2], in_neg[1], in[0]);
    nand3$ nand_1(out[2], in_neg[2], in[1], in[0]);
    inv1$ inv_1(out[3], in[2]);

endmodule

//----------------------------------------
//
//  Decode Stall Logic
//  All *VALID*, *STALL* signal 
//  is generated by this module
//
//----------------------------------------
// stall/flush decode stage
// 1. other stage's stall flush signal
// 2. decode failed
module decode_stall_logic(
    decode_failed,
    other_stage_stall,
    other_stage_flush,
    F2D_valid,
    upc_stall,

    D2L_valid,
    D2L_stall_n,
    D2F_stall_n,
    D2F_stall
);
    input decode_failed;
    input other_stage_stall;
    input other_stage_flush;
    input F2D_valid;
    input upc_stall;
    
    output D2L_valid;
    output D2L_stall_n;
    output D2F_stall;
    output D2F_stall_n;

    wire other_stage_flush_n;
    wire other_stage_stall_n;
    wire D_valid;               // decode itself is valid or not.
    inv1$ inv_flush(other_stage_flush_n, other_stage_flush);
    inv1$ inv_stall(other_stage_stall_n, other_stage_stall);

    // 1. bubble 
    //   a. whenever later gives a flush signal, you must invalidate the valid_signal
    //          actually, only Write_back stage will generate flush signal
    //   b. for decode stage, it should invalidate when decode_failed.
    //   c. propagate F2D valid signal
    nor2$ nor_decode_valid(D_valid, decode_failed, other_stage_flush);
    and2$ and_D2L_valid(D2L_valid, D_valid, F2D_valid);

    // 2. stall
    // only right stages can stall the pipeline_reg, decode itself cannot
    // if flush is active, it cannot stall
    // other_stall_n = 0, && flush == 0         
    // OR other_stall = 1 && flush_n = 1
    wire stall;
    nor2$ nor_stall(stall, other_stage_stall_n, other_stage_flush);
    nand2$ nand_stall(D2L_stall_n, other_stage_stall, other_stage_flush_n);

    // if other stall D, then stall F
    or2$ or_D2F_stall(D2F_stall,stall, upc_stall);
    nor2$ nor_D2F_stall(D2F_stall_n,stall, upc_stall);

endmodule

