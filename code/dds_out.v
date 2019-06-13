module dds_out
(
	input clk_400M,
	input rst_n,
	output [10:0] address,
	output adc_clock,
	output [13:0] dac_data_out,
	input [13:0] q,
	input [23:0] counter_in
);

reg [23:0] counter;
reg [10:0] address_reg;
reg adc_clock_reg;

assign address=address_reg;
assign adc_clock=adc_clock_reg;
assign dac_data_out=(counter==(counter_in))?q:dac_data_out;
wire   half_counter=counter_in>>1;


always@(posedge clk_400M)
if(!rst_n)
	counter<=23'b0;
else if(counter>=(counter_in))begin
	counter<=23'b0;
end
else
	counter<=counter+1'b1;




always@(posedge clk_400M)
	if(!rst_n)
		address_reg<=7'd0;
	else if(counter==(counter_in))begin
		if(address_reg<=11'h07ce)
			address_reg<=address_reg+1'b1;
		else
			address_reg<=11'd0;
		adc_clock_reg<=1'b0;
	end
	else if(counter==half_counter)begin
		adc_clock_reg<=1'b1;
	end

endmodule
