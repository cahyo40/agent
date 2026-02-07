---
name: data-science-notebook-developer
description: "Expert Jupyter/Colab notebook development including interactive analysis, visualization, reproducible research, and notebook best practices"
---

# Data Science Notebook Developer

## Overview

This skill transforms you into an expert in developing professional data science notebooks using Jupyter, Google Colab, and related tools. You'll create reproducible, well-documented, and visually appealing notebooks for data analysis, machine learning, and research.

## When to Use This Skill

- Creating exploratory data analysis (EDA) notebooks
- Building interactive data visualizations
- Developing reproducible ML experiment notebooks
- Setting up Jupyter environments and extensions
- Converting notebooks to reports, slides, or scripts

## Notebook Environments

### JupyterLab Setup

```bash
# Install JupyterLab with extensions
pip install jupyterlab jupyterlab-git jupyterlab-lsp
pip install ipywidgets plotly nbconvert

# Start JupyterLab
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser
```

### Google Colab Integration

```python
# Mount Google Drive
from google.colab import drive
drive.mount('/content/drive')

# Install packages
!pip install -q transformers datasets

# GPU check
import torch
print(f"GPU: {torch.cuda.get_device_name(0)}" if torch.cuda.is_available() else "CPU only")
```

## Notebook Structure Pattern

```markdown
# Project Title
> Brief description and objective

## 1. Setup & Imports
## 2. Data Loading
## 3. Exploratory Data Analysis (EDA)
## 4. Data Preprocessing
## 5. Modeling / Analysis
## 6. Results & Visualization
## 7. Conclusions
## Appendix (optional)
```

## Core Techniques

### Magic Commands

```python
# Timing
%time result = expensive_function()
%%timeit  # For cell timing

# Autoreload modules
%load_ext autoreload
%autoreload 2

# Environment variables
%env API_KEY=your_key

# Run external scripts
%run script.py

# Display plots inline
%matplotlib inline

# Show variables
%who  # All variables
%whos # Detailed info
```

### Interactive Widgets

```python
import ipywidgets as widgets
from IPython.display import display

# Slider
slider = widgets.IntSlider(value=50, min=0, max=100, description='Threshold:')

# Dropdown
dropdown = widgets.Dropdown(
    options=['Linear', 'Polynomial', 'RBF'],
    value='Linear',
    description='Kernel:'
)

# Interactive function
@widgets.interact
def plot_function(n=(1, 10), amplitude=(0.1, 2.0)):
    x = np.linspace(0, 10, 100)
    plt.plot(x, amplitude * np.sin(n * x))
    plt.show()
```

### Rich Display

```python
from IPython.display import HTML, Markdown, Image, display

# Styled HTML
display(HTML("<h2 style='color:blue'>Results</h2>"))

# Markdown
display(Markdown("**Important:** This is a key finding"))

# DataFrame styling
df.style.background_gradient(cmap='Blues').highlight_max(color='yellow')

# Progress bars
from tqdm.notebook import tqdm
for i in tqdm(range(100)):
    process(i)
```

## Visualization Patterns

### Plotly Interactive Charts

```python
import plotly.express as px

# Interactive scatter
fig = px.scatter(df, x='x', y='y', color='category', 
                 hover_data=['name'], size='value',
                 title='Interactive Analysis')
fig.show()

# Dashboard layout
from plotly.subplots import make_subplots
fig = make_subplots(rows=2, cols=2)
```

### Publication-Ready Matplotlib

```python
import matplotlib.pyplot as plt

plt.style.use('seaborn-v0_8-whitegrid')
fig, ax = plt.subplots(figsize=(10, 6), dpi=150)

ax.plot(x, y, 'b-', linewidth=2, label='Model')
ax.fill_between(x, y_lower, y_upper, alpha=0.3)
ax.set_xlabel('X Label', fontsize=12)
ax.set_ylabel('Y Label', fontsize=12)
ax.legend(loc='best')
ax.set_title('Publication Ready Figure', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig('figure.png', dpi=300, bbox_inches='tight')
```

## Notebook Export & Conversion

```bash
# To HTML report
jupyter nbconvert --to html notebook.ipynb

# To PDF (requires LaTeX)
jupyter nbconvert --to pdf notebook.ipynb

# To Python script
jupyter nbconvert --to script notebook.ipynb

# To slides
jupyter nbconvert --to slides notebook.ipynb --post serve

# Execute and save
jupyter nbconvert --execute --to notebook notebook.ipynb
```

### Papermill (Parameterized Notebooks)

```python
import papermill as pm

pm.execute_notebook(
    'template.ipynb',
    'output.ipynb',
    parameters={'dataset': 'sales_2024.csv', 'threshold': 0.8}
)
```

## Best Practices

### ✅ Do This

- Clear outputs before committing to git
- Use markdown cells for documentation
- Keep cells focused (one concept per cell)
- Include requirements.txt or environment.yml
- Add table of contents for long notebooks
- Use descriptive variable names
- Create reusable utility functions

### ❌ Avoid

- Don't leave debugging cells in final notebook
- Don't hardcode file paths (use relative or env vars)
- Don't skip error handling in production notebooks
- Don't mix unrelated analyses in one notebook
- Don't forget random seeds for reproducibility

## Reproducibility Checklist

```python
# Pin random seeds
import random
import numpy as np

SEED = 42
random.seed(SEED)
np.random.seed(SEED)

# Environment info
import sys
print(f"Python: {sys.version}")
print(f"NumPy: {np.__version__}")
print(f"Pandas: {pd.__version__}")

# Requirements export
!pip freeze > requirements.txt
```

## Related Skills

- `@senior-data-analyst` - Data analysis
- `@senior-ai-ml-engineer` - ML workflows
- `@r-data-scientist` - R notebooks
- `@senior-python-developer` - Python best practices
