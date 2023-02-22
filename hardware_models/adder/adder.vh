module half_adder(a, b, s, c);
input a,b;
output s,c;

xor(s, a, b);
and(c, a, b);

endmodule


module full_adder(op1, op2, c_in, res, c_out);
input op1, op2, c_in;
output res, c_out;

wire medium_sum;
wire c1,c2;

half_adder h1(op1, op2, medium_sum, c1);
half_adder h2(c_in, medium_sum, res, c2);

or(c_out, c1, c2);


endmodule
