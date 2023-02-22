module adder_tb;

reg a,b,c;
wire s, c_out;

full_adder uut(a,b,c,s,c_out);

initial begin
	a = 1;
	b = 1;
	c = 1;
	
	#5 
	a=0;

	#5
	b=0;


	#5
	c=0;

	#5
	a=1;



end

endmodule
