import pandas as pd
import requests
from time import sleep
import json
import os
from glob import glob

def get_city(lon, lat):
    params = {
        "lng": "{:.6f}".format(lon),
        "lat": "{:.6f}".format(lat)
    }
    flag = True
    while(flag):
        try:
            response_work = requests.get(url="http://103.116.120.27:9527/queryPoint",params = params)
            flag = False
        except Exception as e:
            print(f"请求错误一次：{e}")
            sleep(10)
            pass
    res_json_work = json.loads(response_work.text)
    #坐标在国内
    list_local_work = res_json_work['v']['list']
    if len(list_local_work) > 0:
        try:
            if len(list_local_work) == 1:
                province_city_work = [local_work['ext_path'] for local_work in list_local_work if local_work['deep'] == '0']
                return province_city_work[0], province_city_work[0]
            else:
                province_city_work = [local_work['ext_path'] for local_work in list_local_work if local_work['deep'] == '1']
                return province_city_work[0].split(" ")[0], province_city_work[0].split(" ")[1]
        except Exception as e:
            print("发生成异常"+json.dumps(list_local_work))
    else:
        print(f"这是一个空的坐标：{lon}，{lat}\n")
        return "", ""


if __name__ == "__main__":
    folder_path = "aba627/"
    result_path = "aba627/result/"
    #拿到文件夹中所有的csv文件
    csv_files = glob(folder_path+"*.csv")
    for file_path in csv_files:
        #对应省份和城市
        province_list = []
        city_list = []
        data = pd.read_csv(file_path, encoding="utf-8")
        #获取经纬度
        lons = data["X_Lon"]
        lats = data["Y_Lat"]
        for lon, lat in zip(lons, lats):
            province, city = get_city(lon=lon, lat=lat)
            province_list.append(province)
            city_list.append(city)
        data["province"] = province_list
        data["city"] = city_list
        data = data.iloc[:,4:].groupby(by=["province", "city"]).mean().reset_index()
        data.to_csv(result_path+os.path.basename(file_path), encoding="utf-8", index=False)
        


