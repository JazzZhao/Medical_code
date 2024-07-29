import pandas as pd
from glob import glob
import os
import re

#文件夹
folderpath = "night_light"

# 读取各个年份的夜光数据
files = os.listdir(folderpath)

#读取地名与ID的对应文件
ok_data_level3 = pd.read_csv("ok_data_level3.csv")
# 新建空的存放最后的结果
result_all = pd.DataFrame()
for file_name in files:
    #获取年份
    match = re.search(r'(F\d{4}|SNNP\d{4})', file_name)
    if match:
        year_str = match.group(0)[-4:]
        year = int(year_str)
        data_one_year = pd.read_csv(os.path.join(folderpath, file_name))
        #只需要id、ext_name、MEAN
        if result_all.empty:
            tmp_result = pd.merge(data_one_year, ok_data_level3, on="id", how="left")
            result_all = tmp_result[["id", "ext_name", "MEAN"]]
            #改列名
            result_all.rename(columns={"MEAN":year}, inplace=True)
        else:
            result_all = pd.merge(result_all, data_one_year[["id", "MEAN"]], on="id", how="left")
            #改列名
            result_all.rename(columns={"MEAN":year}, inplace=True)
    else:
        print(f"no year find in file: {file_name}")
    
result_all.to_csv("night_light_result.csv", encoding="utf-8", index=False)    

    
