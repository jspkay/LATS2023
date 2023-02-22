module full_adder_n_tb;

reg [8:1] a;
reg [8:1] b;
reg c_in;

wire [8:1] s;
wire c;

full_adder_nbits fa (a, b, c_in, s, c);

initial begin
a = 0;
b = 0;
c_in = 0;

# 10;
a = 10;
b = 5;
c_in = 0;

# 10;
a = 5;
b = 2;
c_in = 0;

# 10;
a = 8'd156;
b = 8'd43;
c_in = 1'b1;

# 10;
a = 8'd0;

# 10;
$stop;


end 

endmodule


