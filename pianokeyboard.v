// octave assignment
module pianokeyboard(CLOCK_50,SW, LEDR, HEX0,GPIO);
    input CLOCK_50;
    input [17:0] SW; // to indicate the 7 octaves
    output [6:0] LEDR;
    output [6:0] HEX0;
    output [5:0] GPIO;
    wire octavenum;
    // assign to hex display:
    fsm fsm1(.IN(SW[6:0]),.OUT(octavenum),.clk(ClOCK_50));
    hex_display hex ( .IN(SW[6:0]), .OUT(HEX0[6:0]));
    piano_music music1(.clk(CLOCK_50),.state(octavenum),.note(SW[17:11]),.speaker(GPIO[5:0]))
     
    
endmodule
// hex display
module hex_display(IN, OUT);
    input [6:0] IN;
     output reg [7:0] OUT;
     
     always @(*)
     begin
     case(IN[6:0])
            7'b0000000: OUT = 7'b0011001; // octave 4  (default)
            7'b0000001: OUT = 7'b1111001; // octave 1
            7'b0000010: OUT = 7'b0100100; // octave 2
            7'b0000100: OUT = 7'b0110000; // octave 3
            7'b0001000: OUT = 7'b0011001; // octave 4
            7'b0010000: OUT = 7'b0010010; // octave 5
            7'b0100000: OUT = 7'b0000010; // octave 6
            7'b1000000: OUT = 7'b1111000; // octave 7

            default: OUT = 7'b0111111;
        endcase
    end
endmodule

module piano_music(clk,state,note,speaker);
    input clk;
    output speaker;
    input state;
    input [7:0] note;
    reg [14:0] counter;
    reg [32:0] divider;
    reg speaker;
    localparam note1= 50000000/32.7032; //C1
    localparam note2= 50000000/36.7081; //D1
    localparam note3= 50000000/41.2035; //E1
    localparam note4= 50000000/43.6536; //F1
    localparam note5= 50000000/48.9995; //G1
    localparam note6= 50000000/55.0000; //A1
    localparam note7= 50000000/61.7354; //B1
     
    always@(posedge clk)
        begin : octaves
                case(state)
                     4'd0:
                    case(note)
                                7'b0000000: divider <= 0;
                        7'b0000001: divider <= 0;
                        7'b0000010: divider <= 0;
                        7'b0000100: divider <= 0;
                        7'b0001000: divider <= 0;
                        7'b0010000: divider <= 0;
                        7'b0100000: divider <= 0;
                                7'b1000000: divider <=0;
                endcase
                4'd1:
                    case(note)
                                7'b0000000: divider <= 0;
                        7'b0000001: divider <= note1;
                        7'b0000010: divider <= note2;
                        7'b0000100: divider <= note3;
                        7'b0001000: divider <= note4;
                        7'b0010000: divider <= note5;
                        7'b0100000: divider <= note6;
                                7'b1000000: divider <= note7;
                endcase
                4'd2:
                    case(note)
                              7'b0000000: divider <= 0;
                        7'b0000001: divider <= note1 * 2;
                        7'b0000010: divider <= note2 * 2;
                        7'b0000100: divider <= note3 * 2;
                        7'b0001000: divider <= note4 * 2;
                        7'b0010000: divider <= note5 * 2;
                        7'b0100000: divider <= note6 * 2;
                                7'b1000000: divider <= note7 * 2;
                endcase
                4'd3:
                    case(note)
                              7'b0000000: divider <= 0;
                        7'b0000001: divider <= note1*4;
                        7'b0000010: divider <= note2*4;
                        7'b0000100: divider <= note3*4;
                        7'b0001000: divider <= note4*4;
                        7'b0010000: divider <= note5*4;
                        7'b0100000: divider <= note6*4;
                                7'b1000000: divider <= note7*4;
                endcase
                     endcase
    end
            
    always @(posedge clk) if(counter==0) counter<=divider-1; else counter <= counter-1;
    
    always @(posedge clk) if(counter==0 && divider !=0) speaker <= ~speaker;
endmodule

module fsm(IN,OUT,clk,reset);
    input clk;
    input [7:0] IN; //given by SW
    input reset;
    output reg OUT;
    //indicates which octave the frequency should be calculated for
    reg[7:0] curr, nxt;
     localparam octave0=4'd0;
    localparam octave1=4'd1;
    localparam octave2=4'd2;
    localparam octave3=4'd3;
    localparam octave4=4'd4;
    localparam octave5=4'd5;
    localparam octave6=4'd6;
    localparam octave7=4'd7;
        //state table for the fsm
    always@(curr,IN)
        begin:states
        case(curr)
                octave0:begin
                    if(IN==7'b0000000)
                        nxt<=4'd0;
                    else if(IN==7'b0000010)
                        nxt<=octave2;
                    else if(IN==7'b0000100)
                        nxt<=octave3;
                            else if(IN==7'b0000001)
                        nxt<=octave1;
                    end    
            octave1:begin
                if(IN==7'b0000001)
                    nxt<=octave1;
                else if(IN==7'b0000010)
                    nxt<=octave2;
                else if(IN==7'b0000100)
                    nxt<=octave3;
                end
            
            octave2:begin
                    if(IN==7'b0000001)
                        nxt<=octave1;
                    else if(IN==7'b0000010)
                        nxt<=octave2;
                    else if(IN==7'b0000100) 
                        nxt<=octave3;
                    end
            octave3:begin
                    if(IN==7'b0000001)
                        nxt<=octave1;
                    else if(IN==7'b0000010)
                        nxt<=octave2;
                    else if(IN==7'b0000100)
                        nxt<=octave3;
                    end    
            default: nxt<=octave0;
        endcase
    end
     always@(posedge clk)
        begin : state_reg
            curr <= nxt;
        end
    always@(curr)
        begin
            case(curr)
                octave1:begin
                    OUT<=octave1;
                end
                octave2:begin
                    OUT<=octave2;
                end
                octave3:begin
                    OUT<=octave3;
                end
                     octave4:begin
                         OUT<=octave4;
                     end
                     octave5:begin
                         OUT<=octave5;
                     end
                     octave6:begin
                         OUT<=octave6;
                     end
                     octave7:begin
                          OUT<=octave7;
                     end
            endcase
    end
endmodule
