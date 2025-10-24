from datetime import datetime
def formatt(timedelta):
    epoch=datetime(1970,1,1,hour=0,minute=0,second=0)
    td=(epoch+timedelta).strftime("%H:%M:%S")
    return td

