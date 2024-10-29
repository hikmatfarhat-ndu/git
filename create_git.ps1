param([string] $checkpoint)
$checkpoint=[int]$checkpoint
# Basics
cd ../git-tmp
remove-item -Force -Recurse *
git init
git config advice.detachedHead false
echo "first version of file1" >file1.txt
git add file1.txt
echo "second version of file1.txt" >> file1.txt
git restore file1.txt
git commit -m "added first version of file1"
echo "second version of file1.txt" >> file1.txt
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
