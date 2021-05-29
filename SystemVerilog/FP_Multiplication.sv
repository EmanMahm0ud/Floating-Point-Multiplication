module sign_calculation(input logic a, b, output logic sign);
	assign sign = a ^ b;
endmodule

module add_exponent(input logic [7:0] a, b, output logic [8:0] sum);
	assign sum = a + b;
endmodule

module subtract_bias(input logic [8:0] sum, output logic [7:0] final_exponent);
	assign final_exponent = sum - 127;
endmodule

module multiply_mantissa(input logic [23:0] a, b, output logic [47:0] multi);
	assign multi = a * b;
endmodule

module normalize(input logic [7:0] exponent, input logic [47:0] mantissa,
					  output logic [30:0] norm_exp_mant);
	logic [22:0] norm_mantissa;
	logic [7:0] norm_exponent;
	always @(*)
		begin
			if (mantissa[47] == 0) begin
				norm_mantissa = mantissa[45:23];
				norm_exponent = exponent;
			end
			else if (mantissa[47] == 1) begin
				norm_mantissa = mantissa[46:24];
				norm_exponent = exponent + 1;
			end
		end
	assign norm_exp_mant = {norm_exponent, norm_mantissa};
endmodule

module FP_Multiplication(input logic [31:0] a, b, output logic [31:0] result);
	logic sign1, sign2, sign_res;
	logic [7:0] exponent1, exponent2, final_exponent_res;
	logic [8:0] exponent_res;
	logic [23:0] mantissa1, mantissa2;
	logic [47:0] mantissa_res;
	logic [30:0] final_exp_mantissa;

	assign {sign1, exponent1} = {a[31], a[30:23]};
	assign {sign2, exponent2} = {b[31], b[30:23]};
	assign mantissa1 = {1'b1, a[22:0]};
	assign mantissa2 = {1'b1, b[22:0]};
	
	sign_calculation sign_calc(sign1, sign2, sign_res);
	add_exponent add(exponent1, exponent2, exponent_res);
	subtract_bias sub(exponent_res, final_exponent_res);
	multiply_mantissa multi(mantissa1, mantissa2, mantissa_res);
	normalize normal(final_exponent_res, mantissa_res, final_exp_mantissa);
	
	assign result = {sign_res, final_exp_mantissa};
endmodule 