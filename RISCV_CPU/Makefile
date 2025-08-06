TEST_MODULE?=CPU_Top

TOP_MODULE?=$(TEST_MODULE)_tb_top

FILE_LIST?=file.f

UVM_TEST?=base_test

UVM_VERBOSITY?=UVM_MEDIUM
NO_OF_TRANSACTIONS?=1

ifeq ($(OS),Windows_NT)
    RM_CMD = powershell if (Test-Path $(TEST_MODULE)) { Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $(TEST_MODULE) }
else
    RM_CMD = rm -rf $(TEST_MODULE)
endif

all: clean run_uvm

run_uvm: 
# 	mkdir $(TEST_MODULE)
	qrun -verbose -lint=default -parallel -vlog.sv \
		-vopt.access=rw+/. \
		-f $(FILE_LIST) \
		+define+NO_OF_TRANSACTIONS=$(NO_OF_TRANSACTIONS) \
		+define+UVM_NO_DEPRECATED \
		+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
		-top $(TOP_MODULE) \
		+UVM_TESTNAME=$(UVM_TEST) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		-coverage +cover=bcestf\
		-outdir $(TEST_MODULE) \
		-l $(TEST_MODULE)/qrun.log \
		-designfile $(TEST_MODULE)/$(TEST_MODULE).bin \
		-qwavedb=+memory=all+assertion+cell+signal+class+wavefile=$(TEST_MODULE)/$(TEST_MODULE).db

report_coverage: 
	@echo ""
	@echo "=============== COVERAGE SUMMARY ==============="
	vcover report -summary $(UVM_TEST)_0.ucdb
	@echo "================================================"

report_html: run_uvm
	@echo ""
	@echo "=============== GENERATING HTML REPORT ==============="
	vcover report -html -output $(TEST_MODULE)/coverage_html $(UVM_TEST)_0.ucdb
	@echo "HTML report generated in: $(TEST_MODULE)/coverage_html"
	@echo "===================================================="

clean:
	$(RM_CMD)

run_no_uvm:	
# 	mkdir $(TEST_MODULE)
	qrun -verbose -lint=default -parallel -vlog.sv \
		-vopt.access=rw+/. \
		-f $(FILE_LIST) \
		-top $(TOP_MODULE) \
		-outdir $(TEST_MODULE) \
		-l $(TEST_MODULE)/qrun.log \
		-designfile $(TEST_MODULE)/$(TEST_MODULE).bin \
		-qwavedb=+memory=all+assertion+cell+signal+class+wavefile=$(TEST_MODULE)/$(TEST_MODULE).db

.PHONY: all clean run_uvm