`include "VX_define.vh"
// TODO: move VX_define constants to parameters, and then parameterize in blackbox

module Vortex #(
    parameter CORE_ID = 0
) (        

    /* adapt to CoreIO bundle at src/main/scala/tile/Core.scala */

    input         clock,
    input         reset,
    input         hartid,
    input  [31:0] reset_vector,
    input         interrupts_debug,
    input         interrupts_mtip,
    input         interrupts_msip,
    input         interrupts_meip,
    input         interrupts_seip,

    input         imem_a_ready, // TODO: assert true
    input         imem_d_valid,
    input  [2:0]  imem_d_bits_opcode,
    input  [1:0]  imem_d_bits_param,
    input  [3:0]  imem_d_bits_size,
    input  [7:0]  imem_d_bits_source,
    input  [2:0]  imem_d_bits_sink,
    input         imem_d_bits_denied,
    input  [31:0] imem_d_bits_data,
    input         imem_d_bits_corrupt,
    output        imem_a_valid,
    output [2:0]  imem_a_bits_opcode,
    output [2:0]  imem_a_bits_param,
    output [3:0]  imem_a_bits_size,
    output [7:0]  imem_a_bits_source,
    output [31:0] imem_a_bits_address,
    output [3:0]  imem_a_bits_mask,
    output [31:0] imem_a_bits_data,
    output        imem_a_bits_corrupt,
    output        imem_d_ready,

    input         dmem_a_ready,
    input         dmem_d_valid,
    input  [2:0]  dmem_d_bits_opcode,
    input  [1:0]  dmem_d_bits_param,
    input  [3:0]  dmem_d_bits_size,
    input  [7:0]  dmem_d_bits_source,
    input  [2:0]  dmem_d_bits_sink,
    input         dmem_d_bits_denied,
    input  [31:0] dmem_d_bits_data,
    input         dmem_d_bits_corrupt,
    output        dmem_a_valid,
    output [2:0]  dmem_a_bits_opcode,
    output [2:0]  dmem_a_bits_param,
    output [3:0]  dmem_a_bits_size,
    output [7:0]  dmem_a_bits_source,
    output [31:0] dmem_a_bits_address,
    output [3:0]  dmem_a_bits_mask,
    output [31:0] dmem_a_bits_data,
    output        dmem_a_bits_corrupt,
    output        dmem_d_ready,

    input         fpu_fcsr_flags_valid,
    input  [4:0]  fpu_fcsr_flags_bits,
    // input  [63:0] fpu_store_data,
    input  [31:0] fpu_toint_data,
    input         fpu_fcsr_rdy,
    input         fpu_nack_mem,
    input         fpu_illegal_rm,
    input         fpu_dec_wen,
    input         fpu_dec_ldst,
    input         fpu_dec_ren1,
    input         fpu_dec_ren2,
    input         fpu_dec_ren3,
    input         fpu_dec_swap12,
    input         fpu_dec_swap23,
    input  [1:0]  fpu_dec_typeTagIn,
    input  [1:0]  fpu_dec_typeTagOut,
    input         fpu_dec_fromint,
    input         fpu_dec_toint,
    input         fpu_dec_fastpipe,
    input         fpu_dec_fma,
    input         fpu_dec_div,
    input         fpu_dec_sqrt,
    input         fpu_dec_wflags,
    input         fpu_sboard_set,
    input         fpu_sboard_clr,
    input  [4:0]  fpu_sboard_clra,

    output        fpu_hartid,
    output [31:0] fpu_time,
    output [31:0] fpu_inst,
    output [31:0] fpu_fromint_data,
    output [2:0]  fpu_fcsr_rm,
    output        fpu_dmem_resp_val,
    output [2:0]  fpu_dmem_resp_type,
    output [4:0]  fpu_dmem_resp_tag,
    output        fpu_valid,
    output        fpu_killx,
    output        fpu_killm,
    output        fpu_keep_clock_enabled,

    output        cease,

    input         traceStall,
    output        wfi
);
`ifdef PERF_ENABLE
    VX_perf_memsys_if perf_memsys_if();
`endif

    /* interrupts */

    /* imem */
    assign icache_rsp_if.valid = imem_d_valid;
    assign icache_rsp_if.data = imem_d_bits_data;
    assign icache_rsp_if.tag = imem_d_bits_source;
    assign imem_d_ready = icache_rsp_if.ready;
    // always @(posedge clock) begin
    //     if (icache_req_if.valid && icache_req_if.ready)
    //         icache_rsp_if.tag <= icache_req_if.tag;
    // end
    assign imem_a_bits_source = icache_req_if.tag[7:0];
    assign imem_a_valid = icache_req_if.valid;
    assign imem_a_bits_address = icache_req_if.addr;
    assign icache_req_if.ready = imem_a_ready;

    assign imem_a_bits_data = 32'd0;
    assign imem_a_bits_mask = 4'd0;
    assign imem_a_bits_corrupt = 1'b0;
    assign imem_a_bits_param = 3'd0;
    assign imem_a_bits_size = 4'd2; // 32b
    assign imem_a_bits_opcode = 3'd4; // Get

    /* dmem */
    assign dcache_rsp_if.valid = dmem_d_valid;
    assign dcache_rsp_if.data = dmem_d_bits_data;
    assign dcache_rsp_if.tag = dmem_d_bits_source;
    assign dcache_rsp_if.tmask = 'd0; // TODO
    assign dmem_d_ready = dcache_rsp_if.ready;

    assign dmem_a_valid = dcache_req_if.valid;
    assign dmem_a_bits_address = dcache_req_if.addr;
    assign dmem_a_bits_source = dcache_req_if.tag[7:0];
    assign dmem_a_bits_data = dcache_req_if.data;
    assign dmem_a_bits_opcode = dcache_req_if.rw ? 3'd4 /*Get*/ : 3'd0 /*PutFull*/; // rw = ~wb
    assign dmem_a_bits_size = $countones(dcache_req_if.byteen) === 'd4 ? 2'd2 :
        ($countones(dcache_req_if.byteen) === 'd2 ? 2'd1 : 2'd0); // TODO
    assign dmem_a_bits_mask = 4'(dcache_req_if.byteen >> (dcache_req_if.addr[5:2] << 2));
    assign dcache_req_if.ready = dmem_a_ready;

    assign dmem_a_bits_corrupt = 1'b0;
    assign dmem_a_bits_param = 3'd0;

    /* fpu */

    assign {fpu_hartid, fpu_time, fpu_inst, fpu_fromint_data, fpu_fcsr_rm, fpu_dmem_resp_val, fpu_dmem_resp_type,
            fpu_dmem_resp_tag, fpu_valid, fpu_killx, fpu_killm, fpu_keep_clock_enabled} = '0;

    assign cease = 1'b0;
    assign wfi = 1'b0; // what is this?

    VX_dcache_req_if #(
        .NUM_REQS  (`DCACHE_NUM_REQS),
        .WORD_SIZE (`DCACHE_WORD_SIZE),
        .TAG_WIDTH (`DCACHE_CORE_TAG_WIDTH)
    ) dcache_req_if();

    VX_dcache_rsp_if #(
        .NUM_REQS  (`DCACHE_NUM_REQS),
        .WORD_SIZE (`DCACHE_WORD_SIZE), 
        .TAG_WIDTH (`DCACHE_CORE_TAG_WIDTH)
    ) dcache_rsp_if();
    
    VX_icache_req_if #(
        .WORD_SIZE (`ICACHE_WORD_SIZE), 
        .TAG_WIDTH (`ICACHE_CORE_TAG_WIDTH)
    ) icache_req_if();

    VX_icache_rsp_if #(
        .WORD_SIZE (`ICACHE_WORD_SIZE), 
        .TAG_WIDTH (`ICACHE_CORE_TAG_WIDTH)
    ) icache_rsp_if();
    
    VX_pipeline #(
        .CORE_ID(CORE_ID)
    ) pipeline (
        `SCOPE_BIND_VX_core_pipeline
    `ifdef PERF_ENABLE
        .perf_memsys_if (perf_memsys_if),
    `endif

        .clk(clock),
        .reset(reset),

        // Dcache core request
        .dcache_req_valid   (dcache_req_if.valid),
        .dcache_req_rw      (dcache_req_if.rw),
        .dcache_req_byteen  (dcache_req_if.byteen),
        .dcache_req_addr    (dcache_req_if.addr),
        .dcache_req_data    (dcache_req_if.data),
        .dcache_req_tag     (dcache_req_if.tag),
        .dcache_req_ready   (dcache_req_if.ready),

        // Dcache core reponse    
        .dcache_rsp_valid   (dcache_rsp_if.valid),
        .dcache_rsp_tmask   (dcache_rsp_if.tmask),
        .dcache_rsp_data    (dcache_rsp_if.data),
        .dcache_rsp_tag     (dcache_rsp_if.tag),
        .dcache_rsp_ready   (dcache_rsp_if.ready),

        // Icache core request
        .icache_req_valid   (icache_req_if.valid),
        .icache_req_addr    (icache_req_if.addr),
        .icache_req_tag     (icache_req_if.tag),
        .icache_req_ready   (icache_req_if.ready),

        // Icache core reponse    
        .icache_rsp_valid   (icache_rsp_if.valid),
        .icache_rsp_data    (icache_rsp_if.data),
        .icache_rsp_tag     (icache_rsp_if.tag),
        .icache_rsp_ready   (icache_rsp_if.ready),

        // Status
        .busy(/* ignored */)
    );  

endmodule : Vortex





