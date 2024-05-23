objects=$(find .git/objects/ -type f)
for h in $objects
do 
hash=$(echo $h | sed 's/\// /g'|cut -d ' '  -f 3,4|sed 's/ //g')
echo $hash
type=$(git cat-file -t $hash)
echo $type
if [ "$type" = "commit" ]
then
git cat-file -p $hash
fi

echo
echo
echo "---------------------------------------"
done
