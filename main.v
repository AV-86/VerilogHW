
module blink(
	input wire clk,
	output wire led
);
    reg [27:0] cntr;
    assign led = cntr > 50000000 ? 1 : 0;
    always @(posedge clk) begin
        cntr <= (cntr == 100000000) ? 0 : cntr + 1;
    end
endmodule

module main(
	input wire clk,
	output wire led5,
	output wire led6
);
	
	blink blink_inst1(.clk(clk), .led(led5));
	blink blink_inst2(.clk(clk), .led(led6));

endmodule