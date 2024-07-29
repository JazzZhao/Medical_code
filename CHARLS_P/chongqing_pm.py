import pandas as pd
from glob import glob
import os

def pollutant_chongqing_handle():
    path = "result_O3"
    data = pd.read_csv(path+".csv")
    # 找到province列等于'重庆市'的行
    chongqing_rows = data[data['province'] == '重庆市']
    # 求这些行除了'A'列和'B'列之外的其他列的平均值
    avg_values = chongqing_rows.iloc[:, 2:].mean()
    insert = pd.DataFrame([avg_values])
    # 增加前两行
    insert['province'] = '重庆市'
    insert['city'] = '重庆市'
    df = pd.concat([data,insert])
    df.to_csv(path+"_p.csv", index=False)

def aba_chongqing_handle():
    path = "aba627/result/"
    files = glob(path+"*.csv")
    for file in files:
        data = pd.read_csv(file)
        # 找到province列等于'重庆市'的行
        chongqing_rows = data[data['province'] == '重庆市']
        # 求这些行除了'A'列和'B'列之外的其他列的平均值
        avg_values = chongqing_rows.iloc[:, 3:].mean()
        insert = pd.DataFrame([avg_values])
        # 增加前两行
        insert['province'] = '重庆市'
        insert['city'] = '重庆市'
        df = pd.concat([data,insert])
        tmp = os.path.basename(file)
        file_name, extension = os.path.splitext(tmp)
        df.to_csv(path+file_name+"_p"+extension, index=False)

if __name__ == "__main__":
    aba_chongqing_handle()