`ifndef VX_CSR_TO_ALU_IF
`define VX_CSR_TO_ALU_IF

`include "VX_define.vh"

interface VX_csr_to_alu_if ();

    wire [31:0] csr_mtvec;
    modport master (
        output csr_mtvec
    );

    modport slave (
        input csr_mtvec
    );

endinterface

`endif