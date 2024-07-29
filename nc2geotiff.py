#;+
#; :Author: Dr. Jing Wei (Email: weijing_rs@163.com)
#;-
import os
from time import sleep
# import gdal
import netCDF4 as nc
import numpy as np  
from glob import glob
import requests
import json
import pandas as pd
import concurrent.futures
# from osgeo import osr

#Define work and output paths
WorkPath = r'/root/r_base/O3'
OutPath  = WorkPath

#Define air pollutant type 
#e.g., PM1, PM2.5, PM10, O3, NO2, SO2, and CO, et al.
AP = 'O3'

#Define spatial resolution 
#e.g., 1 km ≈ 0.01 Degree
SP = 0.01 #Degrees

if not os.path.exists(OutPath):
    os.makedirs(OutPath)
path = glob(os.path.join(WorkPath, '*.nc'))

#线程运行函数
def thread_work(vll_work, start, end):
    result_work_array = []
    for value_work, lat_ind_work, lon_ind_work in vll_work:
        params = {
            "lng": "{:.6f}".format(lon[lon_ind_work]),
            "lat": "{:.6f}".format(lat[lat_ind_work])
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
                    tmp_result_work = [province_city_work[0], province_city_work[0], value_work]
                    result_work_array.append(tmp_result_work)
                else:
                    province_city_work = [local_work['ext_path'] for local_work in list_local_work if local_work['deep'] == '1']
                    tmp_result_work = [province_city_work[0].split(" ")[0], province_city_work[0].split(" ")[1], value_work]
                    result_work_array.append(tmp_result_work)
            except Exception as e:
                print("发生成异常"+json.dumps(list_local_work))
        else:
            print(f"这是一个空的坐标：{lon[lon_ind_work]}，{lat[lat_ind_work]}\n")
        # if len(result_work_array) % 100 == 0 :
            # print(f"当前线程处理开始{start},结束{end}, 已经处理的个数为{len(result_work_array)}\n")
    return result_work_array

for file in path:
    #全部年份的
    file_path = "result.csv"
    #提取出来年份
    year = file.split("_")[4]
    print(f"当前处理年份{year}")
    f = nc.Dataset(file)   
    #Read SDS data
    data = np.array(f[AP][:]) 
    #Define missing value: NaN or -999
    data[data==65535] = np.nan #-999 
    #Read longitude and latitude information
    lon = np.array(f['lon'][:])
    lat = np.array(f['lat'][:])
    #获取非空索引
    indices = np.where(~np.isnan(data))
    #获取非空值
    values = data[indices]
    #拼接（value, lat, lon）
    vll = list(zip(values, indices[0], indices[1]))
    #继续索引记录文件地址
    index_path = "index_"+year+".txt"
    # 尝试以读取模式打开文件
    try:
        with open(index_path, 'r') as file:
            # 如果文件存在，读取文件内容
            index = file.readline()
    # 如果文件不存在，则新建文件并写入内容
    except FileNotFoundError:
        index = 0
    vll = vll[int(index):]
    #将一年的数据拆分成多大一块
    batch_size = 100000
    total_len = len(vll)
    if total_len == 0:
        continue
    batch_start = 0
    # 多少个线程
    max_workers = 10
    with concurrent.futures.ThreadPoolExecutor(max_workers) as executor:
        for i in range(total_len // batch_size + 1):
            # 尝试以读取模式打开文件
            try:
                # 如果文件存在，读取文件内容
                result_all = pd.read_csv(file_path)
            # 如果文件不存在，则新建文件并写入内容
            except FileNotFoundError:
                result_all = []
            batch_end = min(batch_start + batch_size, total_len)
            vll_one = vll[batch_start:batch_end]
            batch_start = batch_end
            result_array = []
            #并行调用接口获取坐标对应城市
            start = 0
            avg = len(vll_one)//max_workers
            remainder = len(vll_one) % max_workers
            all_task = []
            for i in range(max_workers):
                if i < remainder:
                    end = start + avg + 1
                else:
                    end = start + avg
                all_task.append(executor.submit(thread_work, vll_one[start:end], start, end))
                start = end
            for future in concurrent.futures.as_completed(all_task):
                data = future.result()
                result_array = result_array + data
            #相同地区求平均
            columns = ['province', 'city', year]
            result_df = pd.DataFrame(result_array, columns=columns)
            if len(result_all) == 0 :
                result_all = result_df.groupby(['province', 'city']).mean().reset_index()
            else:
                result_one = result_df.groupby(['province', 'city']).mean().reset_index()
                #合并
                if year in result_all.columns:
                    print("============新加的数据================")
                    print(result_one)
                    concatenated_df = pd.concat([result_all[['province', 'city', year]], result_one])
                    # 使用 groupby 进行聚合
                    grouped_df = concatenated_df.groupby(['province', 'city']).mean().reset_index()
                    result_all = pd.merge(result_all, grouped_df, on=['province', 'city'], how='outer', suffixes=('', '_total'))
                    #替换掉
                    result_all[year] = result_all[year+"_total"]
                    result_all = result_all.drop([year+"_total"], axis=1)
                else:
                    result_all = pd.merge(result_all, result_one, on=['province', 'city'], how="outer")
            print("============合并后的数据================")
            print(result_all.head())
            result_all.to_csv("result.csv",index=False)
            with open(index_path, 'w') as file:
                # 如果文件存在，读取文件内容
                file.write(str(batch_end+int(index)))
    # LonMin,LatMax,LonMax,LatMin = lon.min(),lat.max(),lon.max(),lat.min()    
    # N_Lat = len(lat) 
    # N_Lon = len(lon)
    # Lon_Res = SP #round((LonMax-LonMin)/(float(N_Lon)-1),2)
    # Lat_Res = SP #round((LatMax-LatMin)/(float(N_Lat)-1),2)
    # #Define Define output file
    # fname = os.path.basename(file).split('.nc')[0]
    # outfile = OutPath + '/{}.tif' .format(fname)        
    #Write GeoTIFF
    # driver = gdal.GetDriverByName('GTiff')    
    # outRaster = driver.Create(outfile,N_Lon,N_Lat,1,gdal.GDT_Float32)
    # outRaster.SetGeoTransform([LonMin-Lon_Res/2,Lon_Res,0,LatMax+Lat_Res/2,0,-Lat_Res])
    # sr = osr.SpatialReference()
    # sr.SetWellKnownGeogCS('WGS84')
    # outRaster.SetProjection(sr.ExportToWkt())
    # outRaster.GetRasterBand(1).WriteArray(data)
    # print(fname+'.tif',' Finished')     
    # #release memory
    # del outRaster
    f.close()
# result_all.reset_index(inplace=True)
# print(result_all.head())
# result_all.to_csv("result.csv",index=False)
