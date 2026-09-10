# Continuous Integration with GitLab CI/CD

## Learning Outcomes

By the end of this session, students will be able to:

1. Explain what Continuous Integration (CI) is and why it matters in software engineering.
2. Create and customize a GitLab CI/CD pipeline configuration to run tests automatically.
3. Use parallel matrix execution and caching to speed up and standardise builds.
4. Protect `main` using Merge Request rules and required pipeline status checks.

---

## Why Continuous Integration?

- Catches integration errors early (small, frequent, automated).
- Creates reproducible builds and standardised environments.
- Provides fast feedback loops for developers.
- Enforces quality gates: only “green” pipelines merge to `main`.

---

## GitLab CI/CD Concepts

- **Pipeline Configuration:** A single YAML file named `.gitlab-ci.yml` placed in the root directory of your project.
- **Pipelines, Stages, and Jobs:** 
  - A **Pipeline** is top-level; it contains **Stages** (e.g., `build`, `test`, `deploy`).
  - **Jobs** define *what* to do (shell commands) and belong to a stage. Jobs in the same stage run in parallel; stages run sequentially.
- **Runners & Images:** Jobs are executed by a **GitLab Runner** (GitLab SaaS-hosted or self-hosted), typically using an isolated **Docker image** (e.g., `image: python:3.10`).
- **Predefined Variables:** `$CI_COMMIT_BRANCH`, `$CI_MERGE_REQUEST_IID`, and `$CI_PROJECT_DIR` provide runtime metadata (comparable to GitHub context objects).

---

### Pipelines, Runners, and Environments

- **Triggers / Rules:** Managed via the `rules:` block (`if: $CI_PIPELINE_SOURCE == "push"`, merge requests, schedules, manual actions).
- **Runners:** SaaS runners tagged with tags like `saas-linux-small-amd64` (or custom tags for self-hosted instances).
- **No Marketplace Needed:** Instead of marketplace setup actions, GitLab native architecture uses official Docker container images directly (`image: python:3.10`), while built-in `cache:` and `artifacts:` keywords replace third-party actions.

---

## 8. Setup

First login to GitLab and create a **new blank public project** (repository) named `python-ci`. The URL for that repo will be `https://gitlab.com/your-account/python-ci`. Then open `git-bash` and execute the following commands:

```bash
$ git clone [https://github.com/hikmatfarhat-ndu/python-ci](https://github.com/hikmatfarhat-ndu/python-ci)
$ cd python-ci
```

This clones the initial lab repo onto your local computer. The repo has two Python files: add.py and test_add.py.

add.py

```python
def add(x: int, y: int) -> int:
    """Returns the sum of two integers."""
    return x + y
```

test_add.py
```python
from add import add
import pytest

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0

def test_add_type_error():
    with pytest.raises(TypeError):
        add(2, 3.3)
```

Now, remove the .github directory and create the root GitLab CI configuration:
```bash
$ rm -rf .github
$ touch .gitlab-ci.yml
```

9. GitLab CI/CD
GitLab CI runs pipelines defined in a file called `.gitlab-ci.yml` at the root of your project. Every time code is pushed, GitLab looks for this file and executes the jobs on an available GitLab Runner.

Open `.gitlab-ci.yml` in your code editor and add the following configuration:

Minimal CI Pipeline (.gitlab-ci.yml)
```yaml
stages:
  - test

test-job:
  stage: test
  image: python:3.10
  before_script:
    - python -m pip install --upgrade pip
    - pip install pytest
    - if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
  script:
    - pytest -q
```
Explanation
image: python:3.10: Unlike GitHub Actions which requires an operating system runner and a setup action, GitLab runs directly inside a Docker container. Specifying this image provides an environment with Python 3.10 and pip pre-installed.

GitLab automatic checkout: You do not need an equivalent of actions/checkout. GitLab Runner automatically clones the repository and checks out the specific commit inside the container work directory before executing.

before_script: Commands executed before the primary task—used here to install testing tools and requirements.

script: The required commands that determine whether the job passes or fails. If pytest -q returns an exit code other than 0, the job fails.

To proceed, point your local repository to your newly created GitLab project:
```bash
$ git remote set-url origin <your GitLab repo url>
$ git add .
$ git commit -m "initialize gitlab ci pipeline"
$ git push -u origin main
```

Because of the push, the files are uploaded to GitLab. In the left navigation menu, go to Build > Pipelines. You will see the pipeline running or finished with a failed badge:

Click on the failed job (test-job). You will see the job log: add.py failed one of the unit tests because it did not validate that the arguments were integers.

Open add.py and update it with the fix:

```python
def add(x: int, y: int) -> int:
    if not isinstance(x, int) or not isinstance(y, int):
        raise TypeError("Both arguments must be integers")
    """Returns the sum of two integers."""
    return x + y
```
Commit and push your fix:
```bash
$ git commit -a -m "added argument check to function add"
$ git push
```
Return to Build > Pipelines. The new pipeline will show a green Passed status.

10. Protecting the Main Branch
To keep the main branch stable, team members should never push directly to main. Instead, work is submitted through a Merge Request (MR) and merged only when pipelines pass.

In GitLab, the default branch (main) is protected by default against direct pushes from Developers, but we will configure it to strictly require Merge Requests and passing pipelines.

Configuring Branch and Merge Checks:
Go to Settings > Repository in the left sidebar.

Expand Protected branches. Ensure main is listed under "Protected branch".

Set Allowed to push and merge to No one (or Maintainers only, but block direct commits).

Go to Settings > Merge requests.

Scroll to Merge checks (or Merge options) and check:

Pipelines must succeed (Prevents merging if the CI pipeline is red).

All threads must be resolved.

Click Save changes.

Testing the Branch Rule
Test the protection by breaking the test. Comment out the parameter check in add.py:

```python
def add(x: int, y: int) -> int:
    # if not isinstance(x, int) or not isinstance(y, int):
    #     raise TypeError("Both parameters must be integers.")
    """Returns the sum of two integers."""
    return x + y
```
Attempt to push directly to main:
```bash
$ git commit -a -m "commented out raise TypeError"
$ git push
```
GitLab rejects the push:
```
remote: GitLab: You are not allowed to push code to protected branches on this project.
To [https://git.soton.ac.uk/your-account/python-ci.git](https://git.soton.ac.uk/your-account/python-ci.git)
 ! [remote rejected] main -> main (pre-receive hook declined)
error: failed to push some refs
```

Now use the proper workflow: revert your local commit, make a new feature branch (dev), and push:
```bash
$ git reset --hard HEAD~1
$ git checkout -b dev
```
Re-comment the type checks in add.py, then:
```bash
$ git commit -a -m "commented out raise TypeError on dev"
$ git push -u origin dev
```
On your project’s GitLab page, a prompt will appear: Create merge request. Click it.

On the Merge Request screen:

Source branch: dev

Target branch: main

Click Create merge request.

You will see the pipeline run for this MR and fail. Notice that the Merge button is disabled with a warning: "A pipeline must succeed before this merge request can be merged."

To resolve this, restore the check in add.py
```python
def add(x: int, y: int) -> int:
    if not isinstance(x, int) or not isinstance(y, int):
        raise TypeError("Both arguments must be integers")
    return x + y
```

Commit and push from dev:
```bash
$ git commit -a -m "uncommented the raise TypeError"
$ git push
```
The pipeline re-runs automatically inside the open Merge Request. Once it turns green, the Merge button activates. Click Merge.

On your local terminal:
```bash
$ git switch main
$ git pull
```
11. Code Review (Approvals)
In team environments, code should be reviewed before being merged into the primary branch.

Go to Manage > Members and click Invite members. Add your lab partner’s GitLab username with the Developer role. Have them accept or verify access.

Go to Settings > Merge requests.

Under Merge request approvals, locate the target branch rules. Click Add approval rule:

Rule name: Peer Review

Target branch: main

Approvals required: 1

Approvers: Select your partner's username or project group.

Click Save changes.

Now on branch dev, add an integer division function to add.py:
```python
def add(x: int, y: int) -> int:
    if not isinstance(x, int) or not isinstance(y, int):
        raise TypeError("Both parameters must be integers.")
    """Returns the sum of two integers."""
    return x + y

def div(x: int, y: int) -> int:
    return x // y
```
Commit and push
```bash
$ git commit -a -m "implemented integer division"
$ git push
```
Create a new Merge Request from dev to main.

Even though the pipeline passes, the Merge button remains blocked with the message: Approval required.

Have your partner navigate to the Merge Request:

Click the Changes tab to review the diff.

Add inline comments on lines of code if necessary.

Click the Approve button at the top right of the Merge Request.

Once approved, the status changes to show the required approvals have been satisfied, and the MR can be merged into main.

12. Caching
Installing dependencies repeatedly on fresh Docker runners wastes execution time and network bandwidth. We can cache downloaded packages across pipeline runs using GitLab’s native cache keyword.

In Python, pip stores downloaded .whl and tarballs in an internal cache directory. By pointing PIP_CACHE_DIR inside our project folder, GitLab Runner can save and restore it across runs.

Update .gitlab-ci.yml:

```yaml
stages:
  - test

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

cache:
  key:
    files:
      - requirements.txt
  paths:
    - .cache/pip

test-job:
  stage: test
  image: python:3.10
  before_script:
    - python -m pip install --upgrade pip
    - pip install pytest
    - if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
  script:
    - pytest -q
```
Rename req.txt to requirements.txt:
```bash
$ mv req.txt requirements.txt
$git add .$ git commit -m "configure pip cache and add requirements.txt"
$ git push
```
Explanation
PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip": GitLab Runner can only cache directories located inside the project repository folder ($CI_PROJECT_DIR). We instruct pip to place its cache here instead of ~/.cache/pip.

cache:key:files: Generates a SHA hash of requirements.txt. If requirements.txt does not change, future jobs immediately restore the cached wheels without downloading them again.

cache:paths: The relative folder paths to preserve between runs.

13. Testing Multiple Python Versions (Parallel Matrix)

To test code across multiple Python releases without duplicating job configurations, use GitLab’s parallel:matrix feature:
```yaml
stages:
  - test

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

cache:
  key:
    files:
      - requirements.txt
  paths:
    - .cache/pip

test-matrix-job:
  stage: test
  image: python:${PYTHON_VERSION}
  parallel:
    matrix:
      - PYTHON_VERSION: ["3.10", "3.11", "3.12"]
  before_script:
    - python -m pip install --upgrade pip
    - pip install pytest
    - if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
  script:
    - python --version
    - pytest -q
```
Commit and push your changes:
```bash
$ git commit -a -m "add parallel test matrix for python versions"
$ git push
```
Navigate to Build > Pipelines and click on your latest pipeline. You will see 3 distinct jobs (test-matrix-job: [3.10], test-matrix-job: [3.11], and test-matrix-job: [3.12]) generated and executing in parallel across distinct Docker containers.