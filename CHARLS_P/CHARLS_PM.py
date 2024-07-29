import pandas as pd
from glob import glob
import os

def pollutant_handle(CHARLS_data):
    #读取污染物数据
    pollutants_data = pd.read_csv("result_O3_p.csv")
    #处理哪一年的数据
    year = 2020
    #开始筛选出year的数据
    CHARLS_data_year = CHARLS_data[CHARLS_data['wave']==year]
    #两个表合并
    table_merge = pd.merge(CHARLS_data_year, pollutants_data, on=['province', 'city'], how='left')
    #更新CHARLS表
    CHARLS_data.loc[CHARLS_data['wave']==year, 'last_year_O3'] = table_merge[str(year-1)].values
    CHARLS_data.loc[CHARLS_data['wave']==year, 'before_last_O3'] = table_merge[str(year-2)].values
    CHARLS_data.to_csv("CHARLS_data_pollutants.csv",index=False)
    print(year)

def aba_handle(CHARLS_data):
    #处理CHARLS数据的年份
    year = 2020
    path = "aba627/result/"
    #读取污染物组分
    last_year_file_name = path+str(year-1)+"_PM25_and_species_p.csv"
    before_last_file_name = path+str(year-2)+"_PM25_and_species_p.csv"
    last_year_pollutants_data = pd.read_csv(last_year_file_name)
    before_last_pollutants_data = pd.read_csv(before_last_file_name)
    #开始筛选出year的数据
    CHARLS_data_year = CHARLS_data[CHARLS_data['wave']==year]
    #和上一年的污染物组分文件合并
    last_table_merge = pd.merge(CHARLS_data_year, last_year_pollutants_data, on=['province', 'city'], how='left')
    CHARLS_data.loc[CHARLS_data['wave']==year, 'last_year_SO4'] = last_table_merge["SO4"].values
    CHARLS_data.loc[CHARLS_data['wave']==year, 'last_year_NO3'] = last_table_merge["NO3"].values
    CHARLS_data.loc[CHARLS_data['wave']==year, 'last_year_NH4'] = last_table_merge["NH4"].values
    CHARLS_data.loc[CHARLS_data['wave']==year, 'last_year_OM'] = last_table_merge["OM"].values
    CHARLS_data.loc[CHARLS_data['wave']==year, 'last_year_BC'] = last_table_merge["BC"].values
    #和上上年的污染物组分文件合并
    before_last_table_merge = pd.merge(CHARLS_data_year, before_last_pollutants_data, on=['province', 'city'], how='left')
    CHARLS_data.loc[CHARLS_data['wave']==year, 'before_last_SO4'] = before_last_table_merge["SO4"].values
    CHARLS_data.loc[CHARLS_data['wave']==year, 'before_last_NO3'] = before_last_table_merge["NO3"].values
    CHARLS_data.loc[CHARLS_data['wave']==year, 'before_last_NH4'] = before_last_table_merge["NH4"].values
    CHARLS_data.loc[CHARLS_data['wave']==year, 'before_last_OM'] = before_last_table_merge["OM"].values
    CHARLS_data.loc[CHARLS_data['wave']==year, 'before_last_BC'] = before_last_table_merge["BC"].values
    #更新CHARLS表
    CHARLS_data.to_csv("CHARLS_data_pollutants.csv",index=False)
    print(year)

if __name__ == "__main__":
    #读取CHARLS数据
    CHARLS_data = pd.read_csv("CHARLS_data_pollutants.csv")
    print(CHARLS_data.info())
    # CHARLS_data1 = pd.read_csv("NHANES/result_all.csv")
    # print(CHARLS_data1.info())
    
    #处理污染物
    # pollutant_handle(CHARLS_data)
    #处理PM2.5组分
    # aba_handle(CHARLS_data)