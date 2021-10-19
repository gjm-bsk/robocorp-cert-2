from datetime import datetime
import calendar

def Last_day_of_the_Month_in_Dutch_Format():
    d = datetime.now()
    jaar = d.year
    maand = d.month
    DageninMaand = calendar.monthrange(jaar, maand)
    dagnummer, LaatsteDag = DageninMaand
    print(LaatsteDag)
    output = str(LaatsteDag) + "-"+ str(maand) + "-" + str(jaar)
    return output