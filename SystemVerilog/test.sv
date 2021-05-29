module test();
	logic [31:0] a, b, result;
	FP_Multiplication u_FP_Multiplication(a, b, result);
	
	initial begin
		a = 32'b00111111110000000000000000000000; //1.5
		b = 32'b00111111101000000000000000000000; //1.25
		#100;
		if (result == 32'b00111111111100000000000000000000)$display("Successful result: %b",result);
		else $display("Unsccessful result");

		a = 32'b01000010010101000000000000000000; //53
		b = 32'b01000010110011000000000000000000; //102
		#100;
		if (result == 32'b01000101101010001111000000000000)$display("Successful result: %b",result);
		else $display("Unsccessful result");

		a = 32'b10111111111000000000000000000000; //-1.75
		b = 32'b01000010110010000000000000000000; //100
		#100;
		if (result == 32'b11000011001011110000000000000000)$display("Successful result: %b",result);
		else $display("Unsccessful result");

		a = 32'b11000001001000000000000000000000; //-10
		b = 32'b11000001101001000000000000000000; //-20.5
		#100;
		if (result == 32'b01000011010011010000000000000000)$display("Successful result: %b",result);
		else $display("Unsccessful result");

		$finish();
	end
endmodule 