module usart_receive
(
	input [7:0] rx_data,
	input data_valid,
	input clk,
	input rst_n,
	output [23:0] div_out,
	output [11:0] mult_out
);

reg set_select;
reg [23:0] div_out_reg;
reg [11:0] mult_out_reg;
reg [3:0] state;
reg [3:0] state_next;
reg [4:0] number_to_receive;
reg [4:0] number_received;


parameter WAIT=4'b0000;
parameter GET_NUM=4'b0001;
parameter RECEIVE=4'b0011;
parameter SET=4'b0010;
parameter FREQUENCY=1'b0;
parameter AMPLITUDE=1'b1;

assign div_out=(state==SET)?div_out_reg:div_out;
assign mult_out=(state==SET)?mult_out_reg:mult_out;

always@(posedge clk)
if(!rst_n)
	state<=WAIT;
else 
	state<=state_next;


always@* begin
	state_next<=4'bx;
	if(data_valid)
		case (state)
		WAIT:
			if(rx_data=="F") begin
				state_next<=GET_NUM;
				set_select<=FREQUENCY;
			end
			else if(rx_data=="M") begin
				state_next<=GET_NUM;
				set_select<=AMPLITUDE;
			end
			else
				state_next<=WAIT;
		GET_NUM:
			state_next<=RECEIVE;
		RECEIVE:
			if(number_received>=number_to_receive)
				state_next<=SET;
			else
				state_next<=RECEIVE;
		SET:
			state_next<=WAIT;
		endcase
end

always@(posedge clk)
	if(!rst_n)begin
		div_out_reg<=24'b0;
		mult_out_reg<=24'b0;
		number_to_receive<=4'b0;
		number_received<=4'b0;
	end
	else
		if(data_valid)
			case(state)
			WAIT:begin
				number_to_receive<=4'b0;
				number_received<=4'b0;
			end
			GET_NUM:begin
				number_to_receive<=rx_data;
				if(set_select==AMPLITUDE)
					mult_out_reg<=12'b0;
				else
					div_out_reg<=24'b0;
			end
			RECEIVE:
				if(set_select==AMPLITUDE)begin
					mult_out_reg<=(mult_out_reg<<8)|rx_data;
					number_received<=number_received+1'b1;
				end
				else begin
					div_out_reg<=(div_out_reg<<8)|rx_data;
					number_received<=number_received+1'b1;
				end
			endcase

endmodule 
