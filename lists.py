def ae(ragged_list,i,j):
    code=3 if ragged_list==None else 0
    if code==3:
        return (3,None)
    n=len(ragged_list)
    if i>=n:
        return (1,None)
    m=len(ragged_list[i])
    if j>=m:
        return (2,None)
    return (0,ragged_list[i][j])
def access_element(ragged_list,i,j):
    code=3 if ragged_list==None else 0
    if code==3:
        return (3,None)
    try:
        z=ragged_list[i]
        try:
            w=z[j]
        except:
            code=2
            print("error in j")
    except:
        code=1
        print("error in i")

    if code!=0:
        return (code,None)
    else:
        return (code,w)
    

a=[[1,2,3],[4,5],[6,7,8,9]]
#y=[x for xs in a for x in xs]
i,j=4,2
print(access_element(a,i,j))
print("----------------")
print(ae(a,i,j))