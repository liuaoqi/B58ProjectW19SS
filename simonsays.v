`timescale 1ns / 1ns // `timescale time_unit/time_precision

//SW[2:0] data inputs for determining speed
//SW[17] game start
//KEY[3:0] key inputs used for inputting player's pattern
//SW[3] reset input for rate divider

//LEDR[3:0] the LEDS used for outputting pattern to be matched

module simonsays(CLOCK_50, LEDR, SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4);
	input CLOCK_50;
	input [17:0] SW;
	input [3:0] KEY;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4;
	output [3:0] LEDR;

	wire [27:0] Q_out;
	wire [27:0] rate_d;
	wire clk;

	wire [17:0] pattern;
	reg reset;
	wire [1:0] light;

	reg [3:0] lv; //denotes level number
	reg rst;
	
	wire [1:0] win; //indicates if level is won or lost
	
	reg [3:0] hex3, hex2, hex1, hex0;
	reg [3:0] led;
	
	//get the speed of the level from the user
	speedchanger sc(.speed(SW[2:0]), .rate(rate_d));
	
	//load the randomized pattern of lights at the start of the game
	randomizer rand(.switch(SW[17]), .seed(18'b010011101010111010), .pattern(pattern), .clk(CLOCK_50));
	
	//use rate divider to determine clock speed
	RateDivider rd(.clk(CLOCK_50), .reset(SW[3]), .timer(rate_d), .Q(Q_out));
	
	initial
	begin
		lv = 4'b0001; //there are totally 9 levels; starts at level 1
		rst = 0;
	end
	
	assign clk = (Q_out == 0 ? 1 : 0);

	always @(win)
	begin
			if (win == 2'b11 && lv < 4'b1001) //if round has been won and level is not level 9
			begin
				lv = lv + 1'b1; //continue to the next level
				rst = 0;
				hex3 = 4'h6; //display GOOD on hex display to indicate level is passed
				hex2 = 4'h0;
				hex1 = 4'h0;
				hex0 = 4'hD;
			end
			else if (win == 2'b00) //if round has been lost
			begin
					rst = 1; //there are no levels left to play
					hex3 = 4'hD; //display DIED on hex display to indicate game over
					hex2 = 4'h1;
					hex1 = 4'hE;
					hex0 = 4'hD;
			end
			else if (win == 2'b11 && lv == 4'b1001) //if round has been won and level is level 9
			begin
					rst = 1; //there are no levels left to play
					hex3 = 4'h6; //display GOOD on hex display to indicate game has been won
					hex2 = 4'h0;
					hex1 = 4'h0;
					hex0 = 4'hD;
			end
				
	end
		
	//load the next light in the pattern
	load_pattern lp(.reset(rst), .clck(clk), .pattern(pattern), .level(lv), .light(light));
	
	//check if keys entered by user match the pattern displayed
	checkifwin ch(.light(light), .keys(KEY[3:0]), .level(lv), .pattern(pattern), .result(win));
	
	//the value of light determines the led # that will shine in that clock cycle 
	always @(posedge clk)
	begin
		case(light)
			2'b00: led = 4'b0001; //led[0] is LED[0]'s value and led[3] is LED[3]'s value
			2'b01: led = 4'b0010;
			2'b10: led = 4'b0100;
			2'b11: led = 4'b1000;
			default: led = 4'b0000;
		endcase
	end

	assign LEDR[0] = led[0];
	assign LEDR[1] = led[1];
	assign LEDR[2] = led[2];
	assign LEDR[3] = led[3];
	
	//displays GOOD or DIED message
	hex_display h3(hex3, HEX3);
	hex_display h2(hex2, HEX2);
	hex_display h1(hex1, HEX1);
	hex_display h0(hex0, HEX0);
	
	//displayes current level
	hex_display hex4(lv, HEX4);

endmodule


// ******************************************
// SPEED CHANGER: changes the speed at which leds are flashed depending on the switch input
// ****************************************** 
module speedchanger(speed, rate);
	input [2:0] speed;
	output reg [27:0] rate;

	always @(rate)
		begin
		case(rate)
			3'b001: morse_code = 28'b1011111010111100000111111111; //0.25 Hz -  EASY
			3'b010: morse_code = 28'b0101111101011110000011111111; //0.5 Hz - MEDIUM
			3'b011: morse_code = 28'b0010111110101111000001111111; //1 Hz - HARD
			default: morse_code = 28'b0000000000000000000000000000;
		endcase
	end

endmodule


// ******************************************
// CHECK IF WIN: checks if the sequence of keys inputted by the player matches the sequence of lights
// ****************************************** 
module checkifwin(light, keys, level, pattern, result); 
	input [1:0] light;
	input [3:0] keys;
	input [3:0] level;
	input [19:0] pattern;
	reg [3:0] count; //keeps track of how much of the pattern has been checked
	reg [3:0] c; //keeps track of where in the pattern we are
	output reg [1:0] result;
	
	initial
	begin
		count = 4'b0000;
		c = 4'b0000;
	end
	
	integer i;

	
	always @(keys)
	begin	
		if (keys == 4'b0001) //KEY[0] is pressed
			begin
			if (pattern[c] == 0 && pattern[c+1] == 0) //checks if the light in this part of the sequence was LED[0]
				begin
				result = 2'b01; //means level isn't over but current key matches up with the LED in the pattern
				count <= count + 1'b1;
				c <= c + 4'b0010;
				end
			else
				result = 2'b00; //means current key does not match up with the LED in the pattern
			end
		else if (keys == 4'b0010) //KEY[1] is pressed
			begin
			if (pattern[c] == 1 && pattern[c+1] == 0) //checks if the light in this part of the sequence was LED[1]
				begin
				result = 2'b01;
				count <= count + 1'b1;
				c <= c + 4'b0010;
				end
			else
				result = 2'b00;
			end
		else if (keys == 4'b0100) //KEY[2] is pressed
			begin
			if (pattern[c] == 0 && pattern[c+1] == 1) //checks if the light in this part of the sequence was LED[2]
				begin
				result = 2'b01;
				count <= count + 1'b1;
				c <= c + 4'b0010;
				end
			else
				result = 2'b00;
			end
		else if (keys == 4'b1000) //KEY[3] is pressed
			begin
			if (pattern[c] == 1 && pattern[c+1] == 1) //checks if the light in this part of the sequence was LED[3]
				begin
				result = 2'b01;
				count <= count + 1'b1;
				c <= c + 4'b0010;
				end
			else
				result = 2'b00;
			end
		if (count == level)
			begin
				result = 2'b11; //means level is over
				count <= 0;
				c <= 0;
			end
	end


endmodule		

// ******************************************
// LOAD PATTERN: loads the values of the light that should be on at a certain point in the game
// ****************************************** 
module load_pattern(reset, clck, pattern, level, light);
	input reset;
	input clck;
	input [17:0] pattern;
	input [3:0] level;
	output reg [1:0] light;
	reg [3:0] count;
	
	initial
	begin
		count = 4'b0000;
	end

	/*every 2 bits of the pattern stand for a certain LED
	00 - LED[0] (should be matched with KEY[0])
	01 - LED[1] (should be matched with KEY[1])
	10 - LED[2] (should be matched with KEY[2])
	11 - LED[3] (should be matched with KEY[3])*/
	
	always @(count)
		begin
		if (count <= level && count != 0)
		begin
		case(count)
			4'b0001: light = pattern[1:0];
			4'b0010: light = pattern[3:2];
			4'b0011: light = pattern[5:4];
			4'b0100: light = pattern[7:6];
			4'b0101: light = pattern[9:8];
			4'b0110: light = pattern[11:10];
			4'b0111: light = pattern[13:12];
			4'b1000: light = pattern[15:14];
			4'b1001: light = pattern[17:16];
			//default: light = NULL;
		endcase
		end
	end
	
	always @(posedge clck) //keeps track of how much of the pattern is divulged depending on the level
		begin
			if (count <= level)
				count <= count + 1'b1;
			else if (reset == 0 && count != level + 1'b1) //stops everything when end of level is reached or when game over
				count <= 0;
		end

endmodule

// ******************************************
// RATE DIVIDER: determines the frequency of the clock
// ****************************************** 
module RateDivider(clk, reset, timer, Q);
	input clk, reset;
	input [27:0] timer;
	output reg [27:0] Q;

	always @(posedge clk)
	begin
		if(reset == 1'b0) 
			Q <= 0;
		else if(Q == 0)
			Q <= timer;
		else 
			Q <= Q - 1'b1;
	end
endmodule

// ******************************************
// RANDOMIZER: an LFSR that pseudo randomizes the pattern that will determine the sequence of lights for this game of Simon Says
// ****************************************** 
module randomizer(switch, seed, pattern, clk);

    input switch; // when this switch is on, game starts
    input clk;
    input [17:0] seed; //the initial value fed into the randomizer
    output reg [17:0] pattern; //the final random pattern

    reg [17:0] rand_num;
	 
   always @(posedge clk)
       begin
       //on start up of FPGA board SW[17] will be 0 which gives the randomizer enough time to randmoize the seed value
		 if (switch == 1'b0)
			begin
			rand_num <= seed;
			rand_num[0] <= rand_num[7];
			rand_num[1] <= rand_num[16]^rand_num[14];
			rand_num[2] <= rand_num[11];
			rand_num[3] <= rand_num[1];
			rand_num[4] <= rand_num[9];
			rand_num[5] <= rand_num[12]^rand_num[6];
			rand_num[6] <= rand_num[14];
			rand_num[7] <= rand_num[6];
			rand_num[8] <= rand_num[2];
			rand_num[9] <= rand_num[4];
			rand_num[10] <= rand_num[15]^rand_num[10];
			rand_num[11] <= rand_num[17];
			rand_num[12] <= rand_num[3];
			rand_num[13] <= rand_num[8];
			rand_num[14] <= rand_num[5]^rand_num[7];
			rand_num[15] <= rand_num[0];
			rand_num[16] <= rand_num[10];
			rand_num[17] <= rand_num[13];
			end
	//once SW[17] is 1, i.e. game started, the pattern is finalized
		else if (switch == 1'b1)
			begin
			pattern <= rand_num;
			end
	end
endmodule

// ******************************************
// HEX DISPLAY: displays numbers and letters on the FPGA hex display
// ****************************************** 
module hex_display(IN, OUT);
    
   input [3:0] IN;	 
   output reg [6:0] OUT;

   always @(*)
      begin
         case(IN[3:0])
            4'b0000: OUT = 7'b1000000;
            4'b0001: OUT = 7'b1111001;
            4'b0010: OUT = 7'b0100100;
            4'b0011: OUT = 7'b0110000;
            4'b0100: OUT = 7'b0011001;
            4'b0101: OUT = 7'b0010010;
            4'b0110: OUT = 7'b0000010;
            4'b0111: OUT = 7'b1111000;
            4'b1000: OUT = 7'b0000000;
            4'b1001: OUT = 7'b0011000;
            4'b1010: OUT = 7'b0001000;
            4'b1011: OUT = 7'b0000011;
            4'b1100: OUT = 7'b1000110;
            4'b1101: OUT = 7'b0100001;
            4'b1110: OUT = 7'b0000110;
            4'b1111: OUT = 7'b0001110;
            default: OUT = 7'b0111111;
         endcase
      end
endmodule
