import pandas as pd


#读取CHARLS数据
CHARLS_data = pd.read_csv("CHARLS_data_pollutants.csv")
#读取夜光数据
pollutants_data = pd.read_csv("night_light_result.csv", encoding="utf-8")
#处理哪一年的数据
year = 2020
#新增两列，分别为year的去年和前年的环境值
# CHARLS_data[['last_year_pm2.5', "before_last_pm2.5"]]=''
#开始筛选出year的数据
CHARLS_data_year = CHARLS_data[CHARLS_data['wave']==year]
#两个表合并
table_merge = pd.merge(CHARLS_data_year, pollutants_data, left_on="city", right_on="ext_name", how='left')
# table_merge_last.to_csv("123.csv",index=False)
#更新CHARLS表
CHARLS_data.loc[CHARLS_data['wave']==year, 'last_year_nl'] = table_merge[str(year-1)].values
CHARLS_data.loc[CHARLS_data['wave']==year, 'before_last_nl'] = table_merge[str(year-2)].values
CHARLS_data.to_csv("CHARLS_data_pollutants.csv",index=False)
print(year)