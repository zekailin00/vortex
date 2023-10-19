`include "VX_define.vh"
// TODO: move VX_define constants to parameters, and then parameterize in blackbox

module Vortex #(
    parameter CORE_ID = 0
) (        

    /* adapt to CoreIO bundle at src/main/scala/tile/Core.scala */

    input          clock,
    input          reset,
    input          hartid,
    input  [31:0]  reset_vector,
    input          interrupts_debug,
    input          interrupts_mtip,
    input          interrupts_msip,
    input          interrupts_meip,
    input          interrupts_seip,

    input          mem_a_ready,
    input          mem_d_valid,
    input  [2:0]   mem_d_bits_opcode,
    input  [1:0]   mem_d_bits_param,
    input  [3:0]   mem_d_bits_size,
    input  [14:0]  mem_d_bits_source,
    input  [2:0]   mem_d_bits_sink,
    input          mem_d_bits_denied,
    input  [127:0] mem_d_bits_data,
    input          mem_d_bits_corrupt,
    output         mem_a_valid,
    output [2:0]   mem_a_bits_opcode,
    output [2:0]   mem_a_bits_param,
    output [3:0]   mem_a_bits_size,
    output [14:0]  mem_a_bits_source,
    output [31:0]  mem_a_bits_address,
    output [15:0]  mem_a_bits_mask,
    output [127:0] mem_a_bits_data,
    output         mem_a_bits_corrupt,
    output         mem_d_ready,

    input          fpu_fcsr_flags_valid,
    input  [4:0]   fpu_fcsr_flags_bits,
    // input  [63:0] fpu_store_data,
    input  [31:0]  fpu_toint_data,
    input          fpu_fcsr_rdy,
    input          fpu_nack_mem,
    input          fpu_illegal_rm,
    input          fpu_dec_wen,
    input          fpu_dec_ldst,
    input          fpu_dec_ren1,
    input          fpu_dec_ren2,
    input          fpu_dec_ren3,
    input          fpu_dec_swap12,
    input          fpu_dec_swap23,
    input  [1:0]   fpu_dec_typeTagIn,
    input  [1:0]   fpu_dec_typeTagOut,
    input          fpu_dec_fromint,
    input          fpu_dec_toint,
    input          fpu_dec_fastpipe,
    input          fpu_dec_fma,
    input          fpu_dec_div,
    input          fpu_dec_sqrt,
    input          fpu_dec_wflags,
    input          fpu_sboard_set,
    input          fpu_sboard_clr,
    input  [4:0]   fpu_sboard_clra,

    output         fpu_hartid,
    output [31:0]  fpu_time,
    output [31:0]  fpu_inst,
    output [31:0]  fpu_fromint_data,
    output [2:0]   fpu_fcsr_rm,
    output         fpu_dmem_resp_val,
    output [2:0]   fpu_dmem_resp_type,
    output [4:0]   fpu_dmem_resp_tag,
    output         fpu_valid,
    output         fpu_killx,
    output         fpu_killm,
    output         fpu_keep_clock_enabled,

    output         cease,

    input          traceStall,
    output         wfi
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

    /* dmem */
    assign mem_rsp_if.valid =
        (mem_d_valid && (mem_d_bits_opcode !== 'd0 /*AccessAck*/));
    assign mem_rsp_if.data = mem_d_bits_data;

    assign mem_rsp_if.tag = mem_d_bits_source;
    assign mem_d_ready = mem_rsp_if.ready;

    assign mem_a_valid = mem_req_if.valid;
    assign mem_a_bits_address = {mem_req_if.addr, 4'b0};
    assign mem_a_bits_source = mem_req_if.tag;
    assign mem_a_bits_data = mem_req_if.data;
    assign mem_a_bits_opcode = 
        mem_req_if.rw ? (&mem_req_if.byteen ? 3'd0 /*PutFull*/ : 3'd1 /*PutPartial*/) : 3'd4 /*Get*/;
        // NOTE: MAKE SURE TO CHANGE CONSTANT WIDTH FOR SIZE!
    assign mem_a_bits_size = 4'd4; // 2^4 = 16 bytes, corresponds to DCACHE_MEM_DATA_WIDTH in presence of L2/L3
    /* $countones(dcache_req_if.byteen[0]) === 'd4 ? 2'd2 :
        ($countones(dcache_req_if.byteen[0]) === 'd2 ? 2'd1 : 2'd0); */
    // For some reason mem_req_if.byteen is X on icache fills
    // TODO: is this necessary? only has to be "naturally aligned" whatever that means
    assign mem_a_bits_mask = mem_req_if.rw ? mem_req_if.byteen : '1; 
    assign mem_req_if.ready = mem_a_ready;

    assign mem_a_bits_corrupt = '0;
    assign mem_a_bits_param = '0;

    /* fpu */

    assign {fpu_hartid, fpu_time, fpu_inst, fpu_fromint_data, fpu_fcsr_rm, fpu_dmem_resp_val, fpu_dmem_resp_type,
            fpu_dmem_resp_tag, fpu_valid, fpu_killx, fpu_killm, fpu_keep_clock_enabled} = '0;

    assign cease = ~busy;
    assign wfi = 1'b0;

    // Log writes to heap memory.
    // L1 is a write-through cache, so logging at the L1-L2 boundary can still
    // catch all writes in software.
    logic [3:0] mask;
    logic [31:0] word;
    logic [31:0] addr;
    always @(posedge clock) begin
        if (mem_req_if.valid && mem_req_if.ready && mem_req_if.rw) begin
            // filter out store to heap address 0xc*******
            if (mem_a_bits_address[31:28] == 4'hc) begin
                for (integer i = 0; i < 4; i += 1) begin
                    mask = mem_a_bits_mask >> (i * 4);
                    word = mem_a_bits_data >> (i * 32);
                    addr = mem_a_bits_address + (i * 4);
                    if (&mask) begin
                        $display("[%d] STORE HEAP MEM: THREAD=%d, ADDRESS=0x%X, DATA=0x%08X", $time(), i, addr, word);
                    end
                    $display("[%d] DEBUG MEM: THREAD=%d, ADDRESS=0x%X, MASK=0x%X, DATA=0x%08X", $time(), i, mem_a_bits_address, mem_a_bits_mask, mem_a_bits_data);
                end
            end
        end
    end

    VX_mem_req_if #(
        .DATA_WIDTH (`DCACHE_MEM_DATA_WIDTH),
        .ADDR_WIDTH (`DCACHE_MEM_ADDR_WIDTH),
        .TAG_WIDTH  (`L1_MEM_TAG_WIDTH)
    ) mem_req_if();

    VX_mem_rsp_if #(
        .DATA_WIDTH (`DCACHE_MEM_DATA_WIDTH),
        .TAG_WIDTH  (`L1_MEM_TAG_WIDTH)
    ) mem_rsp_if();

    VX_core #(
        .CORE_ID(CORE_ID)
    ) core (
        // `SCOPE_BIND_VX_core_pipeline
    `ifdef PERF_ENABLE
        .perf_memsys_if (perf_memsys_if),
    `endif

        .clk(clock),
        .reset(reset || intr_reset),
        .irq(1'b0/*intr_reset*/),
        
        // Memory request
        .mem_req_valid(mem_req_if.valid),
        .mem_req_rw(mem_req_if.rw),    
        .mem_req_byteen(mem_req_if.byteen),
        .mem_req_addr(mem_req_if.addr),
        .mem_req_data(mem_req_if.data),
        .mem_req_tag(mem_req_if.tag),
        .mem_req_ready(mem_req_if.ready),

        // Memory reponse    
        .mem_rsp_valid(mem_rsp_if.valid),
        .mem_rsp_data(mem_rsp_if.data),
        .mem_rsp_tag(mem_rsp_if.tag),
        .mem_rsp_ready(mem_rsp_if.ready),

        // Status
        .busy(busy)
    );

    always @(*) begin
        if (busy === 1'b0) begin
            $display("no more active warps, wrapping up");

            @(negedge clock);

            `ifndef SYNTHESIS
            for (integer j = 0; j < `NUM_WARPS; j++) begin
                $display("warp %2d", j);
                for (integer k = 0; k < `NUM_REGS; k += 1) begin
                    $display("x%2d: %08x  %08x  %08x  %08x", k,
                        core.pipeline.issue.gpr_stage.iports[0].dp_ram1.not_out_reg.reg_dump.ram[j * `NUM_REGS + k],
                        core.pipeline.issue.gpr_stage.iports[1].dp_ram1.not_out_reg.reg_dump.ram[j * `NUM_REGS + k],
                        core.pipeline.issue.gpr_stage.iports[2].dp_ram1.not_out_reg.reg_dump.ram[j * `NUM_REGS + k],
                        core.pipeline.issue.gpr_stage.iports[3].dp_ram1.not_out_reg.reg_dump.ram[j * `NUM_REGS + k]);
                end
            end
            `endif

            // @(posedge clock) $finish();
        end
    end

endmodule : Vortex





