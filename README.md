# GIT

## Basics

### Initialization
Typically there are two ways to start version control on a directory. The first is initializing the directory
to be under version control.

There are three states: working directory, staging area (or index), and committed. The index contains information on what **will be** in the next commit.

We start with an example. The file you are reading is currently in the working directory.
```bash
>git init
>git status
On branch master
No commits yet
nothing to commit (create/copy files and use "git add" to track)
```
Now create a new file, ```file.txt```
```bash
>echo "first version of file1" > file1.txt
>git log
fatal: your current branch 'master' does not have any commits yet
>git status
On branch master
No commits yet
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        file1.txt

nothing added to commit but untracked files present (use "git add" to track)
```
At this point file1 is newly added to the working directory, so it is untracked. To start tracking it we added
it to the index using the **add** command.

```bash
>git add file1.txt
>git status
On branch master
No commits yet
Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   file1.txt
```
So now there are two (identical) copies of file1, in the **working** directory and in the **index**. If we make changes
to file1.txt they will affect the one in the **working** directory only. Edit "file1.txt", by adding the line "second version of file1.txt".

```bash
>echo "second version of file1.txt">>file1.txt
>git status
On branch master
No commits yet
Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   file1.txt

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   file1.txt
```

At this point the version in the **working** directory and the **index** are different. We can either add the second
version to the **index** or commit the **index**, or restore the version in the index (that contains one line only) to the working directory.
Let us try the last option.
```bash
>cat file1.txt

first version of file1.txt
second version of file1.txt

>git restore file1.txt
>git status
On branch master
No commits yet
Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   file1.txt
>cat file1.txt

first version of file1
```

Our next action is to commit the content of the **index** (staging area).
```bash
>git commit -m "added first version of file1"
>git status
On branch master
nothing to commit, working tree clean
```
Next we add the line "second version of text1" to file1.txt, add it to the index then add "third version" to file1. 
```bash
>echo "second version of file1.txt">> file1.txt
>git add file1.txt
>echo "third version of file1.txt">> file1.txt
```
So we have **three** versions of file1.txt: 
- one in the working tree
- one in the index
- one was committed. 

We can compare the difference between the three versions using the **diff** command.
First we show the difference between working tree and index.

```bash
>git diff
diff --git a/file1.txt b/file1.txt
index 0005eef..73c2f46 100644
--- a/file1.txt
+++ b/file1.txt
@@ -1,2 +1,3 @@
 first version of file1.txt
 second version of file1.txt
+third version of file1.txt
```

The above says that the version in the working tree has an extra line "third version of file1.txt".

We can also show the difference between working tree and the last commit.

```bash
>git diff HEAD #or git diff master
diff --git a/file1.txt b/file1.txt
index 7436323..73c2f46 100644
--- a/file1.txt
+++ b/file1.txt
@@ -1 +1,3 @@
 first version of file1.txt
+second version of file1.txt
+third version of file1.txt
```
Finally, we can show the difference between the index and the last commit (or any specified commit)
```bash
>git diff --cached 
diff --git a/file1.txt b/file1.txt
index 7436323..0005eef 100644
--- a/file1.txt
+++ b/file1.txt
@@ -1 +1,2 @@
 first version of file1.txt
+second version of file1.txt
```
```git diff --cached``` 
shows the difference between the **index** and last commit.

```git diff``` shows the difference between **working** directory and **index**

```git diff commit``` shows the difference between working directory and a commit

### Branching


Typically, to work on a new feature in a software base we create a new branch from the main one. This way all the changes we make do not affect the supposedly "working code". But after we are done developing the new feature we would like to incorporate back the new changes into the main part. Before we proceed we perform two commits to get three different 
versions of file1.txt in the database.
```bash
>git commit -m "added second version of file1"
# at this point the version in the index in the commit are the same. You can check using diff
>git add file1.txt
>git commit -m "added third version of file1"
>git log --oneline
31c7080 (HEAD -> master) added third version of file1
6b2bfba added second version of file1
da21bb7 added first version of file1
6b66b6a initial commit
```
First simple example. 
```bash
>git checkout -b dev # or git branch dev ; git checkout dev
>git log --oneline
31c7080 (HEAD -> dev, master) added third version of file1
6b2bfba added second version of file1
da21bb7 added first version of file1
6b66b6a initial commit
```

Notice that in the above output HEAD is pointing to dev.
On branch dev we add a new file: file2.txt then make a second version of file2.txt
```bash
>echo "first version of file2"> file2.txt
>git add file2.txt
>git commit -m "first version of file2"
>echo "second version of file2">> file2.txt
>git commit -a -m "second version of file2"
```
Now switch back to branch master and add file3.txt and then a second version of file3.txt

```bash
>git checkout master
>echo "first version of file3"> file3.txt
>git add file3.txt
>git commit -m "first version of file3"
>echo "second version of file3">> file3.txt
>git commit -a -m "second version of file3"
>git log --oneline -graph --all
```
![fig1](fig1.png)

As you can see from the figure above we now have two divergent, but separate, branches.
## Creating remote branches
First create a local branch then push it to the remote. Example

```
git branch experimental
git checkout experimental
git push origin experimental
```
### Merging 
 Once we are satisfied with the "development" on branch dev typically we want to incorporate the changes into master. We make sure first that we are "on" branch master.

```bash
>git checkout master
Already on 'master'
>git merge dev
```
A default editor will open with a default message "Merge branch 'dev'". We can change the message then save and quit.
```bash
>git log --oneline --graph --all
```
![fig2](fig2.png)
At this point branch master contains all the changes made in dev (note that file2.txt was created and modified on branch dev only)
```bash
>ls
file1.txt  file2.txt  file3.txt
```
Suppose that we made a mistake in merging and we want to undo it. Consulting the output of the log we see that the last commit before merge was 4ef2bf5.
```bash
>git reset --hard 4ef2bf5
>git log --oneline --graph --all
```
![fig1](fig1.png)
Lets do the merge again but this time passing the message on the command line
```bash
>git merge dev -m "Merging dev into master"
```
The merging operation went smoothly because we made sure not to change a file common between branches.
If there are different versions of the same file git does not know which one to choose so it is up to us to decide.
```bash
>git checkout dev
>echo "changed on dev">>file2.txt
>git commit -a -m "changed file2 on dev"
>git checkout master
>echo "changed on master">> file2.txt
>git commit -a -m "changed file2 on master"
>git merge dev
Auto-merging file2.txt
CONFLICT (content): Merge conflict in file2.txt
Automatic merge failed; fix conflicts and then commit the result.
```
git is telling us that it cannot perform the merge because there is a conflict between the two versions. 
```bash
>git status
On branch master
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   file2.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

But it also tells us where the conflict is
```bash
>cat file2.txt
first version of file2
second version of file2
changed on master
changed on dev
```
We can choose the version (or both) we want by editing the file, the committing. So after editing the file to our liking
```bash
>git commit -a -m "fixed merge conflict on file2.txt"
>git log --oneline --graph --all
```
![fig3](fig3.png)

### Rebase
Rebase allows us to change the **base** of a sequence of commits. Below we create two branches, master and dev, each with a series of commits.

Starting from an empty working directory we do  some commits on the master branch.
```bash
>echo "first line">file1.txt
>git init
>git add file1.txt
>git commit -m "1st master"
>echo "second line">>file1.txt
>git commit -a -m "2nd master"
>echo "third line">>file1.txt
>git commit -a -m "3rd master"
>git log --oneline

```
The commit history will look something like this.
![fig4](fig4.png)
Then we create a **dev** branch and add some commits to it.

```bash
>git checkout -b dev
>echo "file2">>file2.txt
>git add file2.txt
>git commit -m "1st dev"
```
Then switch back to master and add some commits.
```bash
>git checkout master
>echo "4th line">>file1.txt
>git commit -a -m "4th master"
>echo "5th line">>file1.txt
>git commit -a -m "5th master"
```
The history will look something like this.
![fig5](fig5.png)

The common  ancestor of both branches is the commit 3a99d41 which as far as git is concerned is the **base** of branch dev.
```bash
>git checkout dev
>git rebase master
>git log --oneline --graph --all
```
![fig6](fig6.png)
Basically, we are telling git to use master as a base for which to add all the commits of the dev branch since it branched out from master.
Another way to look at it is to use master as a base for commits from 3a99d41 to dev where 3a99d41 is automatically detected by git as the common ancestor of the two branches.


### Example

Below we create two branches with a series of commits. Each commit on master includes a new file. For example, in commit "1st master" file "master1.txt" was added... and for dev commit "1st dev" file "dev1.txt" was added.
```bash
>git log --oneline --graph --all
```
![fig7](fig7.png)

As can be seen the sequence of commits "4th dev",...,"1st dev" has commit "3rd master" as ancestor.  We rebase it on master,i.e. "5master" becomes the new ancestor.
```bash
#git rebase --onto new-base old-base tip
>git --onto master 3b360f5 dev
>git log --oneline --graph --all
```
![fig8](fig8.png)

### Cleaning up history

Sometimes the log becomes very long and we would like to get rid of the earlier commits. We can do that using rebase as follows. First we create an "orphan" branch were we want the new history to start.
First we remove the dev branch.
```bash
>git branch -D dev
```
Then 
```bash
>git checkout --orphan temp 3b360f5
>git commit -m "new initial commit"
```
Next we rebase the sequence of commits 3b360f5 to master from the new orphan branch
```bash
>git rebase --onto temp 3b360f5 master
>git log --oneline --graph --all
```
![fig9](fig9.png)


### FIX ME
```
git diff --name-only sha1 sha2
```

```
git diff --name-status sha1 sha2

```

```
git show ???
```


### Remote repos and Github
To add a remote repo you need the url and give it a name
```
git remote add origin URL
```
Here we gave it the name origin (instead of using URL every time)
To fetch the info about the remote 
```
git fetch origin
```

to associate an existing local branch with  remote
```
git branch --set-uptream-to=origin/branch-name local-branch-name
````

If we have a local branch, say ```someBranch```, that doesn't exist in the remote, and we want to add it
with a different name, say ```anotherName```

```
git push --set-upstream origin anotherName
```