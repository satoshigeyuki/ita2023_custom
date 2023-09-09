MASTER_DIR = masters
FORM_DIR = forms
TEST_DIR = tests
ANSWER_DIR = answers
RESULT_DIR = results
LIB_DIR = plags-scripts

EXERCISES = $(basename $(notdir $(wildcard $(MASTER_DIR)/*.ipynb)))
MASTERS = $(addprefix $(MASTER_DIR)/, $(addsuffix .ipynb, $(EXERCISES)))
PREFILLS = $(addprefix $(MASTER_DIR)/, $(addsuffix .py, $(EXERCISES)))
ANSWERS = $(addprefix $(ANSWER_DIR)/, $(addsuffix .py, $(EXERCISES)))
TESTS = $(addprefix $(TEST_DIR)/, $(EXERCISES))

RESERVED = ex02_1 ex02_2 ex02_3 ex02_4 ex02_5 ex02_6 ex02_7 ex02_8 ex03_1 ex03_2 ex03_3 ex03_4 ex03_5 ex03_6 ex03_7 ex04_1 ex04_2 ex04_3 ex04_4 ex04_5 ex04_6 ex04_7 ex04_8 ex04_9 ex05_1 ex05_2 ex05_3 ex06_1 ex06_2 ex06_3 ex07_1 ex07_2 ex07_3 ex07_4 ex07_5 ex07_6 ex08_1 ex08_2 ex08_3 ex08_4

ifneq ($(filter $(RESERVED), $(EXERCISES)),)
$(error Conflict with reserved exercise names: $(filter $(RESERVED), $(EXERCISES)))
endif

all:	conf.zip

conf.zip:	$(MASTERS) $(PREFILLS) test_mod.json drive.json
	mkdir -p $(FORM_DIR)
	python3 $(LIB_DIR)/build_as_is.py -f $(FORM_DIR) -c judge_env.json -ae test_mod.json -bt rawcheck_ita.py -gd drive.json -ac -qc $(MASTERS)
	env PYTHONPATH=$(LIB_DIR) python3 pip_install_ita_header.py $(FORM_DIR)/*.ipynb

$(PREFILLS):
	touch $@

drive.json:
	echo '{}' > $@

test_mod.json:	$(TESTS)
	python3 -c "import json,os,sys; print(json.dumps({os.path.basename(path): [os.path.join(path, x) for x in sorted(os.listdir(path)) if x.endswith('.py')] for path in sorted(sys.argv[1:])}, ensure_ascii=False, indent=4))" $(TESTS) > $@

$(TESTS):	$(wildcard $@/*.py)
	mkdir -p $@
	if [ $(words $(wildcard $@/*.py)) -ne 0 ]; then touch -r $$(ls -dt $@ $@/*.py | head -n 1) $@; fi

test:	test_mod.json
	python3 -c "import json,os,sys; print(json.dumps({os.path.basename(path)[:-3]: path for path in sorted(sys.argv[1:]) if path.endswith('.py')}, ensure_ascii=False, indent=4))" $(ANSWERS) > answer_mod.json
	mkdir -p $(FORM_DIR).tmp $(RESULT_DIR)
	python3 $(LIB_DIR)/build_as_is.py -ae test_mod.json -ac answer_mod.json -bt rawcheck_ita.py -qc -t $(RESULT_DIR) $(MASTERS)
	python3 $(LIB_DIR)/build_as_is.py -ae test_mod.json -ac answer_mod.json -bt rawcheck_ita.py -qc -t $(RESULT_DIR)/results.json $(MASTERS)
	rm -f answer_mod.json

clean:
	rm -fR conf.zip conf test_mod.json $(FORM_DIR) $(RESULT_DIR)

.PHONY: test clean
