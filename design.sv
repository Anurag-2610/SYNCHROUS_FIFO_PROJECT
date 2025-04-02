// Design Code for synchronous FIFO

module Synchronous_FIFO #(
    parameter WIDTH = 32,    // Data width
    parameter DEPTH = 1024    // FIFO depth
)(
    input wire clk,
    input wire reset,
    input wire [WIDTH-1:0] d_in,
    input wire w_enb,
    input wire r_enb,
    output reg [WIDTH-1:0] d_out,
    output wire full,
    output wire empty
);

// Memory and pointers
reg [WIDTH-1:0] fifo [0:DEPTH-1];
reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
reg [$clog2(DEPTH):0] count;

// Reset logic
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        w_ptr <= 0;
        r_ptr <= 0;
        count <= 0;
        d_out <= 0;
    end else begin
        if (w_enb && !full) begin
            fifo[w_ptr] <= d_in;
            w_ptr <= (w_ptr + 1) % DEPTH;
            count <= count + 1;
        end
        if (r_enb && !empty) begin
            d_out <= fifo[r_ptr];
            r_ptr <= (r_ptr + 1) % DEPTH;
            count <= count - 1;
        end
      
    end
end


   
// Status flags
assign full = (count == DEPTH);
assign empty = (count == 0);

endmodule
