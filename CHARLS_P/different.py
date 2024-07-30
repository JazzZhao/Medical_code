import pandas as pd
from glob import glob

year = "2011"
path = "/root/r_base/CHARLS/CHARLS"

if __name__ == "__main__":
    year = "2011"
    files = glob(path+"2011/*.dta")
    var_2011 = []
    for file_name in files:
        data = pd.read_stata(file_name)
        var_2011 += data.columns.to_list()
    year = "2013"
    files = glob(path+"2013/*.dta")
    var_2013 = []
    for file_name in files:
        data = pd.read_stata(file_name)
        var_2013 += data.columns.to_list()
    #获取2013新增变量
    var_2011 = set(var_2011)
    result_2013 = [elem for elem in var_2013 if elem not in var_2011]
    with open("2013.csv", "w") as f2013:
        f2013.write('\n'.join(result_2013) + '\n')

    year = "2015"
    files = glob(path+"2015/*.dta")
    var_2015 = []
    for file_name in files:
        data = pd.read_stata(file_name)
        var_2015 += data.columns.to_list()
    #获取2015新增变量
    var_2013 = set(var_2013)
    result_2015 = [elem for elem in var_2015 if elem not in var_2013]
    with open("2015.csv", "w") as f2015:
        f2015.write('\n'.join(result_2015) + '\n')

    year = "2018"
    files = glob(path+"2018/*.dta")
    var_2018 = []
    for file_name in files:
        data = pd.read_stata(file_name)
        var_2018 += data.columns.to_list()
    #获取2018新增变量
    var_2015 = set(var_2015)
    result_2018 = [elem for elem in var_2018 if elem not in var_2015]
    with open("2018.csv", "w") as f2018:
        f2018.write('\n'.join(result_2018) + '\n')

    year = "2020"
    files = glob(path+"2020/*.dta")
    var_2020 = []
    for file_name in files:
        data = pd.read_stata(file_name)
        var_2020 += data.columns.to_list()
    #获取2020新增变量
    var_2018 = set(var_2018)
    result_2020 = [elem for elem in var_2020 if elem not in var_2018]
    with open("2020.csv", "w") as f2020:
        f2020.write('\n'.join(result_2020) + '\n')