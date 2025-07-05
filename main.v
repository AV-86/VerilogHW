module main(
	input wire clk,
	output reg led
);
    
    reg [26:0] cntr;
    
    always @(posedge clk) begin
        cntr <= cntr + 1;
        if(cntr == 50000000) begin
            cntr <= 0;
            led <= ~led;
        end
    end

endmodule