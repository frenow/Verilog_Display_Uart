module counterM(
    input clk,
    output reg [7:0] counterValue = 0
);
    reg [32:0] clockCounter = 0;

    localparam WAIT_TIME = 27000000;

    always @(posedge clk) begin
        if (clockCounter == WAIT_TIME) begin
            clockCounter <= 0;
            counterValue <= counterValue + 1;
        end
        else
            clockCounter <= clockCounter + 1;
    end
endmodule

module top #(parameter STARTUP_WAIT = 32'd10000000)
            (input CLK, RXD, output TXD, output reg LED0, LED1, LED2, LED3, LED4, LED5,
             output ioSclk, ioSdin, ioCs, ioDc, ioReset);

   //display
   wire [9:0] pixelAddress;
   wire [7:0] textPixelData, chosenPixelData;
   wire [5:0] charAddress;
   reg  [7:0] charOutput;
   wire [1:0] rowNumber;
   wire [7:0] charOut1, charOut2, charOut3, charOut4;

   wire [7:0] counterValue;
   
   //uart 
   wire       reset = 1;
   reg        start;
   wire       busy;
   wire       byteReady;
   wire [7:0] uartDataIn;
   reg [31:0] sec_clk;
   reg 	      send = 0;
   reg [7:0]  tx_char = 8'b0;
   wire	      tx_busy;

   uart_rx rx(.clk(CLK), .byteReady(byteReady), .dataIn(uartDataIn), .rx(RXD)); //rec
   uart_tx tx(.clk(CLK), .tx(TXD), .send(send), .data(tx_char), .busy(busy)); //env

   screen #(STARTUP_WAIT) scr(.clk(CLK), .ioSclk(ioSclk), .ioSdin(ioSdin), .ioCs(ioCs), .ioDc(ioDc), .ioReset(ioReset), .pixelAddress(pixelAddress), .pixelData(textPixelData)); //inicializa tela

   assign rowNumber = charAddress[5:4]; //posiciona a linha da impressao na memoria

   uartTextRow row(.clk(CLK), .byteReady(byteReady), .data(uartDataIn), .outputCharIndex(charAddress[3:0]), .outByte1(charOut1), .outByte2(charOut2), .outByte3(charOut3), .outByte4(charOut4)); //prepara linha

   counterM c(.clk(CLK), .counterValue(counterValue));

   textEngine te(.clk(CLK), .pixelAddress(pixelAddress), .pixelData(textPixelData), .charAddress(charAddress), .charOutput(charOutput)); //escreve na tela

  always @(negedge reset or posedge CLK) 
  begin
   if(!reset)
	begin
	   send  = 0;
	   start = 0;
	end
   else 
   begin
        case (rowNumber)
            0: charOutput <= charOut1;
            1: charOutput <= charOut2;
            2: charOutput <= charOut3;
            3: charOutput <= charOut4;
        endcase
      
      if (busy)
	      send = 0;

      if(!busy && !send)
         begin
            if(byteReady)
            begin
               LED0 = ~counterValue[5:5];
               LED1 = ~counterValue[4:4];
               LED2 = ~counterValue[3:3];
               LED3 = ~counterValue[2:2];
               LED4 = ~counterValue[1:1];
               LED5 = ~counterValue[0:0];  

               tx_char = uartDataIn;
               send  = 1;
               start  = 0;
            end
            else
            begin
                start = 1;
                send = 0;
            end
         end 
   end

  end

  //assign LED0 = 1;
  //assign LED1 = 1;
  //assign LED2 = 1;
  //assign LED3 = 1;
  //assign LED4 = 1;
  //assign LED5 = 1;

endmodule