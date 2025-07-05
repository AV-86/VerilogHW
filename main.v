module clk_div_1000(input wire fast_clk, output reg divided_clk);
    reg [9:0] cntr;    
    always @(posedge fast_clk) begin
        cntr <= (cntr == 999) ? 0 : cntr + 1;
		  divided_clk <= (cntr >= 500);
    end
endmodule

module blink(input wire clk, output wire led);
    reg [27:0] cntr;
    assign led = cntr > 50000000 ? 1 : 0;
    always @(posedge clk) begin
        cntr <= (cntr == 100000000) ? 0 : cntr + 1;
    end
endmodule

module LowLevel3_7Seg(
	input wire seg_sw_clk,
	input wire [7:0] Dig1,
	input wire [7:0] Dig2,
	input wire [7:0] Dig3,

	output wire[7:0] Seg,
	output wire[2:0] Dig
);

	reg [1:0] curr_dig;

	assign Seg = (curr_dig == 0) ?  ~Dig1 : (curr_dig == 1) ? ~Dig2 : (curr_dig == 2) ? ~Dig3 : 8'b00000000;
	assign Dig = (curr_dig == 0) ?  1 : (curr_dig == 1) ? 2 : (curr_dig == 2) ? 4 : 3'b000;

	always @(posedge seg_sw_clk) begin
		curr_dig <= (curr_dig == 2) ? 0 : curr_dig + 1;
	end
endmodule

module DigToSegs(input wire[3:0] DigVal, output wire [7:0] Seg);
	assign Seg = 
	(DigVal == 0) ? 8'b00111111 :
	(DigVal == 1) ? 8'b00000110 :
	(DigVal == 2) ? 8'b01011011 :
	(DigVal == 3) ? 8'b01001111 :
	(DigVal == 4) ? 8'b01100110 :
	(DigVal == 5) ? 8'b01101101 :
	(DigVal == 6) ? 8'b01111101 :
	(DigVal == 7) ? 8'b00000111 :
	(DigVal == 8) ? 8'b01111111 :
	(DigVal == 9) ? 8'b01101111 :

	(DigVal == 10) ? 8'b01110111 :
	(DigVal == 11) ? 8'b01111100 :
	(DigVal == 12) ? 8'b00111001 :
	(DigVal == 13) ? 8'b01011110 :
	(DigVal == 14) ? 8'b01111001 :
	(DigVal == 15) ? 8'b01110001 : 0;	
endmodule

module NumberOn3_7Seg(
	input wire seg_sw_clk,
	input wire[9:0] Num,

	output wire[7:0] Seg,
	output wire[2:0] Dig
);
	wire[3:0] Dig1Val = Num / 100;
	wire[3:0] Dig2Val = (Num / 10) % 10;
	wire[3:0] Dig3Val = Num % 10;
	
	wire[7:0] Dig1;
	wire[7:0] Dig2;
	wire[7:0] Dig3;

	DigToSegs GetDig1(.DigVal(Dig1Val), .Seg(Dig1));
	DigToSegs GetDig2(.DigVal(Dig2Val), .Seg(Dig2));
	DigToSegs GetDig3(.DigVal(Dig3Val), .Seg(Dig3));
	

	LowLevel3_7Seg indicator(
		.seg_sw_clk(seg_sw_clk),
		.Dig1(Dig1),
		.Dig2(Dig2),
		.Dig3(Dig3),

		.Seg(Seg),
		.Dig(Dig)
	);	
endmodule

module count1000(input wire clk, output wire [9:0] value);
    reg [22:0] div_cntr;    
    reg [9:0] out_cntr;
    reg divided_clk;
    
	 always @(posedge clk) begin
        div_cntr <= (div_cntr == 1999999) ? 0 : div_cntr + 1;
		  divided_clk <= (div_cntr >= 1000000);
    end
    
	 always @(posedge divided_clk) begin
        out_cntr <= (out_cntr == 999) ? 0 : out_cntr + 1;
    end
	 
	 assign value = out_cntr;
endmodule

module main(
	input wire clk,

	output wire led5,
	output wire led6,

    output wire [7:0] disp_7seg_segments,
    output wire [2:0] disp_7seg_dig
);
    wire [9:0] displayed_val;
    wire disp7seg_clk;

    count1000 count1000_inst1(.clk(clk), .value(displayed_val));

    clk_div_1000 clk_div_1000_inst1(.fast_clk(clk), .divided_clk(disp7seg_clk));
    
    NumberOn3_7Seg NumberOn3_7Seg_inst1(
        .seg_sw_clk(disp7seg_clk),
        .Num(displayed_val),

        .Seg(disp_7seg_segments),
        .Dig(disp_7seg_dig)
    );

	
	blink blink_inst1(.clk(clk), .led(led5));
	blink blink_inst2(.clk(clk), .led(led6));

endmodule