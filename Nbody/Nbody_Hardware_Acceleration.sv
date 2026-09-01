`timescale 1ns / 1ps

module nbody_dist_sq_unit #(
    parameter DATA_WIDTH = 32
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   valid_in,
    // 3D coordinates for body 1 and body 2
    input  logic signed [DATA_WIDTH-1:0] x1, y1, z1,
    input  logic signed [DATA_WIDTH-1:0] x2, y2, z2,
    output logic signed [DATA_WIDTH-1:0] r_out,
    output logic                   valid_out
);

    logic signed [DATA_WIDTH-1:0] dx, dy, dz;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dx <= '0;
            dy <= '0;
            dz <= '0;
            r_out <= '0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
            if (valid_in) begin
                dx <= x1 - x2;
                dy <= y1 - y2;
                dz <= z1 - z2;
                // Compute Euclidean distance squared
                r_out <= (dx * dx) + (dy * dy) + (dz * dz);
            end
        end
    end

endmodule
