`define CYCLE_TIME 6.0 // Cycle time in nanoseconds
`define PAT_NUM 1000    // Number of patterns
`define MAX_LATENCY 100 // Max latency for each pattern
`define OUT_NUM 1       // The number of output for each pattern
`define SEED 5487

module PATTERN (
    clk,
    rst_n,
    in_valid,
    in_data,
    addr_valid,
    addr,
    out_valid,
    out_data
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
// Output Registers
output reg clk, rst_n;
output reg in_valid;
output reg addr_valid;
output reg [7:0] in_data;
output reg [5:0] addr;

// Input Signals
input out_valid;
input [31:0] out_data;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
/* Parameters and Integers */
integer patnum = `PAT_NUM;
integer seed = `SEED;
integer i_pat;
integer latency;
integer total_latency;
integer i;
integer out_num;


//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg [7:0]  in_data_reg;
reg [5:0]  addr_reg;
reg [31:0] golden_out;
reg [31:0] RAM [0:63]; 
reg [5:0]  RAM_addr;


//---------------------------------------------------------------------
//  CLOCK
//---------------------------------------------------------------------
/* Define clock cycle */
real CYCLE = `CYCLE_TIME;
always #(CYCLE/2.0) clk = ~clk;

//---------------------------------------------------------------------
//  SIMULATION
//---------------------------------------------------------------------
/* Check for invalid overlap */
always @(*) begin
    if (in_valid && out_valid) begin
        $display("************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  The out_valid signal cannot overlap with in_valid.   *");
        $display("************************************************************");
        $finish;            
    end
    if (addr_valid && out_valid) begin
        $display("************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  The out_valid signal cannot overlap with addr_valid.   *");
        $display("************************************************************");
        $finish;            
    end
end

/* Check output value when out_valid is low */
always @(negedge clk) begin
    if (out_valid === 1'b0 && out_data !== 'b0) begin
        $display("************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  The out signal should be zero when out_valid is low.   *");
        $display("************************************************************");
        repeat (5) #CYCLE;
		$finish;            
    end    
end

initial begin
    rst_n           = 1'b1;
    in_valid        = 1'b0;
    addr_valid      = 1'b0;
    in_data         = 8'bx;
    addr            = 6'bx;
    total_latency   = 0;
    latency         = 0;
    golden_out      = 0;
end

/* execution */
initial begin
    reset_task;
    ram_input_task;
    for (i_pat = 0; i_pat < patnum; i_pat = i_pat + 1) begin
        input_task;
        wait_out_valid_task;
        compute_out_task;
        check_ans_task;
        $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m     Execution Cycle: %3d\033[m", i_pat, latency);
    end
    YOU_PASS_task;
end


// Task to reset the system
task reset_task; begin 
    rst_n = 1'b1;
    force clk = 0;

    #(CYCLE*2.0); rst_n = 1'b0; 
    #(CYCLE*2.0); rst_n = 1'b1;
    if (out_valid !== 'b0 || out_data !== 'b0) begin
        $display("************************************************************");
        $display("                          FAIL!                           ");
        $display("*  Output signals should be 0 after initial RESET at %8t *", $time);
        $display("************************************************************");
        repeat (2) #CYCLE;
        $finish;
    end
    #(CYCLE*2.0); release clk;
end endtask

// Task
task ram_input_task; begin
    repeat (4) @(negedge clk);
    in_valid = 1'b1;
    for(i = 0 ; i < 256 ; i = i + 1) begin
        in_data_reg = $random(seed);
        in_data = in_data_reg;
        @(negedge clk);
    end
    in_valid = 1'b0;
    in_data  = 8'dx;
end endtask


task input_task; begin
    repeat (2) @(negedge clk);
    addr_reg    = $random(seed);
    addr        = addr_reg;
    addr_valid  = 1'b1;

    @(negedge clk);
    addr        = 8'dx;
    addr_valid  = 1'b0;
end endtask


// Wait until out_valid is high
task wait_out_valid_task; begin
    latency = 0;
    while (out_valid !== 1'b1) begin
        latency = latency + 1;
        if (latency == `MAX_LATENCY) begin
            $display("********************************************************");     
            $display("                          FAIL!                           ");
            $display("*  The execution latency exceeded %d cycles at %8t   *", `MAX_LATENCY, $time);
            $display("********************************************************");
            repeat (2) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end endtask


task compute_out_task; begin
    golden_out = RAM[addr_reg];
end endtask


task check_ans_task; begin
    out_num = 0;
    while (out_valid === 1) begin
        if (out_data !== golden_out) begin
            $display("************************************************************");  
            $display("                          FAIL!                           ");
            $display(" Expected:  = %h", golden_out);
            $display(" Received:  = %h", out_data);
            $display("************************************************************");
            repeat (4) @(negedge clk);
            $finish;
        end 
        else begin
            @(negedge clk);
            out_num = out_num + 1;
        end
    end
    if(out_num !== `OUT_NUM) begin
        $display("************************************************************");  
        $display("                          FAIL!                              ");
        $display(" Expected one valid output, but found %d", out_num);
        $display("************************************************************");
        repeat(4) @(negedge clk);
        $finish;
    end
end endtask


task YOU_PASS_task; begin
    $display("----------------------------------------------------------------------------------------------------------------------");
    $display("                                                  Congratulations!                                                    ");
    $display("                                           You have passed all patterns!                                               ");
    $display("                                           Your execution cycles = %5d cycles                                          ", total_latency);
    $display("                                           Your clock period = %.1f ns                                                 ", CYCLE);
    $display("                                           Total Latency = %.1f ns                                                    ", total_latency * CYCLE);
    $display("----------------------------------------------------------------------------------------------------------------------");
    repeat (2) @(negedge clk);
    $finish;
end endtask

reg [7:0] data_buffer [0:3];
reg [1:0] count;
reg in_valid_reg;

always @(posedge clk) begin
    in_valid_reg <= in_valid;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        count <= 'd0;
    end
    else if(in_valid_reg) begin
        count <= count + 'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_buffer[0] <= 'd0;
        data_buffer[1] <= 'd0;
        data_buffer[2] <= 'd0;
        data_buffer[3] <= 'd0;
    end
    else if(in_valid) begin
        data_buffer[0] <= in_data;
        data_buffer[1] <= data_buffer[0];
        data_buffer[2] <= data_buffer[1];
        data_buffer[3] <= data_buffer[2];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i=0; i<64; i=i+1) begin
            RAM[i] <= 'd0;
        end
    end
    else if (count == 'd3) begin
        RAM[RAM_addr] <= {data_buffer[0], data_buffer[1], data_buffer[2], data_buffer[3]};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        RAM_addr <= 'd0;
    end
    else if (count == 'd3) begin
        RAM_addr <= RAM_addr + 'd1;
    end
end


endmodule
