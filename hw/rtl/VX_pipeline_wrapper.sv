`include "VX_define.vh"
// TODO: move VX_define constants to parameters, and then parameterize in blackbox

module Vortex #(
    parameter CORE_ID = 0
) (        

    /* adapt to CoreIO bundle at src/main/scala/tile/Core.scala */

    input         clock,
    input         reset,
    // input         hartid,
    input  [31:0] reset_vector,
    input         interrupts_debug,
    input         interrupts_mtip,
    input         interrupts_msip,
    input         interrupts_meip,
    input         interrupts_seip,

    input         imem_0_a_ready,
    input         imem_0_d_valid,
    input  [2:0]  imem_0_d_bits_opcode,
    input  [1:0]  imem_0_d_bits_param,
    input  [3:0]  imem_0_d_bits_size,
    input  [9:0]  imem_0_d_bits_source,
    input  [2:0]  imem_0_d_bits_sink,
    input         imem_0_d_bits_denied,
    input  [31:0] imem_0_d_bits_data,
    input         imem_0_d_bits_corrupt,
    output        imem_0_a_valid,
    output [2:0]  imem_0_a_bits_opcode,
    output [2:0]  imem_0_a_bits_param,
    output [3:0]  imem_0_a_bits_size,
    output [9:0]  imem_0_a_bits_source,
    output [31:0] imem_0_a_bits_address,
    output [3:0]  imem_0_a_bits_mask,
    output [31:0] imem_0_a_bits_data,
    output        imem_0_a_bits_corrupt,
    output        imem_0_d_ready,

    input         dmem_0_a_ready,
    input         dmem_0_d_valid,
    input  [2:0]  dmem_0_d_bits_opcode,
    // input  [1:0]  dmem_0_d_bits_param,
    input  [3:0]  dmem_0_d_bits_size,
    input  [9:0]  dmem_0_d_bits_source,
    // input  [2:0]  dmem_0_d_bits_sink,
    // input         dmem_0_d_bits_denied,
    input  [31:0] dmem_0_d_bits_data,
    // input         dmem_0_d_bits_corrupt,
    output        dmem_0_a_valid,
    output [2:0]  dmem_0_a_bits_opcode,
    // output [2:0]  dmem_0_a_bits_param,
    output [3:0]  dmem_0_a_bits_size,
    output [9:0]  dmem_0_a_bits_source,
    output [31:0] dmem_0_a_bits_address,
    output [3:0]  dmem_0_a_bits_mask,
    output [31:0] dmem_0_a_bits_data,
    // output        dmem_0_a_bits_corrupt,
    output        dmem_0_d_ready,

    input         dmem_1_a_ready,
    input         dmem_1_d_valid,
    input  [2:0]  dmem_1_d_bits_opcode,
    // input  [1:0]  dmem_1_d_bits_param,
    input  [3:0]  dmem_1_d_bits_size,
    input  [9:0]  dmem_1_d_bits_source,
    // input  [2:0]  dmem_1_d_bits_sink,
    // input         dmem_1_d_bits_denied,
    input  [31:0] dmem_1_d_bits_data,
    // input         dmem_1_d_bits_corrupt,
    output        dmem_1_a_valid,
    output [2:0]  dmem_1_a_bits_opcode,
    // output [2:0]  dmem_1_a_bits_param,
    output [3:0]  dmem_1_a_bits_size,
    output [9:0]  dmem_1_a_bits_source,
    output [31:0] dmem_1_a_bits_address,
    output [3:0]  dmem_1_a_bits_mask,
    output [31:0] dmem_1_a_bits_data,
    // output        dmem_1_a_bits_corrupt,
    output        dmem_1_d_ready,

    input         dmem_2_a_ready,
    input         dmem_2_d_valid,
    input  [2:0]  dmem_2_d_bits_opcode,
    // input  [1:0]  dmem_2_d_bits_param,
    input  [3:0]  dmem_2_d_bits_size,
    input  [9:0]  dmem_2_d_bits_source,
    // input  [2:0]  dmem_2_d_bits_sink,
    // input         dmem_2_d_bits_denied,
    input  [31:0] dmem_2_d_bits_data,
    // input         dmem_2_d_bits_corrupt,
    output        dmem_2_a_valid,
    output [2:0]  dmem_2_a_bits_opcode,
    // output [2:0]  dmem_2_a_bits_param,
    output [3:0]  dmem_2_a_bits_size,
    output [9:0]  dmem_2_a_bits_source,
    output [31:0] dmem_2_a_bits_address,
    output [3:0]  dmem_2_a_bits_mask,
    output [31:0] dmem_2_a_bits_data,
    // output        dmem_2_a_bits_corrupt,
    output        dmem_2_d_ready,

    input         dmem_3_a_ready,
    input         dmem_3_d_valid,
    input  [2:0]  dmem_3_d_bits_opcode,
    // input  [1:0]  dmem_3_d_bits_param,
    input  [3:0]  dmem_3_d_bits_size,
    input  [9:0]  dmem_3_d_bits_source,
    // input  [2:0]  dmem_3_d_bits_sink,
    // input         dmem_3_d_bits_denied,
    input  [31:0] dmem_3_d_bits_data,
    // input         dmem_3_d_bits_corrupt,
    output        dmem_3_a_valid,
    output [2:0]  dmem_3_a_bits_opcode,
    // output [2:0]  dmem_3_a_bits_param,
    output [3:0]  dmem_3_a_bits_size,
    output [9:0]  dmem_3_a_bits_source,
    output [31:0] dmem_3_a_bits_address,
    output [3:0]  dmem_3_a_bits_mask,
    output [31:0] dmem_3_a_bits_data,
    // output        dmem_3_a_bits_corrupt,
    output        dmem_3_d_ready,

    // input         fpu_fcsr_flags_valid,
    // input  [4:0]  fpu_fcsr_flags_bits,
    // // input  [63:0] fpu_store_data,
    // input  [31:0] fpu_toint_data,
    // input         fpu_fcsr_rdy,
    // input         fpu_nack_mem,
    // input         fpu_illegal_rm,
    // input         fpu_dec_wen,
    // input         fpu_dec_ldst,
    // input         fpu_dec_ren1,
    // input         fpu_dec_ren2,
    // input         fpu_dec_ren3,
    // input         fpu_dec_swap12,
    // input         fpu_dec_swap23,
    // input  [1:0]  fpu_dec_typeTagIn,
    // input  [1:0]  fpu_dec_typeTagOut,
    // input         fpu_dec_fromint,
    // input         fpu_dec_toint,
    // input         fpu_dec_fastpipe,
    // input         fpu_dec_fma,
    // input         fpu_dec_div,
    // input         fpu_dec_sqrt,
    // input         fpu_dec_wflags,
    // input         fpu_sboard_set,
    // input         fpu_sboard_clr,
    // input  [4:0]  fpu_sboard_clra,

    // output        fpu_hartid,
    // output [31:0] fpu_time,
    // output [31:0] fpu_inst,
    // output [31:0] fpu_fromint_data,
    // output [2:0]  fpu_fcsr_rm,
    // output        fpu_dmem_resp_val,
    // output [2:0]  fpu_dmem_resp_type,
    // output [4:0]  fpu_dmem_resp_tag,
    // output        fpu_valid,
    // output        fpu_killx,
    // output        fpu_killm,
    // output        fpu_keep_clock_enabled,

    output        cease,

    input         traceStall,
    output        wfi
);

    logic [3:0] intr_counter;
    logic msip_1d, intr_reset;
    logic busy;

    assign intr_reset = |intr_counter;
    /* interrupts */
    always @(posedge clock) begin
        msip_1d <= interrupts_msip;
        if (reset) begin
            intr_counter <= 4'h0;
        end else if (~msip_1d && interrupts_msip) begin
            // rising edge
            intr_counter <= 4'h6;
        end else begin
            intr_counter <= intr_counter > 0 ? intr_counter - 4'h1 : 4'h0;
        end
    end

    // ------------------------------------------------------------------------
    // TL <-> Vortex core-cache interface adapter
    // ------------------------------------------------------------------------

    /* imem */
    assign icache_rsp_if.valid = imem_0_d_valid;
    assign icache_rsp_if.data = imem_0_d_bits_data;
    assign icache_rsp_if.tag = imem_0_d_bits_source[`ICACHE_CORE_TAG_WIDTH-1:0];
    assign imem_0_d_ready = icache_rsp_if.ready;
    // always @(posedge clock) begin
    //     if (icache_req_if.valid && icache_req_if.ready)
    //         icache_rsp_if.tag <= icache_req_if.tag;
    // end
    assign imem_0_a_bits_source = {32'b0, icache_req_if.tag}[9:0];
    assign imem_0_a_valid = icache_req_if.valid;
    assign imem_0_a_bits_address = {icache_req_if.addr, 2'b0};
    assign icache_req_if.ready = imem_0_a_ready;

    assign imem_0_a_bits_data = 32'd0;
    assign imem_0_a_bits_mask = 4'hf;
    assign imem_0_a_bits_corrupt = 1'b0;
    assign imem_0_a_bits_param = 3'd0;
    assign imem_0_a_bits_size = 4'd2; // 32b
    assign imem_0_a_bits_opcode = 3'd4; // Get

    /* dmem */
    assign dcache_rsp_if.valid =
        (dmem_3_d_valid && (dmem_3_d_bits_opcode !== 'd0 /*AccessAck*/)) ||
        (dmem_2_d_valid && (dmem_2_d_bits_opcode !== 'd0 /*AccessAck*/)) ||
        (dmem_1_d_valid && (dmem_1_d_bits_opcode !== 'd0 /*AccessAck*/)) ||
        (dmem_0_d_valid && (dmem_0_d_bits_opcode !== 'd0 /*AccessAck*/));
    assign dcache_rsp_if.data = {dmem_3_d_bits_data, dmem_2_d_bits_data, dmem_1_d_bits_data, dmem_0_d_bits_data};

    // get tag (source) from one of the valid dmem lanes; any is fine, use
    // priority logic for simplicity
    logic [9:0] tag_d;
    always @(*) begin
        tag_d = '0;
        for (integer i = 0; i < 4; i += 1) begin
            if ({dmem_3_d_valid, dmem_2_d_valid, dmem_1_d_valid, dmem_0_d_valid}[i]) begin
                tag_d = {dmem_3_d_bits_source, dmem_2_d_bits_source, dmem_1_d_bits_source, dmem_0_d_bits_source}[i * 10 +: 10];
            end
        end
    end
    assign dcache_rsp_if.tag = tag_d;
    // NOTE: Vortex dcache response has 1-bit valid, but uses thread mask to
    // differentiate per-lane valids.  This is different from dcache request
    // which uses per-lane N-bit valid.  In either case, the same tag is shared
    // across all request/response lanes.
    assign dcache_rsp_if.tmask = {
        dmem_3_d_valid && (dmem_3_d_bits_opcode !== 'd0 /*AccessAck*/),
        dmem_2_d_valid && (dmem_2_d_bits_opcode !== 'd0 /*AccessAck*/),
        dmem_1_d_valid && (dmem_1_d_bits_opcode !== 'd0 /*AccessAck*/),
        dmem_0_d_valid && (dmem_0_d_bits_opcode !== 'd0 /*AccessAck*/)};
    assign {dmem_3_d_ready, dmem_2_d_ready, dmem_1_d_ready, dmem_0_d_ready} = {4{dcache_rsp_if.ready}};

    assign {dmem_3_a_valid, dmem_2_a_valid, dmem_1_a_valid, dmem_0_a_valid} = dcache_req_if.valid;
    assign {dmem_3_a_bits_address, dmem_2_a_bits_address, dmem_1_a_bits_address, dmem_0_a_bits_address} =
        {{dcache_req_if.addr[3], 2'b0}, {dcache_req_if.addr[2], 2'b0}, {dcache_req_if.addr[1], 2'b0}, {dcache_req_if.addr[0], 2'b0}};
    assign {dmem_3_a_bits_source, dmem_2_a_bits_source, dmem_1_a_bits_source, dmem_0_a_bits_source} = dcache_req_if.tag;
    // we assume all lanes always have the same tag; otherwise the sourceId
    // logic in the Chisel tile breaks
    // always @(*) begin
    //   for (i = 0; i < 4; i++) begin
    //     assert(dcache_req_if.tag[0] == dcache_req_if.tag[i])
    //   end
    // end
    assign {dmem_3_a_bits_data, dmem_2_a_bits_data, dmem_1_a_bits_data, dmem_0_a_bits_data} = dcache_req_if.data;
    assign {dmem_3_a_bits_opcode, dmem_2_a_bits_opcode, dmem_1_a_bits_opcode, dmem_0_a_bits_opcode} = {
        dcache_req_if.rw[3] ? (&dcache_req_if.byteen[3] ? 3'd0 /*PutFull*/ : 3'd1 /*PutPartial*/) : 3'd4 /*Get*/,
        dcache_req_if.rw[2] ? (&dcache_req_if.byteen[2] ? 3'd0 /*PutFull*/ : 3'd1 /*PutPartial*/) : 3'd4 /*Get*/,
        dcache_req_if.rw[1] ? (&dcache_req_if.byteen[1] ? 3'd0 /*PutFull*/ : 3'd1 /*PutPartial*/) : 3'd4 /*Get*/,
        dcache_req_if.rw[0] ? (&dcache_req_if.byteen[0] ? 3'd0 /*PutFull*/ : 3'd1 /*PutPartial*/) : 3'd4 /*Get*/};
        // NOTE: MAKE SURE TO CHANGE CONSTANT WIDTH FOR SIZE!
    assign {dmem_3_a_bits_size, dmem_2_a_bits_size, dmem_1_a_bits_size, dmem_0_a_bits_size} = {4{4'd2}}; /* $countones(dcache_req_if.byteen[0]) === 'd4 ? 2'd2 :
        ($countones(dcache_req_if.byteen[0]) === 'd2 ? 2'd1 : 2'd0); */
    assign {dmem_3_a_bits_mask, dmem_2_a_bits_mask, dmem_1_a_bits_mask, dmem_0_a_bits_mask} = dcache_req_if.byteen;
    assign dcache_req_if.ready = {dmem_3_a_ready, dmem_2_a_ready, dmem_1_a_ready, dmem_0_a_ready};

    // assign {dmem_3_a_bits_corrupt, dmem_2_a_bits_corrupt, dmem_1_a_bits_corrupt, dmem_0_a_bits_corrupt} = '0;
    // assign {dmem_3_a_bits_param, dmem_2_a_bits_param, dmem_1_a_bits_param, dmem_0_a_bits_param} = '0;

    /* fpu */

    // assign {fpu_hartid, fpu_time, fpu_inst, fpu_fromint_data, fpu_fcsr_rm, fpu_dmem_resp_val, fpu_dmem_resp_type,
    //         fpu_dmem_resp_tag, fpu_valid, fpu_killx, fpu_killm, fpu_keep_clock_enabled} = '0;

    assign cease = ~busy;
    assign wfi = 1'b0;

    always @(posedge clock) begin
        for (integer i = 0; i < 4; i++) begin
            if (dcache_req_if.valid[i] && dcache_req_if.ready[i] && dcache_req_if.rw[i]) begin
                if ({dcache_req_if.addr[i], 2'b0}[31:28] == 4'hc) begin // heap address
                    $display("[%d] STORE HEAP MEM: THREAD=%d, ADDRESS=0x%X, DATA=0x%08X", $time(), i, {dcache_req_if.addr[i], 2'b0}, dcache_req_if.data[i]);
                end
            end
            // if (dcache_rsp_if.valid[i] && dcache_rsp_if.ready) begin
            //     $display("LOAD MEM: THREAD=%d, DATA=0x%08X", i, dcache_req_if.data);
            // end
        end
    end

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
        .reset(reset || intr_reset),

        .irq(1'b0/*intr_reset*/),

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
        .busy(busy)
    );

    always @(*) begin
        if (busy === 1'b0) begin
            $display("no more active warps");

            @(negedge clock);

            // TODO: lane assumed to be 4
            `ifndef SYNTHESIS
            for (integer j = 0; j < `NUM_WARPS; j++) begin
                $display("warp %2d", j);
                for (integer k = 0; k < `NUM_REGS; k += 1)
                    $display("x%2d: %08x  %08x  %08x  %08x", k,
                        pipeline.issue.gpr_stage.iports[/*thread*/0].dp_ram1.not_out_reg.reg_dump.ram[j * `NUM_REGS + k],
                        pipeline.issue.gpr_stage.iports[/*thread*/1].dp_ram1.not_out_reg.reg_dump.ram[j * `NUM_REGS + k],
                        pipeline.issue.gpr_stage.iports[/*thread*/2].dp_ram1.not_out_reg.reg_dump.ram[j * `NUM_REGS + k],
                        pipeline.issue.gpr_stage.iports[/*thread*/3].dp_ram1.not_out_reg.reg_dump.ram[j * `NUM_REGS + k]);
                end
            `endif

            // @(posedge clock) $finish();
        end
    end

endmodule : Vortex





