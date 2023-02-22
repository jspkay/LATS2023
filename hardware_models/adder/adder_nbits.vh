module full_adder_nbits
	#( parameter n_bits = 8 )
	( input [n_bits:1] op1, 
		input [n_bits:1] op2, 
		input c_in,
		output [n_bits:1] s,
		output c_out );

wire [n_bits-1:1] carries;

genvar i;
full_adder first_add(op1[1], op2[1], c_in, s[1], carries[1]); // first adder (LSB)
for (i=2; i<=n_bits-1; i=i+1) begin 
	full_adder fa_n (op1[i], op2[i], carries[i-1], s[i], carries[i]); // middle ones
end
full_adder last_add(op1[n_bits], op2[n_bits], carries[n_bits-1], s[n_bits], c_out); // last adder MSB

endmodule
