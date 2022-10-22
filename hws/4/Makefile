# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -g2012 -Wall -y ./ -I ./
VVP=vvp
VVP_POST=-fst
# VIVADO=vivado -mode batch -source

MUX_SRCS = ./mux*.sv
ADD_SRCS = ./add*.sv

# Look up .PHONY rules for Makefiles
.PHONY: clean submission

test_practice : practice.sv test_practice.sv
	${IVERILOG} $^ -o test_practice.bin && ${VVP} test_practice.bin ${VVP_POST}

waves_practice : test_practice
	gtkwave practice.fst -a practice.gtkw

test_mux2: test_mux2.sv ${MUX_SRCS}
	${IVERILOG} $^ -o test_mux2.bin && ${VVP} test_mux2.bin ${VVP_POST}

test_mux4: test_mux4.sv ${MUX_SRCS}
	${IVERILOG} $^ -o test_mux4.bin && ${VVP} test_mux4.bin ${VVP_POST}

test_mux16: test_mux16.sv ${MUX_SRCS}
	${IVERILOG} $^ -o test_mux16.bin && ${VVP} test_mux16.bin ${VVP_POST}

test_mux32: test_mux32.sv ${MUX_SRCS}
	${IVERILOG} $^ -o test_mux32.bin && ${VVP} test_mux32.bin ${VVP_POST}

test_add1: test_add1.sv ${ADD_SRCS}
	${IVERILOG} $^ -o test_add1.bin && ${VVP} test_add1.bin ${VVP_POST}

test_addn: test_addn.sv ${ADD_SRCS}
	${IVERILOG} $^ -o test_addn.bin && ${VVP} test_addn.bin ${VVP_POST}

# add targets for your tests of your adders and muxes here!



# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml
	rm -rf .Xil

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile *.sv README.md *.pdf
