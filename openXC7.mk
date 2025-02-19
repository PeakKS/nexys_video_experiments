NEXTPNR_XILINX_DIR ?= /snap/openxc7/current/opt/nextpnr-xilinx
NEXTPNR_XILINX_PYTHON_DIR ?= ${NEXTPNR_XILINX_DIR}/python
PRJXRAY_DB_DIR ?= ${NEXTPNR_XILINX_DIR}/external/prjxray-db
YOSYS_INCDIR = $(shell yosys-config --datdir)/include
CXXRTL_RT_INCDIR = ${YOSYS_INCDIR}/backends/cxxrtl/runtime

################################################################################
CXX = clang++
CXXFLAGS += -ggdb3 -O3 -std=c++14 -I ${CXXRTL_RT_INCDIR}

DBPART = $(shell echo ${PART} | sed -e 's/-[0-9]//g')
SPEEDGRADE = $(shell echo ${PART} | sed -e 's/.*\-\([0-9]\)/\1/g')

CHIPDB ?= ../chipdb/
ifeq ($(CHIPDB),)
CHIPDB = ../chipdb/
endif

PYPY3 ?= pypy3

TOP ?= ${PROJECT}
TOP_MODULE ?= ${TOP}
TOP_VHDL ?= ${TOP}.vhd
TOP_CXX ?= ${TOP}.cc
TOP_SIM ?= ${TOP}_sim

MAIN_CXX ?= main.cc

LIBRARY ?= work

PNR_DEBUG ?= # --verbose --debug

BOARD ?= UNKNOWN
# JTAG_LINK ?= --board ${BOARD}
JTAG_LINK ?= --board nexysVideo

XDC ?= ${PROJECT}.xdc

.PHONY: all
all: ${PROJECT}.bit

.PHONY: program
program: ${PROJECT}.bit
	openFPGALoader ${JTAG_LINK} --bitstream $<

.PHONY: simulate
simulate: ${TOP_SIM}
	./$<

${TOP_SIM}: ${MAIN_CXX} ${TOP_CXX}
	${CXX} ${CXXFLAGS} ${MAIN_CXX} -o $@

${TOP_CXX}: ${TOP_VHDL} ${ADDITIONAL_SOURCES}
	yosys -m ghdl.so -p "ghdl ${TOP_VHDL} ${ADDITIONAL_SOURCES} -e ${TOP_MODULE}; write_cxxrtl ${TOP_CXX}"

${PROJECT}.json: ${TOP_VHDL} ${ADDITIONAL_SOURCES}
	yosys -m ghdl.so -p "ghdl ${TOP_VHDL} ${ADDITIONAL_SOURCES} -e ${TOP_MODULE}; synth_xilinx -flatten -abc9 ${SYNTH_OPTS} -arch xc7 -top ${TOP_MODULE}; write_json ${PROJECT}.json"

# The chip database only needs to be generated once
# that is why we don't clean it with make clean
${CHIPDB}/${DBPART}.bin:
	${PYPY3} ${NEXTPNR_XILINX_PYTHON_DIR}/bbaexport.py --device ${PART} --bba ${DBPART}.bba
	bbasm -l ${DBPART}.bba ${CHIPDB}/${DBPART}.bin
	rm -f ${DBPART}.bba

${PROJECT}.fasm: ${PROJECT}.json ${CHIPDB}/${DBPART}.bin ${XDC}
	nextpnr-xilinx --chipdb ${CHIPDB}/${DBPART}.bin --xdc ${XDC} --json ${PROJECT}.json --fasm $@ ${PNR_ARGS} ${PNR_DEBUG}
	
${PROJECT}.frames: ${PROJECT}.fasm
	fasm2frames --part ${PART} --db-root ${PRJXRAY_DB_DIR}/${FAMILY} $< > $@

${PROJECT}.bit: ${PROJECT}.frames
	xc7frames2bit --part_file ${PRJXRAY_DB_DIR}/${FAMILY}/${PART}/part.yaml --part_name ${PART} --frm_file $< --output_file $@

.PHONY: clean
clean:
	@rm -f ${TOP_SIM}
	@rm -f ${TOP_CXX}
	@rm -f *.bit
	@rm -f *.frames
	@rm -f *.fasm
	@rm -f *.json
	@rm -f *.vcd

.PHONY: pnrclean
pnrclean:
	rm *.fasm *.frames *.bit
