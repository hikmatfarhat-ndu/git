from datetime import datetime,timedelta
from format_timedelta import formatt
def init_leaderboard()->dict[str,timedelta]:
    return {}


def add_player(leaderboard:dict[str,timedelta],player_name:str)->bool:
    if player_name in leaderboard:
        return False
    leaderboard.update({player_name:None})
    return True

def add_run(leaderboard:dict[str,timedelta],player_name:str,time:timedelta)->int:
    if time.total_seconds()<0:
        return 1
    if player_name not in leaderboard:
        return 2
    
    if leaderboard[player_name]==None or leaderboard[player_name]> time:
        leaderboard.update({player_name:time})
    return 0
def clear_score(leaderboard,player_name):
    if player_name not in leaderboard:
        return False
    leaderboard.update({player_name:None})
    return True

def display_leaderboard(leaderboard,n=3):
    lst=sorted(leaderboard.items(),key=lambda x:(x[1] is None,x[1]))
    #lst=sorted(leaderboard.items(),key=lambda x:x[1])
    r=min(n,len(lst))
    count=0
    

    for i in range(r):
    #for i,v in enumerate(lst):
        if lst[i][1] is not None:
            td=formatt(lst[i][1])
            print(f'{i+1}\t{lst[i][0]}\t{td}')
            count+=1
    if count==0:
        print("Leaderboard is empty")
def calculate_average_time(leaderboard):
    ave=0
    count=0
    for r in leaderboard.items():
        if r[1] is not None:
            ave+=r[1].seconds
            count+=1
    if count==0:
        return (False,0)
    return (True,formatt(timedelta(seconds=ave/count)))
lb=init_leaderboard()
add_player(lb,'zaza')
add_player(lb,'zozo')

add_run(lb,'zaza',timedelta(minutes=10))
add_run(lb,'zozo',timedelta(minutes=14))
display_leaderboard(lb)
add_player(lb,'zizi')
add_run(lb,'zizi',timedelta(minutes=7))
display_leaderboard(lb)
print(calculate_average_time(lb)[1])