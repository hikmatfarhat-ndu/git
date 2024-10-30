param([string] $checkpoint)
$checkpoint=[int]$checkpoint
# Basics
cd ../git-tmp
remove-item -Force -Recurse *
git init
git config advice.detachedHead false
echo "first version of file1" >file1.txt
git add file1.txt
echo "second version of file1" >> file1.txt
git restore file1.txt
git commit -m "added first version of file1"
echo "second version of file1" >> file1.txt
git add file1.txt
echo "third version of file1">> file1.txt
git commit -m "added second versio of file1"
git add file1.txt
git commit -m "added third verison of file1"
git log --oneline --graph --all
if ($checkpoint -eq 1){
    Return
}
# Branching
git checkout -b dev 
git log --oneline --graph --all
echo "first version of file2" > file2.txt
git add file2.txt
git commit -m "first version of file2"
echo "second version of file2" >> file2.txt
git commit -a -m "second version of file2"
git checkout main
echo "first version of file3" >file3.txt
git add file3.txt
git commit -m "first version of file3"
echo "second version of file3" >>file3.txt
git commit -a -m "second version of file3"
git log --oneline --graph --all
if($checkpoint -eq 2){
    Return
}
# Merging
git checkout main
git merge dev
git log --oneline --graph --all
ls
# merge with conflict
git checkout dev 
git merge main
git log --oneline --graph --all

echo "added lines on dev" >> file2.txt
echo "changed on dev" >> file2.txt
git commit -a -m "changed file2 on dev"
git checkout main
echo "changed on main" >> file2.txt
git commit -a -m "changed file2 on main"    
git merge dev
$text=Get-Content file2.txt
cat file2.txt
$text[0..($text.count -2)]|Where-Object {$_ -notmatch "(^<)|(^>)|(^=)|(added)"}>file2.txt

# get-content ./file2.txt |Where-Object{$_ -notmatch '<|>|='}| Set-Content file2.txt
git commit -a -m "fixed merge conflict on file2.txt"
git log --oneline --graph --all
if($checkpoint -eq 3){
    Return
}

# undoing commits
git checkout main~1
ls
echo "---cat file2.txt---"
cat file2.txt
echo "--------------------"

git checkout main
git revert HEAD
git revert -m 1 HEAD
ls
git log --oneline --graph --all
git diff HEAD main~2

## reset
git reset --hard main~2
git merge dev


$text=Get-Content file2.txt
$text[0..($text.count -2)]|Where-Object {$_ -notmatch "(^<)|(^>)|(^=)|(^c.*v$)"}>file2.txt

git commit -a -m "re-fixed conflict"


if ($checkpoint -eq 4){
    Return
}

# remote 
$caution=@"
---------------------------------------------------------
Make sure you have created remote repository            |
https://git.soton.ac.uk/username/gitlab                 |
(If you already have one, delete it and recreate again) |
Press any key to continue                               |
---------------------------------------------------------

"@

Read-Host -Prompt $caution
git remote add origin https://git.soton.ac.uk/hf1g22/gitlab
git checkout main
git push -u origin main
git checkout dev 
git push -u origin dev

$caution=@"
--------------------------------------------------
Make sure you have created file4.txt             |
on the remote repository                         | |
Press any key to continue                        |
--------------------------------------------------

"@
Read-Host -Prompt $caution
git pull
git checkout main
git pull


if ($checkpoint -eq 5){
    Return
}

# leaderboard
Remove-Item -Force -Recurse *
$gig=@"
.idea
__pycache
"@
echo $gig >>.gitignore
$code1=@"
from datetime import datetime,timedelta

def init_leaderboard()->dict[str,timedelta]:
    return {}


def add_player(leaderboard:dict[str,timedelta],player_name:str)->bool:
    if player_name in leaderboard:
        return False
    leaderboard.update({player_name:None})
    return True
"@
echo $code1 >>leaderboard.py
git init
git add leaderboard.py .gitignore 
git commit -m "implemented init and add_player"
$caution=@"
--------------------------------------------------
Make sure you have created remote repository     |
https://git.soton.ac.uk/username/leaderboard     |
(If you already have, delete and recreate again) |
Press any key to continue                        |
--------------------------------------------------

"@
Read-Host -Prompt $caution
git remote add origin https://git.soton.ac.uk/hf1g22/leaderboard
git push -u origin main
git checkout -b dev
git push -u origin dev
git branch -c feature1
git branch -c feature2
git checkout feature1
$code=@"
def add_run(leaderboard:dict[str,timedelta],player_name:str,time:timedelta)->int:
    if time.total_seconds()<0:
        return 1
    if player_name not in leaderboard:
        return 2
    
    if leaderboard[player_name]==None or leaderboard[player_name]> time:
        leaderboard.update({player_name:time})
    return 0
"@
echo $code >>leaderboard.py
git commit -a -m "implemented add_run"
git checkout feature2
$code=@"
def clear_score(leaderboard,player_name):
    if player_name not in leaderboard:
        return False
    leaderboard.update({player_name:None})
    return True
"@
echo $code >>leaderboard.py
git commit -a -m "implemented clear_score"
git checkout dev 
git merge feature1
git merge feature2
$text=Get-Content leaderboard.py
$text[0..($text.count -2)]|Where-Object {$_ -notmatch "(^<)|(^>)|(^=)|(added)"}>leaderboard.py
git commit -a -m "fixed merge conflict"
git branch -d feature1
git branch -d feature2
git log --oneline --graph --all
$caution=@"
----------------------------------------------
We are ready to push to remote.              |
Make sure remote repository is initialised   |
----------------------------------------------

"@
Read-Host -Prompt $caution
git push 

$caution=@"
----------------------------------------------
Go to gitlab and perform the merge request   |
Press any key to continue                    |
----------------------------------------------

"@
Read-Host -Prompt $caution
git checkout main 
git pull
git checkout dev 
git merge main
git push
