# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array -g2012 -Y.sv -I ./hdl -I ./tests
VVP=vvp
VVP_POST=-fst
.PHONY: clean submission
PANDOC=pandoc
XOURNAL=xournalpp
PDFUNITE=pdfunite

ADDER_SOURCES=hdl/adder_1.sv hdl/adder_n.sv

test_comparators: tests/test_comparators.sv hdl/comparator_eq.sv hdl/comparator_lt.sv ${ADDER_SOURCES}
	${IVERILOG} $^ -o test_slt.bin && ${VVP} test_slt.bin ${VVP_POST}

waves_comparator: test_comparators
	gtkwave comparators.fst --save=wave_cfgs/comparators.gtkw

test_pulse_generator: tests/test_pulse_generator.sv hdl/pulse_generator.sv
	${IVERILOG} $^ -o test_pulse_generator.bin && ${VVP} test_pulse_generator.bin ${VVP_POST}

waves_pulse_generator: test_pulse_generator
	gtkwave pulse_generator.fst --save=wave_cfgs/pulse_generator.gtkw

test_triangle_generator: tests/test_triangle_generator.sv hdl/triangle_generator.sv
	${IVERILOG} $^ -o test_triangle_generator.bin && ${VVP} test_triangle_generator.bin ${VVP_POST}

waves_triangle_generator: test_triangle_generator
	gtkwave triangle_generator.fst --save=wave_cfgs/triangle_generator.gtkw

test_pwm: tests/test_pwm.sv hdl/pulse_generator.sv hdl/pwm.sv
	@echo "This might take a while, we're testing a lot of clock cycles..."
	${IVERILOG} $^ -o test_pwm.bin && ${VVP} test_pwm.bin ${VVP_POST}

waves_pwm: test_pwm
	gtkwave pwm.fst --save=wave_cfgs/pwm.gtkw

homework_pdf: README.md schematics/Schematics.xopp
	${PANDOC} README.md -o Questions.pdf
	${XOURNAL} schematics/Schematics.xopp -p schematics/Schematics.pdf
	${PDFUNITE} Questions.pdf schematics/Schematics.pdf Homework5.pdf
	rm Questions.pdf

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml schematics/Schematics.pdf

# Call this to generate your submission zip file.
submission: clean homework_pdf
	zip submission.zip Makefile hdl/*.sv tests/*.sv *.md *.pdf wave_cfgs/*.gtkw
