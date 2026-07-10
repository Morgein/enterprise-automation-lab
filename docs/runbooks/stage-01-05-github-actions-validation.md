# Stage 1.5 - GitHub Actions Validation Pipeline

## 1. Purpose

This document describes Stage 1.5 of the Enterprise Automation Lab.

The goal of this stage is to add an automated GitHub Actions validation pipeline for Ansible and YAML code.

Before this stage, validation was performed manually from Kali Linux WSL.

Manual validation commands included:

```bash
yamllint .
ansible-lint .
ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
```

After this stage, GitHub automatically runs these checks when code is pushed to the repository.

---

## 2. Why CI Validation Is Important

Infrastructure automation code should be validated before it is considered ready.

A CI pipeline helps detect:

- YAML syntax issues
- Ansible linting issues
- invalid playbook syntax
- missing roles
- broken project structure
- formatting problems

This improves reliability and makes the project closer to a real engineering workflow.

---

## 3. Workflow File Location

GitHub Actions workflows are stored in:

```text
.github/workflows/
```

The workflow created in this stage is:

```text
.github/workflows/ansible-validation.yml
```

---

## 4. Full Workflow File

```yaml
---
name: Ansible Validation

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: read

jobs:
  ansible-validation:
    name: Validate Ansible Code
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ansible

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install validation tools
        run: |
          python -m pip install --upgrade pip
          pip install ansible ansible-lint yamllint

      - name: Show tool versions
        run: |
          python --version
          ansible --version
          ansible-lint --version
          yamllint --version

      - name: Run yamllint
        working-directory: .
        run: yamllint .

      - name: Run ansible-lint
        run: ansible-lint .

      - name: Syntax check bootstrap playbook
        run: ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check

      - name: Syntax check role-based baseline playbook
        run: ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
```

---

## 5. Workflow Explanation

### name

```yaml
name: Ansible Validation
```

This is the workflow name shown in the GitHub Actions tab.

---

### on

```yaml
on:
```

This section defines when the workflow runs.

---

### push

```yaml
push:
  branches:
    - main
```

The workflow runs automatically when code is pushed to the `main` branch.

---

### pull_request

```yaml
pull_request:
  branches:
    - main
```

The workflow also runs when a pull request targets the `main` branch.

This is useful for future branch-based work.

---

### workflow_dispatch

```yaml
workflow_dispatch:
```

This allows the workflow to be started manually from the GitHub web interface.

---

### permissions

```yaml
permissions:
  contents: read
```

This gives the workflow read-only access to repository contents.

The validation job does not need write permissions.

---

### jobs

```yaml
jobs:
```

This section defines workflow jobs.

A job is a group of steps executed on a runner.

---

### ansible-validation

```yaml
ansible-validation:
```

This is the internal job identifier.

---

### job name

```yaml
name: Validate Ansible Code
```

This is the human-readable job name displayed in GitHub Actions.

---

### runs-on

```yaml
runs-on: ubuntu-latest
```

This tells GitHub to run the job on an Ubuntu runner.

Ubuntu is used because Ansible and Python tooling work well on Linux.

---

### defaults

```yaml
defaults:
  run:
    working-directory: ansible
```

This makes all `run` commands execute from the `ansible/` directory by default.

This is important because the project-specific Ansible configuration file is located at:

```text
ansible/ansible.cfg
```

Running Ansible commands from this directory ensures that Ansible can find:

```text
inventory
roles_path
ansible.cfg
```

---

### steps

```yaml
steps:
```

This section defines the ordered steps of the job.

Steps run from top to bottom.

---

### Checkout repository

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

This downloads the repository content into the GitHub Actions runner workspace.

Without this step, the runner would not have the project files available for validation.

---

### Set up Python

```yaml
- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: "3.12"
```

This installs and configures Python 3.12 on the runner.

Python is required because Ansible, ansible-lint and yamllint are Python-based tools.

---

### Install validation tools

```yaml
- name: Install validation tools
  run: |
    python -m pip install --upgrade pip
    pip install ansible ansible-lint yamllint
```

This installs the tools required for validation.

Installed tools:

| Tool | Purpose |
|---|---|
| ansible | Playbook syntax checking |
| ansible-lint | Ansible best practice validation |
| yamllint | YAML syntax and style validation |

---

### Show tool versions

```yaml
- name: Show tool versions
  run: |
    python --version
    ansible --version
    ansible-lint --version
    yamllint --version
```

This prints tool versions into the workflow logs.

This is useful for debugging if a future version changes behavior.

---

### Run yamllint

```yaml
- name: Run yamllint
  working-directory: .
  run: yamllint .
```

This validates YAML files in the repository.

The working directory is explicitly set to the repository root because YAML files exist outside the `ansible/` directory too.

Examples:

```text
.github/workflows/
docs/
ansible/
```

---

### Run ansible-lint

```yaml
- name: Run ansible-lint
  run: ansible-lint .
```

This validates the Ansible project.

Because the default working directory is `ansible/`, this command runs inside:

```text
ansible/
```

This allows Ansible to correctly load:

```text
ansible.cfg
roles/
inventories/
```

---

### Syntax check bootstrap playbook

```yaml
- name: Syntax check bootstrap playbook
  run: ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
```

This validates the syntax of the original bootstrap playbook.

It does not connect to the Hyper-V VM.

---

### Syntax check role-based baseline playbook

```yaml
- name: Syntax check role-based baseline playbook
  run: ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
```

This validates the role-based baseline playbook.

It also checks whether the `linux_baseline` role can be found.

---

## 6. Local Validation Before Push

Before pushing workflow changes, run:

```bash
cd ~/enterprise-automation-lab
yamllint .github/workflows/ansible-validation.yml
yamllint .

cd ansible
ansible-lint .
ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
```

If these pass locally, the GitHub Actions workflow is more likely to pass too.

---

## 7. Git Commands

Add the workflow:

```bash
git add .github/workflows/ansible-validation.yml
```

Add this documentation:

```bash
git add docs/runbooks/stage-01-05-github-actions-validation.md
```

Commit:

```bash
git commit -m "Add GitHub Actions validation pipeline"
```

Push:

```bash
git push
```

---

## 8. How to Check the Workflow on GitHub

After pushing, open the repository in GitHub.

Go to:

```text
Actions → Ansible Validation
```

Expected result:

```text
The workflow run should complete successfully.
```

A successful workflow usually shows a green check mark.

---

## 9. What This Pipeline Does Not Do

This pipeline does not apply configuration to the real Hyper-V VM.

It does not run:

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml
```

without `--syntax-check`.

Reason:

GitHub-hosted runners cannot access the local Hyper-V lab network.

The real managed node `web-01` exists only inside the local lab network.

Therefore, GitHub Actions is used for static validation only.

---

## 10. Troubleshooting

### Role Not Found

If GitHub Actions reports:

```text
the role 'linux_baseline' was not found
```

Check that commands are executed from the `ansible/` directory.

The workflow uses:

```yaml
defaults:
  run:
    working-directory: ansible
```

Also check:

```ini
roles_path = roles
```

inside:

```text
ansible/ansible.cfg
```

---

### yamllint Fails on Workflow File

If `yamllint` fails on the GitHub Actions file, check:

- indentation
- missing `---`
- line length
- invalid YAML syntax
- wrong spacing

Run locally:

```bash
yamllint .github/workflows/ansible-validation.yml
```

---

### ansible-lint Fails Locally but Not in GitHub Actions

This usually means the local command was run from a different directory.

Recommended local command:

```bash
cd ~/enterprise-automation-lab/ansible
ansible-lint .
```

---

### Syntax Check Fails Because Inventory Hosts Are Unreachable

Syntax check should not connect to hosts.

If Ansible tries to connect, confirm that the command includes:

```text
--syntax-check
```

---

## 11. Stage Result

At the end of this stage, the project has:

```text
GitHub Actions workflow created
Automatic YAML validation added
Automatic Ansible linting added
Automatic playbook syntax checks added
Read-only workflow permissions configured
Manual workflow trigger enabled
CI validation documented
```

---

## 12. Current Status

Current project status:

```text
Stage 1.5 - GitHub Actions validation pipeline completed
```

Next planned stage:

```text
Stage 1.6 - Add screenshots and badges to README
```

The next stage will improve the project presentation by adding a GitHub Actions status badge and clear validation evidence to the README.
