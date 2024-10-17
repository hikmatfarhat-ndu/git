objects=$(find .git/objects/ -type f)
for h in $objects
do 
hash=$(echo $h | sed 's/\// /g'|cut -d ' '  -f 3,4|sed 's/ //g')
type=$(git cat-file -t $hash)
echo $hash $type
git cat-file -p $hash

echo
echo
echo "---------------------------------------"
done
