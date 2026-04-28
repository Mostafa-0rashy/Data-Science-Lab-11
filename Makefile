# TODO: Add common commands for students.
# Suggested targets:
# - setup: install dependencies
# - test: run tests
# - lint: run lint checks
# - clean: remove generated files

.PHONY: help setup test lint clean
PYTHON = python
setup:
	pip install -r requirements.txt
# example
reports/validation_raw.json: data/raw/Teen_Mental_Health_Dataset.csv src/data/validate.py
	$(PYTHON) src/data/validate.py --input data/raw/Teen_Mental_Health_Dataset.csv --output reports/validation_raw.json
validate: reports/validation_raw.json

data/processed/clean.csv: data/raw/Teen_Mental_Health_Dataset.csv src/data/preprocess.py
	$(PYTHON) src/data/preprocess.py --config configs/config.toml
clean_data: data/processed/clean.csv

reports/validation_cleaned.json: data/processed/clean.csv src/data/validate.py
	$(PYTHON) src/data/validate.py --input $< --output $@


#Feature Engineering
data/processed/features.csv: data/processed/clean.csv src/features/engineer.py
	$(PYTHON) src/features/engineer.py --config configs/config.toml

features: data/processed/features.csv

# Train Model
models/model_v1.pkl: data/processed/clean.csv src/models/train.py
	$(PYTHON) src/models/train.py --config configs/config.toml

train: models/model_v1.pkl

# Classify
models/best_model.pkl: data/processed/features.csv src/models/classify.py
	$(PYTHON) src/models/classify.py --config configs/config.toml

classify: models/best_model.pkl

#Report
reports/pipeline_report.md: src/reports/generate_report.py
	$(PYTHON) src/reports/generate_report.py --config configs/config.toml

report: reports/pipeline_report.md

# FULL PIPELINE
pipeline: validate clean_data reports/validation_cleaned.json features train classify report

# ========================
# TEST & LINT
# ========================
test:
	pytest

lint:
	flake8 src

clean:
	rm -rf data/processed/* reports/*.json reports/*.md models/*.pkl