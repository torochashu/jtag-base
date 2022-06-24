# Supported PLATFORM are 'microzed' and 'de10'
# TODO: Add DE10 support
PLATFORM=microzed
TOPMODULE=tb
SIM_EXEC=simv
SIM_LOG=sim.log
IVERILOG_OPTS=-g2012 -gstrict-ca-eval
VVP_OPTS=-l $(SIM_LOG)

compile:
	@iverilog -o $(SIM_EXEC) $(IVERILOG_OPTS) -f tb_$(PLATFORM).f

sim:
	@vvp $(VVP_OPTS) $(SIM_EXEC) -lxt2

clean:
	@rm -rf $(SIM_EXEC) $(SIM_LOG) *.lxt2
